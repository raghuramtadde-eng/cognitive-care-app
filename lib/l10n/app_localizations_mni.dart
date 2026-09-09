// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Manipuri (`mni`).
class AppLocalizationsMni extends AppLocalizations {
  AppLocalizationsMni([String locale = 'mni']) : super(locale);

  @override
  String helloName(Object name) {
    return 'খুরুমজরি, $name';
  }

  @override
  String get exitPatientMode => 'Patient Mode থাদোকপা';

  @override
  String get gameMemoryMatch => 'Memory Match';

  @override
  String get gameSequenceRecall => 'Sequence Recall';

  @override
  String get gameSpotChange => 'Spot the Change';

  @override
  String get dailyRoutine => 'নুমিৎ খুদিংগী থবক';

  @override
  String get memoryLane => 'Memory Lane';

  @override
  String get backToRoleSelection => 'Role সিলেক্সনদা হাল্লক্কো';

  @override
  String get patientLoginTitle => 'Patient Mode';

  @override
  String get patientUserIdFieldLabel => 'Patient User ID';

  @override
  String get incorrectPatientLoginError => 'User ID nattraga password অসোই';

  @override
  String get rememberThisDeviceLabel => 'Device অসি নিংশিংবিয়ু';

  @override
  String get addReminder => 'Reminder হাপচিনবা';

  @override
  String get whatIsIt => 'মসি করিনো?';

  @override
  String get time => 'মতম';

  @override
  String get saveReminder => 'Reminder সেভ তৌবা';

  @override
  String get noRemindersYet =>
      'হৌজিক ফাওবা reminder লৈতে।\n\"Reminder হাপচিনবা\" তেপ তৌরগা ঔষধ, ঈশিং, থবক নত্রগা appointment-গী মতম শেম্মু।';

  @override
  String get statusDone => 'লৈরে';

  @override
  String get statusMissed => 'চাতনখ্রে';

  @override
  String get routineTypeMedicine => 'ঔষধ';

  @override
  String get routineTypeHydration => 'ঈশিং থাকপা';

  @override
  String get routineTypeActivity => 'থবক';

  @override
  String get routineTypeAppointment => 'Appointment';

  @override
  String reminderNotificationTitle(Object type) {
    return '$type Reminder';
  }

  @override
  String get noMemoriesYetPatient =>
      'হৌজিক memory হাপচিনদ্রে।\nনহাক্কী caregiver-দা family photo হাপচিনবা হায়বিয়ু।';

  @override
  String get whoIsThis => 'মসি কনানো?';

  @override
  String get rememberedCorrectly => 'নহাক্না নিংশিংখ্রে! 🌟';

  @override
  String get thisIsWhoItIs => 'মসি অসিনি 💛';

  @override
  String get playTheSong => 'ইশৈ থাদবা';

  @override
  String get playingSong => 'থাদরি…';

  @override
  String get iWouldRatherJustSeeIt => 'ঐ উবা নত্তনা লৈগনি';

  @override
  String memoryMatchLevel(Object level) {
    return 'Memory Match • Level $level';
  }

  @override
  String matchedPairs(Object matched, Object total) {
    return '$total-গী $matched match তৌরে';
  }

  @override
  String get readyStartMatching => 'ঐ সাজু — Matching হৌদোককো';

  @override
  String get memorizeCardsPrompt => 'Card-শিং নিংশিংনবা মতম লৌবিয়ু।';

  @override
  String get tapWhenReady => 'নহাক সাজু ওইলগা তল্লবা button অদু তেপবিয়ু।';

  @override
  String sequenceRecallLevel(Object level) {
    return 'Sequence Recall • Level $level';
  }

  @override
  String get watchThePattern => 'Pattern অদু য়েংবিয়ু...';

  @override
  String yourTurnTap(Object current, Object total) {
    return 'নহাক্কী পাল — $total-গী $current তেপবিয়ু';
  }

  @override
  String spotChangeLevel(Object level) {
    return 'Spot the Change • Level $level';
  }

  @override
  String get memorizePicturePrompt => 'Picture অদু নিংশিংনবা মতম লৌবিয়ু।';

  @override
  String get getReady => 'সাজু ওইয়ু...';

  @override
  String whichOneChanged(Object trial, Object total) {
    return 'করম্না change তৌরবগে? ($total-গী $trial)';
  }

  @override
  String get correctExclaim => 'চুম্মি!';

  @override
  String get thatsNotIt => 'অসি নত্তে';

  @override
  String get imReady => 'ঐ সাজু';

  @override
  String roundComplete(Object gameName) {
    return '$gameName • Round লোইশিল্লে';
  }

