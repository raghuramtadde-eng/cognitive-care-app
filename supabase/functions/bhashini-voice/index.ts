// Proxies ASR/TTS requests from the Flutter app to Bhashini (India's
// National Language Translation Mission -- https://bhashini.gov.in), so the
// Bhashini account credentials (BHASHINI_USER_ID / BHASHINI_API_KEY) live
// only as server-side secrets here and never ship inside the Flutter client.
//
// Deploy: supabase functions deploy bhashini-voice
// Configure secrets once (values come from https://dashboard.bhashini.co.in
// after registration/approval):
//   supabase secrets set BHASHINI_USER_ID=xxx BHASHINI_API_KEY=xxx
//
// Called by lib/services/voice_service.dart via
// Supabase.instance.client.functions.invoke('bhashini-voice', body: {...}),
// which already carries the caller's Supabase auth JWT -- this function
// requires that (verify_jwt stays on, the default), so only a signed-in
// caregiver's session (active for the whole app, including Patient Mode --
// see patient_provider.dart) can reach it.
//
// Request body: { action: 'asr'|'tts', language: 'as'|'mni', ...}
//   asr: audioBase64 (WAV, 16kHz mono)      -> response: { transcript }
//   tts: text                                -> response: { audioBase64, audioFormat }

const BHASHINI_USER_ID = Deno.env.get('BHASHINI_USER_ID');
const BHASHINI_API_KEY = Deno.env.get('BHASHINI_API_KEY');

const ULCA_CONFIG_URL =
  'https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline';
// The publicly-documented default Bhashini pipeline covering ASR+Translation+TTS
// across the languages this app needs; overridable via secret if the
// project's dashboard account is issued a different one.
const PIPELINE_ID = Deno.env.get('BHASHINI_PIPELINE_ID') ?? '64392f96daac500b55c543cd';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

interface PipelineConfig {
  serviceId: string;
  callbackUrl: string;
  authHeaderName: string;
  authHeaderValue: string;
}

async function getPipelineConfig(
  taskType: 'asr' | 'tts',
  sourceLanguage: string,
): Promise<PipelineConfig> {
  const res = await fetch(ULCA_CONFIG_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      userID: BHASHINI_USER_ID!,
      ulcaApiKey: BHASHINI_API_KEY!,
    },
    body: JSON.stringify({
      pipelineTasks: [{ taskType, config: { language: { sourceLanguage } } }],
      pipelineRequestConfig: { pipelineId: PIPELINE_ID },
    }),
  });
  if (!res.ok) {
    throw new Error(`pipeline config call failed: ${res.status} ${await res.text()}`);
  }
  const json = await res.json();

  const taskConfig = (json.pipelineResponseConfig ?? []).find(
    (t: { taskType: string }) => t.taskType === taskType,
  );
  const serviceId = taskConfig?.config?.[0]?.serviceId;
  const endpoint = json.pipelineInferenceAPIEndPoint;
  const callbackUrl = endpoint?.callbackUrl;
  const authHeaderName = endpoint?.inferenceApiKey?.name ?? 'Authorization';
  const authHeaderValue = endpoint?.inferenceApiKey?.value;

  if (!serviceId || !callbackUrl || !authHeaderValue) {
    throw new Error(
      `pipeline config response missing expected fields: ${JSON.stringify(json)}`,
    );
  }
  return { serviceId, callbackUrl, authHeaderName, authHeaderValue };
}

async function runAsr(language: string, audioBase64: string): Promise<string> {
  const { serviceId, callbackUrl, authHeaderName, authHeaderValue } =
    await getPipelineConfig('asr', language);

  const res = await fetch(callbackUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', [authHeaderName]: authHeaderValue },
    body: JSON.stringify({
      pipelineTasks: [
        {
          taskType: 'asr',
          config: {
            language: { sourceLanguage: language },
            serviceId,
            audioFormat: 'wav',
            samplingRate: 16000,
          },
        },
      ],
      inputData: { audio: [{ audioContent: audioBase64 }] },
    }),
  });
  if (!res.ok) {
    throw new Error(`asr compute call failed: ${res.status} ${await res.text()}`);
  }
  const json = await res.json();
  return json.pipelineResponse?.[0]?.output?.[0]?.source ?? '';
}

async function runTts(
  language: string,
  text: string,
): Promise<{ audioBase64: string; audioFormat: string }> {
  const { serviceId, callbackUrl, authHeaderName, authHeaderValue } =
    await getPipelineConfig('tts', language);

  const res = await fetch(callbackUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', [authHeaderName]: authHeaderValue },
    body: JSON.stringify({
      pipelineTasks: [
        {
          taskType: 'tts',
          config: {
            language: { sourceLanguage: language },
            serviceId,
            gender: 'female',
            samplingRate: 22050,
          },
        },
      ],
      inputData: { input: [{ source: text }] },
    }),
  });
  if (!res.ok) {
    throw new Error(`tts compute call failed: ${res.status} ${await res.text()}`);
  }
  const json = await res.json();
  const taskOutput = json.pipelineResponse?.[0];
  return {
    audioBase64: taskOutput?.audio?.[0]?.audioContent ?? '',
    audioFormat: taskOutput?.config?.audioFormat ?? 'wav',
  };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { headers: corsHeaders });

  if (!BHASHINI_USER_ID || !BHASHINI_API_KEY) {
    return jsonResponse({ error: 'Bhashini credentials not configured' }, 500);
  }

  try {
    const body = await req.json();
    const action = body.action as string;
    const language = body.language as string;

    if (action === 'asr') {
      const transcript = await runAsr(language, body.audioBase64 as string);
      return jsonResponse({ transcript });
    } else if (action === 'tts') {
      const result = await runTts(language, body.text as string);
      return jsonResponse(result);
    }
    return jsonResponse({ error: `unknown action: ${action}` }, 400);
  } catch (e) {
    console.error('bhashini-voice error:', e);
    return jsonResponse({ error: String(e) }, 502);
  }
});
