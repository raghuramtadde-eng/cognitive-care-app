-- Cognitive Care App — Supabase schema (v2: real auth + least-privilege RLS)
--
-- AUTH MODEL
-- Only caregivers hold real Supabase Auth accounts (email + password).
-- A patient does NOT have an independent Supabase Auth account — asking a
-- dementia patient to manage a real account isn't realistic, and every
-- request the app makes — in Patient view or Caregiver view — is still
-- authenticated as the caregiver's own Supabase session regardless of
-- which patient is active. Ownership of a patient record
-- (patients.caregiverId = auth.uid()) is therefore the one fact every RLS
-- policy below is ultimately derived from.
--
-- Instead, each patient record carries a Patient User ID (globally unique
-- across every caregiver's patients, not just one caregiver's own -- see
-- is_patient_user_id_taken() below) and a password (hashed, never
-- plaintext), both set by the caregiver. Logging in with the correct pair
-- switches the app's UI into that exact patient's Patient interface (see
-- patient_login_screen.dart) -- this replaced an earlier bare-PIN design
-- that had no way to tell two same-PIN patients apart.
--
-- This keeps patient-profile creation fully offline-capable (no network
-- call needed beyond the caregiver already being logged in — their
-- auth.uid() is available locally from the cached session) and avoids the
-- session-juggling that separate per-patient Supabase Auth accounts would
-- require.
--
-- SECURITY NOTES
-- * RLS is enabled on every table. There are no "allow all" policies.
-- * The publishable/anon key is the only key ever used by the app. It has
--   no power on its own — every read/write is gated by these RLS policies
--   evaluated against the caller's authenticated auth.uid(). The
--   service_role key (which bypasses RLS) must never be embedded in the
--   Flutter app; it is not needed anywhere in this design.
-- * A Patient User ID is an identifier, not a secret -- it is what the
--   password is checked against, not what protects the data. Its hash
--   (like the password's) is salted with the patient's own id, which stops
--   trivial cross-patient rainbow-table reuse. Real protection against a
--   stranger reading a patient's data is: they would first need the
--   caregiver's own Supabase account credentials.

-- ── profiles: one row per caregiver (the only role that authenticates) ──
create table if not exists profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  created_at timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "profiles_select_own" on profiles
  for select using (auth.uid() = id);
create policy "profiles_insert_own" on profiles
  for insert with check (auth.uid() = id);
create policy "profiles_update_own" on profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- Auto-create the profile row the moment someone signs up, so there is
-- never a caregiver account with no matching profile.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── patients: one row per patient, owned by exactly one caregiver ──
create table if not exists patients (
  id text primary key,
  "caregiverId" uuid not null references auth.users (id) on delete cascade,
  name text not null,
  age integer not null,
  language text not null,
  -- Deliberately independent of `language` above -- a caregiver may want
  -- English UI with Assam-themed game content, or Assamese UI with
  -- Manipur theme, etc. Never inferred from `language`; always an
  -- explicit choice at patient setup (see patient.dart / patient_setup_screen.dart).
  "culturalTheme" text not null default 'general',
  "photoPath" text,
  "userId" text not null,
  "passwordHash" text not null,
  "sessionTokenHash" text,
  "createdAt" text not null,
  "updatedAt" text not null,
  "isSynced" integer not null default 0
);
create index if not exists idx_patients_caregiver on patients ("caregiverId");
create unique index if not exists idx_patients_user_id on patients ("userId");

-- Existing projects created before this column: run once via the SQL
-- editor (no-op on a fresh create above).
alter table patients add column if not exists "culturalTheme" text not null default 'general';

-- Migrates a project created before the Patient User ID + password
-- architecture (no-op on a fresh create above, where the table already has
-- these columns from CREATE TABLE itself). Run once via the SQL editor.
alter table patients add column if not exists "userId" text;
alter table patients add column if not exists "sessionTokenHash" text;
-- Existing rows (created back when only a PIN existed) predate userId --
-- backfill a placeholder derived from name + a slice of the row's own
-- (already-unique) id, mirroring database_service.dart's local migration,
-- so the NOT NULL + UNIQUE constraints below can be applied without data
-- loss. A caregiver can still tell the patient apart by name in the
-- Patients screen regardless of this placeholder.
update patients
set "userId" = lower(regexp_replace(name, '[^a-zA-Z0-9]', '', 'g')) || '_' || substr(id, 1, 6)
where "userId" is null;
alter table patients alter column "userId" set not null;
-- Only run this the FIRST time a project is migrated -- once every row has
-- a real userId, re-running is a no-op; but if two placeholders above ever
-- collided (extremely unlikely given the id suffix) this index creation
-- would fail loudly rather than silently corrupt data, which is the
-- intended safety behavior.
create unique index if not exists idx_patients_user_id on patients ("userId");
-- Guarded rename: a fresh create above already names the column
-- "passwordHash" directly, so a plain RENAME COLUMN would error out on a
-- brand-new project. Only rename when the old "pinHash" column actually
-- exists (i.e. this is a pre-existing project being migrated).
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'patients' and column_name = 'pinHash'
  ) then
    alter table patients rename column "pinHash" to "passwordHash";
  end if;
