// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Assamese (`as`).
class AppLocalizationsAs extends AppLocalizations {
  AppLocalizationsAs([String locale = 'as']) : super(locale);

  @override
  String helloName(Object name) {
    return 'নমস্কাৰ, $name';
  }

  @override
  String get exitPatientMode => 'ৰোগীৰ মোড ত্যাগ কৰক';

  @override
  String get gameMemoryMatch => 'স্মৃতি মিলন';

  @override
  String get gameSequenceRecall => 'ক্ৰম স্মৰণ';

  @override
  String get gameSpotChange => 'সলনি বিচাৰক';

  @override
  String get dailyRoutine => 'দৈনন্দিন কাৰ্যসূচী';

  @override
  String get memoryLane => 'স্মৃতিৰ পথ';

  @override
  String get backToRoleSelection => 'ভূমিকা বাছনিলৈ উভতি যাওক';

  @override
  String get patientLoginTitle => 'ৰোগী মোড';

  @override
  String get patientUserIdFieldLabel => 'ৰোগীৰ ব্যৱহাৰকাৰী আইডি';

  @override
  String get incorrectPatientLoginError => 'ভুল ব্যৱহাৰকাৰী আইডি বা পাছৱৰ্ড';

  @override
  String get rememberThisDeviceLabel => 'এই ডিভাইচটো মনত ৰাখক';

  @override
  String get addReminder => 'মনত পেলোৱা যোগ কৰক';

  @override
  String get whatIsIt => 'এইটো কি?';

  @override
  String get time => 'সময়';

  @override
  String get saveReminder => 'মনত পেলোৱা ছেভ কৰক';

  @override
  String get noRemindersYet =>
      'এতিয়ালৈকে কোনো মনত পেলোৱা নাই।\n\"মনত পেলোৱা যোগ কৰক\" টিপি ঔষধ, পানী, কাম বা সাক্ষাৎৰ সময় ঠিক কৰক।';

  @override
  String get statusDone => 'কৰা হ\'ল';

  @override
  String get statusMissed => 'বাদ পৰিল';

  @override
  String get routineTypeMedicine => 'ঔষধ';

  @override
  String get routineTypeHydration => 'পানী পান';

  @override
  String get routineTypeActivity => 'কাম-কাজ';

  @override
  String get routineTypeAppointment => 'সাক্ষাৎ';

  @override
  String reminderNotificationTitle(Object type) {
    return '$type মনত পেলোৱা';
  }

  @override
  String get noMemoriesYetPatient =>
      'এতিয়ালৈকে কোনো স্মৃতি যোগ কৰা হোৱা নাই।\nআপোনাৰ চোৱাচিতা কৰা লোকক পৰিয়ালৰ কেইখনমান ফটো যোগ কৰিবলৈ কওক।';

  @override
  String get whoIsThis => 'এওঁ কোন?';

  @override
  String get rememberedCorrectly => 'আপুনি মনত ৰাখিছে! 🌟';

  @override
  String get thisIsWhoItIs => 'এওঁ হৈছে 💛';

  @override
  String get playTheSong => 'গীত বজাওক';

  @override
  String get playingSong => 'বাজি আছে…';

  @override
  String get iWouldRatherJustSeeIt => 'মই কেৱল চাব বিচাৰো';

  @override
  String memoryMatchLevel(Object level) {
    return 'স্মৃতি মিলন • স্তৰ $level';
  }

  @override
  String matchedPairs(Object matched, Object total) {
    return '$total ৰ ভিতৰত $matched যোৰা মিলিল';
  }

  @override
  String get readyStartMatching => 'মই সাজু — মিলোৱা আৰম্ভ কৰক';

  @override
  String get memorizeCardsPrompt => 'কাৰ্ডবোৰ মনত ৰাখিবলৈ সময় লওক।';

  @override
  String get tapWhenReady => 'সাজু অনুভৱ কৰিলে তলৰ বুটামটো টিপক।';

  @override
  String sequenceRecallLevel(Object level) {
    return 'ক্ৰম স্মৰণ • স্তৰ $level';
  }

  @override
  String get watchThePattern => 'আকৃতিটো চাওক...';

  @override
  String yourTurnTap(Object current, Object total) {
    return 'আপোনাৰ পাল — $total ৰ $current টিপক';
  }

  @override
  String spotChangeLevel(Object level) {
    return 'সলনি বিচাৰক • স্তৰ $level';
  }