  @override
  String scoreLabel(Object score) {
    return 'Score: $score';
  }

  @override
  String accuracyLabel(Object percent) {
    return 'Accuracy: $percent%';
  }

  @override
  String get difficultyIncreased => 'Difficulty হেনগৎলে! 🎉';

  @override
  String get difficultyDecreased => 'Difficulty খ্রাগৎনা হেন্থোক্লে';

  @override
  String get difficultySame => 'Difficulty মদুমক লৈরি';

  @override
  String get playAgain => 'আমুক হন্না শান্নু';

  @override
  String get backToHome => 'মথোংদা হাল্লক্কো';

  @override
  String get reasonAccuracyLow =>
      'Accuracy 40% হানদবা — অসৃত্তমতমদা difficulty হেন্থোকখ্রে।';

  @override
  String get reasonExcellentRound =>
      'অফবা round (accuracy ≥95%, য়ানবা) — difficulty হেনগৎখ্রে।';

  @override
  String get reasonTwoStrongRounds =>
      'অতোপ্পা round অনি অফবা — difficulty হেনগৎখ্রে।';

  @override
  String get reasonGoodRound =>
      'অফবা round — মসিগুম্বা অমুক অমা oirdi difficulty হেনগনি।';

  @override
  String get reasonTwoWeakRounds =>
      'অতোপ্পা round অনি য়াম্না অফদবা — difficulty হেন্থোকখ্রে।';

  @override
  String get reasonBelowTargetRound =>
      'Target-তা মথোন্তা round — মসিগুম্বা অমুক অমা oirdi difficulty হেন্থোকনি।';

  @override
  String get reasonSteadyPerformance =>
      'মপুং ফানা তৌরিবা — difficulty মদুমক থাম্লে।';

  @override
  String get recallCheckIn => 'নুমিৎ খুদিংগী নিংশিং';

  @override
  String get recallPromptQuestion => 'নহাক্না ঙসি মসি তৌরবরা?';

  @override
  String get recallYes => 'হোয়, ঐনা তৌরে';

  @override
  String get recallNo => 'নত্তে, ফাওবা লৈত্রে';

  @override
  String get recallNotSure => 'ঐগী নিংশিংদে';

  @override
  String get recallFeedbackCorrectDone => 'চুম্মি — নহাক্না তৌরে! 🌟';

  @override
  String get recallFeedbackGentleCorrectionDone =>
      'অসৃত্তমক, নহাক্না ঙসি হানবদা মসি তৌরমখ্রে 💛';

  @override
  String get recallFeedbackAcknowledgeNotDone => 'ফোংদোকপগীদমক থাগৎচরি 💛';

  @override
  String get recallOfferMarkDone => 'হৌজিক মসি তৌরে হায়না মার্ক তৌগনি?';

  @override
  String get markDoneNow => 'হৌজিক তৌরে হায়না মার্ক তৌবা';

  @override
  String get noRecallItemsYet =>
      'হৌজিক check তৌনবা করিসু লৈত্রে।\nনহাক্কী matungda reminder মতমগী মতুংদা লাক্কো।';

  @override
  String get recallNext => 'মথংগী';

  @override
  String get appTitle => 'Cognitive Care';

  @override
  String get whoIsUsingApp => 'হৌজিক এপ্ অসি কনা শিজিন্নরিবগে?';

  @override
  String get roleCaregiver => 'Caregiver';

  @override
  String get roleCaregiverSubtitle =>
      'Patient, routine অমসুং progress মাংনবা sign in তৌবিয়ু';

  @override
  String get rolePatient => 'Patient';

  @override
  String get rolePatientSubtitle =>
      'Game শাননবা অমসুং নহাক্কী routine শিজিন্নবা নহাক্কী User ID অমসুং password adubu চাংশিল্লু';

  @override
  String get deviceNotSetUpMessage =>
      'Device অসি হৌজিক ফাওবা set up তৌদ্রি।\nনহাক্কী caregiver-দা sign in তৌহল্লু অমসুং হান্না patient প্রফাইল অমা হাপচিনবিয়ু।';

  @override
  String get backButton => 'হন্না';

  @override
  String get changeLanguage => 'Language';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailValidatorError => 'Email যাথঙনবা অমা চাংশিল্লু';

  @override
  String get passwordValidatorError => 'নহাক্কী password চাংশিল্লু';

  @override
  String get caregiverSignInSubtitle => 'Caregiver sign in';

  @override
  String get logInButton => 'Log In';

  @override
  String get newCaregiverCreateAccount => 'Caregiver অনৌবা? Account অমা শেম্মু';

  @override
  String get createCaregiverAccountTitle => 'Caregiver Account শেম্মু';