end $$;

alter table patients enable row level security;

create policy "patients_select_own" on patients
  for select using (auth.uid() = "caregiverId");
create policy "patients_insert_own" on patients
  for insert with check (auth.uid() = "caregiverId");
create policy "patients_update_own" on patients
  for update using (auth.uid() = "caregiverId") with check (auth.uid() = "caregiverId");
create policy "patients_delete_own" on patients
  for delete using (auth.uid() = "caregiverId");

-- Shared helper: does the CURRENT caregiver own this patient id? Every
-- child table below is scoped through this one function instead of
-- repeating the join inline six times.
create or replace function public.owns_patient(pid text)
returns boolean
language sql
stable
security definer set search_path = public
as $$
  select exists (
    select 1 from patients p
    where p.id = pid and p."caregiverId" = auth.uid()
  );
$$;

-- Lets a caregiver check whether a candidate Patient User ID is already
-- taken by ANY patient, not just their own -- the patients_select_own
-- policy above correctly stops a caregiver's session from seeing another
-- caregiver's rows, so a true global uniqueness check needs this narrow,
-- additive escape hatch. Returns ONLY a boolean; leaks no other data about
-- who owns the id or any other row (see patient_provider.dart's
-- checkUserIdTakenRemotely, and patient_setup_screen.dart). Does not
-- change or weaken any existing RLS policy.
create or replace function public.is_patient_user_id_taken(p_user_id text)
returns boolean
language sql
stable
security definer set search_path = public
as $$
  select exists (
    select 1 from patients p where p."userId" = p_user_id
  );
$$;
grant execute on function public.is_patient_user_id_taken(text) to authenticated;

-- ── game_sessions ──
create table if not exists game_sessions (
  id text primary key,
  "patientId" text not null references patients (id) on delete cascade,
  "gameType" text not null check ("gameType" in ('memory_match', 'sequence_recall', 'spot_change')),
  "difficultyLevel" integer not null,
  score integer not null,
  accuracy double precision not null,
  "avgResponseTimeMs" integer not null,
  "playedAt" text not null,
  "updatedAt" text not null,
  "isSynced" integer not null default 0
);
create index if not exists idx_game_sessions_patient on game_sessions ("patientId");

alter table game_sessions enable row level security;
create policy "game_sessions_owner" on game_sessions
  for all using (owns_patient("patientId")) with check (owns_patient("patientId"));

-- ── game_progress ──
create table if not exists game_progress (
  "patientId" text not null references patients (id) on delete cascade,
  "gameType" text not null check ("gameType" in ('memory_match', 'sequence_recall', 'spot_change')),
  "currentLevel" integer not null,
  "consecutiveGood" integer not null default 0,
  "consecutivePoor" integer not null default 0,
  "updatedAt" text not null,
  "isSynced" integer not null default 0,
  primary key ("patientId", "gameType")
);

alter table game_progress enable row level security;
create policy "game_progress_owner" on game_progress
  for all using (owns_patient("patientId")) with check (owns_patient("patientId"));

-- ── routine_items ──
create table if not exists routine_items (
  id text primary key,
  "patientId" text not null references patients (id) on delete cascade,
  type text not null check (type in ('medicine', 'hydration', 'activity', 'appointment')),
  title text not null,
  "scheduledHour" integer not null,
  "scheduledMinute" integer not null,
  active integer not null default 1,
  "updatedAt" text not null,
  "isSynced" integer not null default 0
);
create index if not exists idx_routine_items_patient on routine_items ("patientId");

alter table routine_items enable row level security;
create policy "routine_items_owner" on routine_items
  for all using (owns_patient("patientId")) with check (owns_patient("patientId"));