  @override
  String get memorizePicturePrompt => 'ছবিখন মনত ৰাখিবলৈ সময় লওক।';

  @override
  String get getReady => 'সাজু হওক...';

  @override
  String whichOneChanged(Object trial, Object total) {
    return 'কোনটো সলনি হ\'ল? ($total ৰ $trial)';
  }

  @override
  String get correctExclaim => 'শুদ্ধ!';

  @override
  String get thatsNotIt => 'এইটো নহয়';

  @override
  String get imReady => 'মই সাজু';

  @override
  String roundComplete(Object gameName) {
    return '$gameName • ৰাউণ্ড সম্পূৰ্ণ';
  }

  @override
  String scoreLabel(Object score) {
    return 'নম্বৰ: $score';
  }

  @override
  String accuracyLabel(Object percent) {
    return 'সঠিকতা: $percent%';
  }

  @override
  String get difficultyIncreased => 'কঠিনতা বাঢ়িল! 🎉';

  @override
  String get difficultyDecreased => 'কঠিনতা অলপ কমোৱা হ\'ল';

  @override
  String get difficultySame => 'কঠিনতা একে থাকিল';

  @override
  String get playAgain => 'আকৌ খেলক';

  @override
  String get backToHome => 'ঘৰলৈ উভতি যাওক';

  @override
  String get reasonAccuracyLow =>
      'সঠিকতা ৪০%ৰ তলত — লগে লগে কঠিনতা কমোৱা হ\'ল।';

  @override
  String get reasonExcellentRound =>
      'উৎকৃষ্ট ৰাউণ্ড (সঠিকতা ≥৯৫%, দ্ৰুত) — কঠিনতা বঢ়োৱা হ\'ল।';

  @override
  String get reasonTwoStrongRounds =>
      'পৰপৰ দুটা শক্তিশালী ৰাউণ্ড — কঠিনতা বঢ়োৱা হ\'ল।';

  @override
  String get reasonGoodRound => 'ভাল ৰাউণ্ড — ইয়াৰ দৰে আৰু এটাই কঠিনতা বঢ়াব।';

  @override
  String get reasonTwoWeakRounds =>
      'পৰপৰ দুটা দুৰ্বল ৰাউণ্ড — কঠিনতা কমোৱা হ\'ল।';

  @override
  String get reasonBelowTargetRound =>
      'লক্ষ্যৰ তলৰ ৰাউণ্ড — ইয়াৰ দৰে আৰু এটাই কঠিনতা কমাব।';

  @override
  String get reasonSteadyPerformance => 'স্থিৰ পৰিৱেশন — কঠিনতা একে ৰখা হ\'ল।';

  @override
  String get recallCheckIn => 'দৈনন্দিন স্মৰণ';

  @override
  String get recallPromptQuestion => 'আপুনি আজি এইটো কৰিছিলনে?';

  @override
  String get recallYes => 'হয়, মই কৰিছিলো';

  @override
  String get recallNo => 'নাই, এতিয়াও নাই';

  @override
  String get recallNotSure => 'মোৰ মনত নাই';

  @override
  String get recallFeedbackCorrectDone => 'শুদ্ধ — আপুনি কৰিছিল! 🌟';

  @override
  String get recallFeedbackGentleCorrectionDone =>
      'প্ৰকৃততে, আপুনি আজি আগতেই এইটো কৰিছিল 💛';

  @override
  String get recallFeedbackAcknowledgeNotDone => 'জনোৱাৰ বাবে ধন্যবাদ 💛';

  @override
  String get recallOfferMarkDone =>
      'আপুনি এতিয়া এইটো কৰা হ\'ল বুলি চিহ্নিত কৰিব বিচাৰেনে?';

  @override
  String get markDoneNow => 'এতিয়াই কৰা হ\'ল বুলি চিহ্নিত কৰক';

  @override
  String get noRecallItemsYet =>
      'এতিয়া পৰীক্ষা কৰিবলৈ একো নাই।\nআপোনাৰ পৰৱৰ্তী মনত পেলোৱাৰ সময়ৰ পিছত পুনৰ আহক।';

  @override
  String get recallNext => 'পৰৱৰ্তী';

  @override
  String get appTitle => 'Cognitive Care';

  @override
  String get whoIsUsingApp => 'এতিয়া এপ্‌টো কোনে ব্যৱহাৰ কৰি আছে?';

  @override
  String get roleCaregiver => 'যত্নকাৰী';