  @override
  String get yourNameLabel => 'নহাক্কী মমিং';

  @override
  String get enterYourNameError => 'নহাক্কী মমিং চাংশিল্লু';

  @override
  String get atLeast6CharsError => 'Character তরুক হেন্না লৈশিল্লু';

  @override
  String get createAccountButton => 'Account শেম্মু';

  @override
  String get checkEmailMessage =>
      'নহাক্কী account confirm তৌনবা email য়েংবিয়ু, মতুংদা হন্না লাক্লগা sign in তৌবিয়ু।';

  @override
  String get backToLogIn => 'Log In-দা হন্না চৎলু';

  @override
  String get caregiverDashboardTitle => 'Caregiver Dashboard';

  @override
  String get signOutTooltip => 'Sign out';

  @override
  String get languageTooltip => 'Language';

  @override
  String get progressDashboardTitle => 'Progress Dashboard';

  @override
  String get progressDashboardSubtitle =>
      'Patient-গী game score, difficulty trend অমসুং routine adherence য়েংবিয়ু';

  @override
  String get manageDailyRoutineTitle => 'নুমিৎ খুদিংগী থবক Manage তৌবিয়ু';

  @override
  String get manageDailyRoutineSubtitle =>
      'Medicine, hydration, activity অমসুং appointment reminder set তৌবিয়ু';

  @override
  String get manageMemoryLaneTitle => 'Memory Lane Manage তৌবিয়ু';

  @override
  String get manageMemoryLaneSubtitle =>
      'Family photo, story, অমসুং favorite song হাপচিনবিয়ু';

  @override
  String get patientsTitle => 'Patient-শিং';

  @override
  String get patientsSubtitle =>
      'Patient profile অমা হাপচিনবিয়ু নত্রগা মখোয়গী login manage তৌবিয়ু';

  @override
  String get addPatientButton => 'Patient হাপচিনবিয়ু';

  @override
  String ageValueLabel(Object age) {
    return 'Age $age';
  }

  @override
  String get activeChip => 'Active';

  @override
  String get switchToButton => 'Switch তৌবিয়ু';

  @override
  String get setUpPatientProfileTitle => 'Patient Profile Set Up তৌবিয়ু';

  @override
  String get welcomeHeading => 'খুরুমজরি';

  @override
  String get welcomeSubtitle => 'চৎনবা হৌজিক patient-গী profile সেট আপ তৌশি।';

  @override
  String get patientsNameLabel => 'Patient-গী মমিং';

  @override
  String get pleaseEnterNameError => 'চানবীদুনা মমিং অমা চাংশিল্লু';

  @override
  String get ageFieldLabel => 'Age';

  @override
  String get enterValidAgeError => 'Age চুম্মবা অমা চাংশিল্লু';

  @override
  String get preferredLanguageLabel => 'নহাক্না পামজবা Language';

  @override
  String get culturalThemeLabel => 'Game content-গী ফমিলিয়ার/cultural theme';

  @override
  String get culturalThemeExplanation =>
      'মসিনা level হেনগৎলগা game-দা উদগদবা লোইনবা পোৎলম খুদিংমক হোংদোক-হোংজিন তৌহল্লি — app-কী language নত্তে।';

  @override
  String get themeGeneralNer => 'General NER';

  @override
  String get themeAssam => 'Assam';

  @override
  String get themeManipur => 'Manipur';

  @override
  String get setPatientCredentialsLabel =>
      'Patient view-গীদমক User ID অমসুং password অমা set তৌবিয়ু';

  @override
  String credentialHandoffExplanation(Object name) {
    return 'Device অদু $name-দা পীবা matam khudingda মসি শিজিন্নগদবনি।';
  }

  @override
  String get defaultPatientWord => 'patient অদু';

  @override
  String get confirmPasswordLabel => 'Password Confirm তৌবিয়ু';

  @override
  String get enterValidUserIdError =>
      'User ID অমা খল্লু: letter khum, number nattraga underscore, at least character ahum';

  @override
  String get passwordTooShortError => 'At least character mari';

  @override
  String get passwordsDoNotMatchError => 'Password অনিমক same নত্তে';

  @override
  String get userIdAlreadyTakenError =>
      'User ID অসি patient অতোপ্পনা শিজিন্নরে। চানবীদুনা User ID অতোপ্পা অমা খল্লু।';

  @override
  String get continueButton => 'Continue';

  @override
  String get addAMemoryButton => 'Memory অমা হাপচিনবিয়ু';

  @override
  String get noMemoriesAddedCaregiver =>
      'হৌজিক ফাওবা memory কোই হাপচিনদ্রি।\nহৌনবা family photo অমা, mapham অমা, অমসুং story চুপ্পা অমা হাপচিনবিয়ু।';

