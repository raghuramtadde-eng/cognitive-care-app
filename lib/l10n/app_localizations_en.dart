// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String helloName(Object name) {
    return 'Hello, $name';
  }

  @override
  String get exitPatientMode => 'Exit Patient Mode';

  @override
  String get gameMemoryMatch => 'Memory Match';

  @override
  String get gameSequenceRecall => 'Sequence Recall';

  @override
  String get gameSpotChange => 'Spot the Change';

  @override
  String get dailyRoutine => 'Daily Routine';

  @override
  String get memoryLane => 'Memory Lane';

  @override
  String get backToRoleSelection => 'Back to role selection';

  @override
  String get patientLoginTitle => 'Patient Mode';

  @override
  String get patientUserIdFieldLabel => 'Patient User ID';

  @override
  String get incorrectPatientLoginError => 'Incorrect User ID or password';

  @override
  String get rememberThisDeviceLabel => 'Remember this device';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get whatIsIt => 'What is it?';

  @override
  String get time => 'Time';

  @override
  String get saveReminder => 'Save Reminder';

  @override
  String get noRemindersYet =>
      'No reminders yet.\nTap \"Add Reminder\" to set up medicine, water, activity or appointment times.';

  @override
  String get statusDone => 'Done';

  @override
  String get statusMissed => 'Missed';

  @override
  String get routineTypeMedicine => 'Medicine';

  @override
  String get routineTypeHydration => 'Hydration';

  @override
  String get routineTypeActivity => 'Activity';

  @override
  String get routineTypeAppointment => 'Appointment';

  @override
  String reminderNotificationTitle(Object type) {
    return '$type reminder';
  }

  @override
  String get noMemoriesYetPatient =>
      'No memories added yet.\nAsk your caregiver to add some family photos.';

  @override
  String get whoIsThis => 'Who is this?';

  @override
  String get rememberedCorrectly => 'You remembered! 🌟';

  @override
  String get thisIsWhoItIs => 'This is who it is 💛';

  @override
  String get playTheSong => 'Play the song';

  @override
  String get playingSong => 'Playing…';

  @override
  String get iWouldRatherJustSeeIt => 'I\'d rather just see it';

  @override
  String memoryMatchLevel(Object level) {
    return 'Memory Match • Level $level';
  }

  @override
  String matchedPairs(Object matched, Object total) {
    return 'Matched $matched of $total pairs';
  }

  @override
  String get readyStartMatching => 'I\'m Ready — Start Matching';

  @override
  String get memorizeCardsPrompt => 'Take your time to memorize the cards.';

  @override
  String get tapWhenReady => 'Tap the button below whenever you feel ready.';

  @override
  String sequenceRecallLevel(Object level) {
    return 'Sequence Recall • Level $level';
  }

  @override
  String get watchThePattern => 'Watch the pattern...';

  @override
  String yourTurnTap(Object current, Object total) {
    return 'Your turn — tap $current of $total';
  }

  @override
  String spotChangeLevel(Object level) {
    return 'Spot the Change • Level $level';
  }

  @override
  String get memorizePicturePrompt => 'Take your time to memorize the picture.';

  @override
  String get getReady => 'Get ready...';

  @override
  String whichOneChanged(Object trial, Object total) {
    return 'Which one changed? ($trial of $total)';
  }

  @override
  String get correctExclaim => 'Correct!';

  @override
  String get thatsNotIt => 'That\'s not it';

  @override
  String get imReady => 'I\'m Ready';

  @override
  String roundComplete(Object gameName) {
    return '$gameName • Round complete';
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
  String get difficultyIncreased => 'Difficulty increased! 🎉';

  @override
  String get difficultyDecreased => 'Difficulty adjusted down a little';

  @override
  String get difficultySame => 'Difficulty stays the same';

  @override
  String get playAgain => 'Play Again';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get reasonAccuracyLow =>
      'Accuracy below 40% — lowering difficulty immediately.';

  @override
  String get reasonExcellentRound =>
      'Excellent round (accuracy ≥95%, fast) — raising difficulty.';

  @override
  String get reasonTwoStrongRounds =>
      'Two consecutive strong rounds — raising difficulty.';

  @override
  String get reasonGoodRound =>
      'Good round — one more like this raises difficulty.';

  @override
  String get reasonTwoWeakRounds =>
      'Two consecutive weak rounds — lowering difficulty.';

  @override
  String get reasonBelowTargetRound =>
      'Below-target round — one more like this lowers difficulty.';

  @override
  String get reasonSteadyPerformance =>
      'Steady performance — holding difficulty.';

  @override
  String get recallCheckIn => 'Recall Check-in';

  @override
  String get recallPromptQuestion => 'Did you do this today?';

  @override
  String get recallYes => 'Yes, I did';

  @override
  String get recallNo => 'No, not yet';

  @override
  String get recallNotSure => 'I don\'t remember';

  @override
  String get recallFeedbackCorrectDone => 'That\'s right — you did! 🌟';

  @override
  String get recallFeedbackGentleCorrectionDone =>
      'Actually, you did do this earlier today 💛';

  @override
  String get recallFeedbackAcknowledgeNotDone =>
      'Thanks for letting us know 💛';

  @override
  String get recallOfferMarkDone => 'Would you like to mark it done now?';

  @override
  String get markDoneNow => 'Mark done now';

  @override
  String get noRecallItemsYet =>
      'Nothing to check in on right now.\nCome back after your next reminder time.';

  @override
  String get recallNext => 'Next';

  @override
  String get appTitle => 'Cognitive Care';

  @override
  String get whoIsUsingApp => 'Who is using the app right now?';

  @override
  String get roleCaregiver => 'Caregiver';

  @override
  String get roleCaregiverSubtitle =>
      'Sign in to manage patients, routines and progress';

  @override
  String get rolePatient => 'Patient';

  @override
  String get rolePatientSubtitle =>
      'Enter your User ID and password to play and use your routine';

  @override
  String get deviceNotSetUpMessage =>
      'This device hasn\'t been set up yet.\nAsk your caregiver to sign in and add a patient profile first.';

  @override
  String get backButton => 'Back';

  @override
  String get changeLanguage => 'Language';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailValidatorError => 'Enter a valid email';

  @override
  String get passwordValidatorError => 'Enter your password';

  @override
  String get caregiverSignInSubtitle => 'Caregiver sign in';

  @override
  String get logInButton => 'Log In';

  @override
  String get newCaregiverCreateAccount => 'New caregiver? Create an account';

  @override
  String get createCaregiverAccountTitle => 'Create Caregiver Account';

  @override
  String get yourNameLabel => 'Your name';

  @override
  String get enterYourNameError => 'Enter your name';

  @override
  String get atLeast6CharsError => 'At least 6 characters';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get checkEmailMessage =>
      'Check your email to confirm your account, then come back and log in.';

  @override
  String get backToLogIn => 'Back to Log In';

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
      'See the patient\'s game scores, difficulty trend and routine adherence';

  @override
  String get manageDailyRoutineTitle => 'Manage Daily Routine';

  @override
  String get manageDailyRoutineSubtitle =>
      'Set medicine, hydration, activity and appointment reminders';

  @override
  String get manageMemoryLaneTitle => 'Manage Memory Lane';

  @override
  String get manageMemoryLaneSubtitle =>
      'Add family photos, stories, and favorite songs';

  @override
  String get patientsTitle => 'Patients';

  @override
  String get patientsSubtitle => 'Add a patient profile or manage their login';

  @override
  String get addPatientButton => 'Add Patient';

  @override
  String ageValueLabel(Object age) {
    return 'Age $age';
  }

  @override
  String get activeChip => 'Active';

  @override
  String get switchToButton => 'Switch to';

  @override
  String get setUpPatientProfileTitle => 'Set Up Patient Profile';

  @override
  String get welcomeHeading => 'Welcome';

  @override
  String get welcomeSubtitle =>
      'Let\'s set up the patient\'s profile to get started.';

  @override
  String get patientsNameLabel => 'Patient\'s name';

  @override
  String get pleaseEnterNameError => 'Please enter a name';

  @override
  String get ageFieldLabel => 'Age';

  @override
  String get enterValidAgeError => 'Enter a valid age';

  @override
  String get preferredLanguageLabel => 'Preferred language';

  @override
  String get culturalThemeLabel => 'Familiar/cultural theme for game content';

  @override
  String get culturalThemeExplanation =>
      'This only changes which everyday objects show up in the games at higher levels — not the app language.';

  @override
  String get themeGeneralNer => 'General NER';

  @override
  String get themeAssam => 'Assam';

  @override
  String get themeManipur => 'Manipur';

  @override
  String get setPatientCredentialsLabel =>
      'Set a Patient User ID and password for Patient view';

  @override
  String credentialHandoffExplanation(Object name) {
    return '$name will use these to log in on this device.';
  }

  @override
  String get defaultPatientWord => 'the patient';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get enterValidUserIdError =>
      'Choose a User ID: lowercase letters, numbers or underscore, at least 3 characters';

  @override
  String get passwordTooShortError => 'At least 4 characters';

  @override
  String get passwordsDoNotMatchError => 'Passwords do not match';

  @override
  String get userIdAlreadyTakenError =>
      'This User ID is already taken. Please choose another.';

  @override
  String get continueButton => 'Continue';

  @override
  String get addAMemoryButton => 'Add a memory';

  @override
  String get noMemoriesAddedCaregiver =>
      'No memories added yet.\nAdd a family photo, a place, and a short story to get started.';

  @override
  String get removeMemoryQuestionTitle => 'Remove this memory?';

  @override
  String removeMemoryConfirm(Object title) {
    return '\"$title\" will be removed for good.';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get removeButton => 'Remove';

  @override
  String get tellUsAboutMemoryTitle => 'Tell us about this memory';

  @override
  String get whoIsThisRequiredLabel => 'Who is this? *';

  @override
  String get placeOptionalLabel => 'Place (optional)';

  @override
  String get whenWasThisOptional => 'When was this? (optional)';

  @override
  String get shortStoryOptionalLabel => 'A short story (optional)';

  @override
  String get attachFavoriteSongOptional => 'Attach a favorite song (optional)';

  @override
  String get saveButton => 'Save';

  @override
  String get closeButton => 'Close';

  @override
  String viewedTimes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Viewed $count times',
      one: 'Viewed $count time',
    );
    return '$_temp0';
  }

  @override
  String recognizedCountSuffix(Object recognized, Object presented) {
    return 'recognized $recognized/$presented times';
  }

  @override
  String progressTitle(Object name) {
    return '$name\'s Progress';
  }

  @override
  String levelValueLabel(Object level) {
    return 'Level $level';
  }

  @override
  String roundsLoggedLabel(Object count) {
    return '$count rounds logged';
  }

  @override
  String get accuracyTrendSuffix => 'accuracy trend';

  @override
  String get noRoundsPlayedYet => 'No rounds played yet.';

  @override
  String nowLevelLabel(Object level) {
    return 'Now: Level $level';
  }

  @override
  String get routineAdherenceTitle => 'Routine Adherence — last 7 days';

  @override
  String completedMissedLabel(Object done, Object missed) {
    return '$done completed • $missed missed';
  }

  @override
  String get alertsTitle => 'Alerts';

  @override
  String alertsTitleWithCount(Object count) {
    return 'Alerts ($count new)';
  }

  @override
  String get markReadButton => 'Mark read';

  @override
  String get recallAccuracyTitle => 'Recall Check-in accuracy — last 7 days';

  @override
  String get recallAccuracyExplanation =>
      'How often the patient\'s own memory of doing a routine task matched what was actually logged.';

  @override
  String get noRecallCheckinsYet => 'No recall check-ins answered yet.';

  @override
  String recallStatsLabel(Object correct, Object mismatched, Object total) {
    return '$correct matched • $mismatched mismatched • $total check-ins answered';
  }

  @override
  String get recentMismatchesTitle => 'Recent mismatches';

  @override
  String mismatchLine(Object date, Object title, Object status) {
    return '$date — $title (actually: $status)';
  }

  @override
  String get statusNotDoneWord => 'Not done';

  @override
  String get memoryLaneEngagementTitle => 'Memory Lane engagement';

  @override
  String get memoryLaneEngagementSubtitle =>
      'A gentle reminiscence feature, not a cognitive test — these are just engagement signals.';

  @override
  String get memoriesStatLabel => 'Memories';

  @override
  String get viewsStatLabel => 'Views';

  @override
  String get recognizedStatLabel => 'Recognized';

  @override
  String get recentSessionHistoryTitle => 'Recent session history';

  @override
  String get noSessionsYet => 'No sessions yet.';

  @override
  String accuracyAvgLabel(Object accuracy, Object ms) {
    return '$accuracy% accuracy • ${ms}ms avg';
  }

  @override
  String ptsLabel(Object score) {
    return '$score pts';
  }

  @override
  String get choosePatientTitle => 'Choose a patient';

  @override
  String get choosePatientSubtitle => 'Select who you\'re managing right now.';
}