  @override
  String get roleCaregiverSubtitle =>
      'ৰোগী, নিয়মাৱলী আৰু অগ্ৰগতি চোৱাচিতা কৰিবলৈ ছাইন ইন কৰক';

  @override
  String get rolePatient => 'ৰোগী';

  @override
  String get rolePatientSubtitle =>
      'খেলিবলৈ আৰু আপোনাৰ নিয়মাৱলী ব্যৱহাৰ কৰিবলৈ আপোনাৰ ব্যৱহাৰকাৰী আইডি আৰু পাছৱৰ্ড দিয়ক';

  @override
  String get deviceNotSetUpMessage =>
      'এই ডিভাইচটো এতিয়াও ছেট আপ কৰা হোৱা নাই।\nআপোনাৰ যত্নকাৰীক ছাইন ইন কৰি প্ৰথমে ৰোগীৰ প্ৰ\'ফাইল যোগ কৰিবলৈ কওক।';

  @override
  String get backButton => 'পিছলৈ';

  @override
  String get changeLanguage => 'ভাষা';

  @override
  String get emailLabel => 'ইমেইল';

  @override
  String get passwordLabel => 'পাছৱৰ্ড';

  @override
  String get emailValidatorError => 'এটা বৈধ ইমেইল দিয়ক';

  @override
  String get passwordValidatorError => 'আপোনাৰ পাছৱৰ্ড দিয়ক';

  @override
  String get caregiverSignInSubtitle => 'যত্নকাৰীৰ ছাইন ইন';

  @override
  String get logInButton => 'লগ ইন';

  @override
  String get newCaregiverCreateAccount =>
      'নতুন যত্নকাৰী? এটা একাউণ্ট সৃষ্টি কৰক';

  @override
  String get createCaregiverAccountTitle => 'যত্নকাৰী একাউণ্ট সৃষ্টি কৰক';

  @override
  String get yourNameLabel => 'আপোনাৰ নাম';

  @override
  String get enterYourNameError => 'আপোনাৰ নাম দিয়ক';

  @override
  String get atLeast6CharsError => 'কমেও ৬টা আখৰ';

  @override
  String get createAccountButton => 'একাউণ্ট সৃষ্টি কৰক';

  @override
  String get checkEmailMessage =>
      'আপোনাৰ একাউণ্ট নিশ্চিত কৰিবলৈ ইমেইল চাওক, তাৰপিছত ঘূৰি আহি লগ ইন কৰক।';

  @override
  String get backToLogIn => 'লগ ইনলৈ ঘূৰি যাওক';

  @override
  String get caregiverDashboardTitle => 'যত্নকাৰী ডেশ্ব\'ৰ্ড';

  @override
  String get signOutTooltip => 'ছাইন আউট';

  @override
  String get languageTooltip => 'ভাষা';

  @override
  String get progressDashboardTitle => 'অগ্ৰগতি ডেশ্ব\'ৰ্ড';

  @override
  String get progressDashboardSubtitle =>
      'ৰোগীৰ খেলৰ স্ক\'ৰ, কঠিনতাৰ প্ৰৱণতা আৰু নিয়মাৱলী মানি চলাটো চাওক';

  @override
  String get manageDailyRoutineTitle => 'দৈনন্দিন কাৰ্যসূচী পৰিচালনা কৰক';

  @override
  String get manageDailyRoutineSubtitle =>
      'ঔষধ, পানী, কাৰ্যকলাপ আৰু সাক্ষাৎকাৰৰ মনত পেলোৱা ছেট কৰক';

  @override
  String get manageMemoryLaneTitle => 'স্মৃতিৰ পথ পৰিচালনা কৰক';

  @override
  String get manageMemoryLaneSubtitle =>
      'পৰিয়ালৰ ফটো, কাহিনী, আৰু প্ৰিয় গীত যোগ কৰক';

  @override
  String get patientsTitle => 'ৰোগীসকল';

  @override
  String get patientsSubtitle =>
      'এটা ৰোগীৰ প্ৰ\'ফাইল যোগ কৰক বা তেওঁলোকৰ লগ ইন পৰিচালনা কৰক';

  @override
  String get addPatientButton => 'ৰোগী যোগ কৰক';

  @override
  String ageValueLabel(Object age) {
    return 'বয়স $age';
  }

  @override
  String get activeChip => 'সক্ৰিয়';

  @override
  String get switchToButton => 'সলনি কৰক';