-- ── routine_logs ──
create table if not exists routine_logs (
  id text primary key,
  "routineItemId" text not null references routine_items (id) on delete cascade,
  "patientId" text not null references patients (id) on delete cascade,
  date text not null,
  status text not null check (status in ('pending', 'done', 'missed')),
  "completedAt" text,
  -- Null = not yet asked; the Recall Check-in's own memory-test result
  -- (0/1, matching every other boolean-ish column here, not a native
  -- Postgres boolean -- RoutineLog.toMap() sends a plain 0/1/null int and
  -- PostgREST rejects integers for a real boolean column), kept separate
  -- from `status` above (the caregiver's actual Done/Missed record) -- see
  -- routine_recall_screen.dart.
  "recalledCorrectly" integer,
  "updatedAt" text not null,
  "isSynced" integer not null default 0
);
create index if not exists idx_routine_logs_patient_date on routine_logs ("patientId", date);

-- Existing projects created before this column: run once via the SQL editor
-- (no-op on a fresh create above).
alter table routine_logs add column if not exists "recalledCorrectly" integer;

alter table routine_logs enable row level security;
create policy "routine_logs_owner" on routine_logs
  for all using (owns_patient("patientId")) with check (owns_patient("patientId"));

-- ── caregiver_alerts ──
-- Derived caregiver-facing notices (a routine item left unactioned well past
-- its time, or a sharp drop in a game's accuracy vs. the patient's own
-- recent baseline) -- see alert_service.dart. sourceKey + date together
-- identify the specific occurrence that triggered the alert (a routine
-- item's id, or a game type's key) so the unique constraint below stops the
-- same occurrence from ever generating more than one row, even though
-- AlertService's checks are safe to re-run on every dashboard/routine load.
create table if not exists caregiver_alerts (
  id text primary key,
  "patientId" text not null references patients (id) on delete cascade,
  type text not null check (type in ('missedReminder', 'gameDecline')),
  title text not null,
  message text not null,
  "sourceKey" text not null,
  date text not null,
  "createdAt" text not null,
  "isRead" integer not null default 0,
  "isSynced" integer not null default 0,
  unique ("patientId", "sourceKey", date)
);
create index if not exists idx_caregiver_alerts_patient on caregiver_alerts ("patientId", "createdAt");

alter table caregiver_alerts enable row level security;
create policy "caregiver_alerts_owner" on caregiver_alerts
  for all using (owns_patient("patientId")) with check (owns_patient("patientId"));

-- ── memory_lane_items ──
-- A personalized reminiscence memory (who/where/when/story), optionally
-- with an attached favorite song. `viewCount`/`presentedCount`/
-- `recognizedCount` are soft engagement signals for the caregiver dashboard
-- only — this table is never read by the adaptive difficulty engine that
-- game_sessions/game_progress feed (see adaptive_difficulty_service.dart).
-- `remoteUrl`/`songRemoteUrl` hold the object's *path within the private
-- memory-lane Storage bucket* (e.g. "<patientId>/<id>_photo.jpg"), not a
-- public URL — the app always fetches bytes through the authenticated
-- client (storage.from('memory-lane').download(path)), which is gated by
-- the same owns_patient() policy as the row itself (see below).
create table if not exists memory_lane_items (
  id text primary key,
  "patientId" text not null references patients (id) on delete cascade,
  type text not null check (type in ('photo', 'song', 'habit')),
  title text not null,
  description text,
  place text,
  "memoryDate" text,
  "remoteUrl" text,
  "songRemoteUrl" text,
  "viewCount" integer not null default 0,
  "presentedCount" integer not null default 0,
  "recognizedCount" integer not null default 0,
  "createdAt" text not null,
  "updatedAt" text not null,
  "isSynced" integer not null default 0
);
create index if not exists idx_memory_lane_patient on memory_lane_items ("patientId");

-- Existing projects created before this column set: run once via the SQL
-- editor (all no-ops on a fresh create above).
alter table memory_lane_items add column if not exists place text;
alter table memory_lane_items add column if not exists "memoryDate" text;
alter table memory_lane_items add column if not exists "songRemoteUrl" text;
alter table memory_lane_items add column if not exists "viewCount" integer not null default 0;
alter table memory_lane_items add column if not exists "presentedCount" integer not null default 0;
alter table memory_lane_items add column if not exists "recognizedCount" integer not null default 0;

alter table memory_lane_items enable row level security;
create policy "memory_lane_items_owner" on memory_lane_items
  for all using (owns_patient("patientId")) with check (owns_patient("patientId"));

-- ── Storage: the actual photo/audio files Memory Lane rows point to ──
-- memory_lane_items."remoteUrl" is only a string; the files themselves live
-- in Supabase Storage and need their own access policies (Storage is a
-- separate permission system from table RLS). Files are uploaded under a
-- path of the form "<patientId>/<filename>" — storage.foldername(name) [1]
-- pulls out that leading patientId segment, so the exact same owns_patient()
-- ownership check used for every table above also gates the files.
insert into storage.buckets (id, name, public)
values ('memory-lane', 'memory-lane', false)
on conflict (id) do nothing;

create policy "memory_lane_storage_select" on storage.objects
  for select using (
    bucket_id = 'memory-lane' and owns_patient((storage.foldername(name))[1])
  );
create policy "memory_lane_storage_insert" on storage.objects
  for insert with check (
    bucket_id = 'memory-lane' and owns_patient((storage.foldername(name))[1])
  );
create policy "memory_lane_storage_delete" on storage.objects
  for delete using (
    bucket_id = 'memory-lane' and owns_patient((storage.foldername(name))[1])
  );

-- ── Baseline table-level privileges ──
-- RLS policies only decide WHICH ROWS a role may touch — Postgres
-- separately requires this baseline grant before RLS is even evaluated.
-- On a normal Supabase project this is usually pre-configured automatically
-- for tables created through the dashboard's SQL editor; it's included
-- explicitly here so this script is self-sufficient regardless of how it's
-- run (dashboard editor, or a direct superuser connection, as was actually
-- needed here after the dashboard editor hit an unrelated UI bug).
grant usage on schema public to authenticated;
grant select, insert, update, delete on
  public.profiles,
  public.patients,
  public.game_sessions,
  public.game_progress,
  public.routine_items,
  public.routine_logs,
  public.caregiver_alerts,
  public.memory_lane_items
to authenticated;