  @override
  String get removeMemoryQuestionTitle => 'Memory অসি লৌথোক্কদ্রা?';

  @override
  String removeMemoryConfirm(Object title) {
    return '\"$title\" matam pumnamakta লৌথোক্কনি।';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get removeButton => 'লৌথোকপিয়ু';

  @override
  String get tellUsAboutMemoryTitle => 'Memory অসিগী মতাংদা এইখোয়দা হায়বিয়ু';

  @override
  String get whoIsThisRequiredLabel => 'মসি কনানো? *';

  @override
  String get placeOptionalLabel => 'Mapham (optional)';

  @override
  String get whenWasThisOptional => 'মসি করম্বা matamda ওইখিবা? (optional)';

  @override
  String get shortStoryOptionalLabel => 'Story চুপ্পা অমা (optional)';

  @override
  String get attachFavoriteSongOptional =>
      'Favorite song অমা attach তৌবিয়ু (optional)';

  @override
  String get saveButton => 'Save তৌবিয়ু';

  @override
  String get closeButton => 'Close তৌবিয়ু';

  @override
  String viewedTimes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count বার view তৌখ্রে',
      one: '$count বার view তৌখ্রে',
    );
    return '$_temp0';
  }

  @override
  String recognizedCountSuffix(Object recognized, Object presented) {
    return '$recognized/$presented বার recognize তৌখ্রে';
  }

  @override
  String progressTitle(Object name) {
    return '$nameগী Progress';
  }

  @override
  String levelValueLabel(Object level) {
    return 'Level $level';
  }

  @override
  String roundsLoggedLabel(Object count) {
    return 'Round $count log তৌখ্রে';
  }

  @override
  String get accuracyTrendSuffix => 'accuracy trend';

  @override
  String get noRoundsPlayedYet => 'হৌজিক ফাওবা round কোই খেলদ্রি।';

  @override
  String nowLevelLabel(Object level) {
    return 'হৌজিক: Level $level';
  }

  @override
  String get routineAdherenceTitle => 'Routine Adherence — নুমিৎ ৭ হেন্না';

  @override
  String completedMissedLabel(Object done, Object missed) {
    return '$done লোইশিন্দুনা • $missed চাত্তুনা';
  }

  @override
  String get alertsTitle => 'Alerts';

  @override
  String alertsTitleWithCount(Object count) {
    return 'Alerts ($count অনৌবা)';
  }

  @override
  String get markReadButton => 'Read তৌখ্রে হায়না Mark তৌবিয়ু';

  @override
  String get recallAccuracyTitle => 'Recall Check-in accuracy — নুমিৎ ৭ হেন্না';

  @override
  String get recallAccuracyExplanation =>
      'Patient-না routine task তৌখ্রবা matangda মখোয়গী নিংশিংবা অদুনা actual-না log তৌখ্রবগা করম্না matching তৌখ্রি।';

  @override
  String get noRecallCheckinsYet =>
      'হৌজিক ফাওবা recall check-in কোই answer তৌদ্রি।';

  @override
  String recallStatsLabel(Object correct, Object mismatched, Object total) {
    return '$correct matching তৌখ্রে • $mismatched matching তৌদ্রে • $total check-in answer তৌখ্রে';
  }

  @override
  String get recentMismatchesTitle => 'Recent mismatches';

  @override
  String mismatchLine(Object date, Object title, Object status) {
    return '$date — $title (actual-না: $status)';
  }

  @override
  String get statusNotDoneWord => 'তৌদ্রে';

  @override
  String get memoryLaneEngagementTitle => 'Memory Lane engagement';

  @override
  String get memoryLaneEngagementSubtitle =>
      'মসি cognitive test নত্তে, engagement signal খক্তনি।';

  @override
  String get memoriesStatLabel => 'Memories';

  @override
  String get viewsStatLabel => 'Views';

  @override
  String get recognizedStatLabel => 'Recognized';

  @override
  String get recentSessionHistoryTitle => 'Recent session history';

  @override
  String get noSessionsYet => 'হৌজিক ফাওবা session কোই লৈত্রে।';

  @override
  String accuracyAvgLabel(Object accuracy, Object ms) {
    return '$accuracy% accuracy • average ${ms}ms';
  }

  @override
  String ptsLabel(Object score) {
    return '$score pts';
  }

  @override
  String get choosePatientTitle => 'Patient অমা খন্নবিয়ু';

  @override
  String get choosePatientSubtitle =>
      'হৌজিক নহাক্না কনাগী কৌশল তৌরিবগে খন্নবিয়ু।';
}