  @override
  String get setUpPatientProfileTitle => 'ৰোগীৰ প্ৰ\'ফাইল ছেট আপ কৰক';

  @override
  String get welcomeHeading => 'স্বাগতম';

  @override
  String get welcomeSubtitle => 'আৰম্ভ কৰিবলৈ ৰোগীৰ প্ৰ\'ফাইল ছেট আপ কৰোঁ আহক।';

  @override
  String get patientsNameLabel => 'ৰোগীৰ নাম';

  @override
  String get pleaseEnterNameError => 'অনুগ্ৰহ কৰি এটা নাম দিয়ক';

  @override
  String get ageFieldLabel => 'বয়স';

  @override
  String get enterValidAgeError => 'এটা বৈধ বয়স দিয়ক';

  @override
  String get preferredLanguageLabel => 'পচন্দৰ ভাষা';

  @override
  String get culturalThemeLabel =>
      'খেলৰ বিষয়বস্তুৰ বাবে পৰিচিত/সাংস্কৃতিক থীম';

  @override
  String get culturalThemeExplanation =>
      'ই কেৱল উচ্চ স্তৰত খেলত কি কি সাধাৰণ বস্তু দেখা যাব সেয়াহে সলনি কৰে — এপ্‌ৰ ভাষা নহয়।';

  @override
  String get themeGeneralNer => 'সাধাৰণ NER';

  @override
  String get themeAssam => 'অসম';

  @override
  String get themeManipur => 'মণিপুৰ';

  @override
  String get setPatientCredentialsLabel =>
      'ৰোগী দৰ্শনৰ বাবে এটা ব্যৱহাৰকাৰী আইডি আৰু পাছৱৰ্ড ছেট কৰক';

  @override
  String credentialHandoffExplanation(Object name) {
    return 'যেতিয়াই আপুনি $nameক ডিভাইচটো দিব তেতিয়া তেওঁ এইবোৰ ব্যৱহাৰ কৰি লগ ইন কৰিব।';
  }

  @override
  String get defaultPatientWord => 'ৰোগীজন';

  @override
  String get confirmPasswordLabel => 'পাছৱৰ্ড নিশ্চিত কৰক';

  @override
  String get enterValidUserIdError =>
      'এটা ব্যৱহাৰকাৰী আইডি বাছক: সৰু আখৰ, সংখ্যা বা আণ্ডাৰস্কোৰ, কমেও ৩টা আখৰ';

  @override
  String get passwordTooShortError => 'কমেও ৪টা আখৰ';

  @override
  String get passwordsDoNotMatchError => 'পাছৱৰ্ড মিল নাখালে';

  @override
  String get userIdAlreadyTakenError =>
      'এই ব্যৱহাৰকাৰী আইডিটো ইতিমধ্যে ব্যৱহাৰ কৰা হৈছে। অনুগ্ৰহ কৰি বেলেগ এটা বাছনি কৰক।';

  @override
  String get continueButton => 'আগবাঢ়ক';

  @override
  String get addAMemoryButton => 'এটা স্মৃতি যোগ কৰক';

  @override
  String get noMemoriesAddedCaregiver =>
      'এতিয়াও কোনো স্মৃতি যোগ কৰা হোৱা নাই।\nআৰম্ভ কৰিবলৈ এখন পৰিয়ালৰ ফটো, এখন ঠাই, আৰু এটা চুটি কাহিনী যোগ কৰক।';

  @override
  String get removeMemoryQuestionTitle => 'এই স্মৃতিটো আঁতৰাব নেকি?';

  @override
  String removeMemoryConfirm(Object title) {
    return '\"$title\" চিৰদিনৰ বাবে আঁতৰোৱা হ\'ব।';
  }

  @override
  String get cancelButton => 'বাতিল কৰক';

  @override
  String get removeButton => 'আঁতৰাওক';

  @override
  String get tellUsAboutMemoryTitle => 'এই স্মৃতিটোৰ বিষয়ে আমাক কওক';

  @override
  String get whoIsThisRequiredLabel => 'এওঁ কোন? *';

  @override
  String get placeOptionalLabel => 'ঠাই (বৈকল্পিক)';

  @override
  String get whenWasThisOptional => 'এইটো কেতিয়া হৈছিল? (বৈকল্পিক)';

  @override
  String get shortStoryOptionalLabel => 'এটা চুটি কাহিনী (বৈকল্পিক)';

  @override
  String get attachFavoriteSongOptional =>
      'এটা প্ৰিয় গীত সংলগ্ন কৰক (বৈকল্পিক)';

  @override
  String get saveButton => 'ছেভ কৰক';

  @override
  String get closeButton => 'বন্ধ কৰক';

  @override
  String viewedTimes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count বাৰ চোৱা হৈছে',
      one: '$count বাৰ চোৱা হৈছে',
    );
    return '$_temp0';
  }

  @override
  String recognizedCountSuffix(Object recognized, Object presented) {
    return '$recognized/$presented বাৰ চিনি পোৱা গৈছে';
  }

  @override
  String progressTitle(Object name) {
    return '$nameৰ অগ্ৰগতি';
  }

  @override
  String levelValueLabel(Object level) {
    return 'স্তৰ $level';
  }

  @override
  String roundsLoggedLabel(Object count) {
    return '$countটা ৰাউণ্ড লগ কৰা হৈছে';
  }

  @override
  String get accuracyTrendSuffix => 'সঠিকতাৰ প্ৰৱণতা';

  @override
  String get noRoundsPlayedYet => 'এতিয়াও কোনো ৰাউণ্ড খেলা হোৱা নাই।';

  @override
  String nowLevelLabel(Object level) {
    return 'এতিয়া: স্তৰ $level';
  }

  @override
  String get routineAdherenceTitle => 'নিয়মাৱলী মানি চলা — যোৱা ৭ দিন';

  @override
  String completedMissedLabel(Object done, Object missed) {
    return '$doneটা সম্পূৰ্ণ • $missedটা এৰি থোৱা হৈছে';
  }

  @override
  String get alertsTitle => 'সতৰ্কবাণী';

  @override
  String alertsTitleWithCount(Object count) {
    return 'সতৰ্কবাণী ($countটা নতুন)';
  }

  @override
  String get markReadButton => 'পঢ়া বুলি চিহ্নিত কৰক';

  @override
  String get recallAccuracyTitle => 'স্মৰণ চেক-ইনৰ সঠিকতা — যোৱা ৭ দিন';

  @override
  String get recallAccuracyExplanation =>
      'ৰোগীয়ে নিয়মাৱলীৰ কাম কৰাৰ নিজৰ স্মৃতি প্ৰকৃততে লগ কৰাৰ সৈতে কিমানবাৰ মিলিছিল।';

  @override
  String get noRecallCheckinsYet =>
      'এতিয়াও কোনো স্মৰণ চেক-ইনৰ উত্তৰ দিয়া হোৱা নাই।';

  @override
  String recallStatsLabel(Object correct, Object mismatched, Object total) {
    return '$correctটা মিলিছে • $mismatchedটা মিলা নাই • $totalটা চেক-ইনৰ উত্তৰ দিয়া হৈছে';
  }

  @override
  String get recentMismatchesTitle => 'শেহতীয়া অমিল';

  @override
  String mismatchLine(Object date, Object title, Object status) {
    return '$date — $title (প্ৰকৃততে: $status)';
  }

  @override
  String get statusNotDoneWord => 'কৰা হোৱা নাই';

  @override
  String get memoryLaneEngagementTitle => 'স্মৃতিৰ পথৰ সম্পৃক্ততা';

  @override
  String get memoryLaneEngagementSubtitle =>
      'এটা কোমল স্মৃতিচাৰণ বৈশিষ্ট্য, কোনো জ্ঞানীয় পৰীক্ষা নহয় — এইবোৰ কেৱল সম্পৃক্ততাৰ সংকেত।';

  @override
  String get memoriesStatLabel => 'স্মৃতিসমূহ';

  @override
  String get viewsStatLabel => 'দৰ্শন';

  @override
  String get recognizedStatLabel => 'চিনি পোৱা গৈছে';

  @override
  String get recentSessionHistoryTitle => 'শেহতীয়া ছেশ্বনৰ ইতিহাস';

  @override
  String get noSessionsYet => 'এতিয়াও কোনো ছেশ্বন নাই।';

  @override
  String accuracyAvgLabel(Object accuracy, Object ms) {
    return '$accuracy% সঠিকতা • গড় ${ms}ms';
  }

  @override
  String ptsLabel(Object score) {
    return '$score পইণ্ট';
  }

  @override
  String get choosePatientTitle => 'এজন ৰোগী বাছনি কৰক';

  @override
  String get choosePatientSubtitle => 'আপুনি এতিয়া কাৰ যত্ন লৈ আছে বাছনি কৰক।';
}
