import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_en.dart';
import 'app_localizations_mni.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('as'),
    Locale('en'),
    Locale('mni'),
  ];

  /// No description provided for @helloName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloName(Object name);

  /// No description provided for @exitPatientMode.
  ///
  /// In en, this message translates to:
  /// **'Exit Patient Mode'**
  String get exitPatientMode;

  /// No description provided for @gameMemoryMatch.
  ///
  /// In en, this message translates to:
  /// **'Memory Match'**
  String get gameMemoryMatch;

  /// No description provided for @gameSequenceRecall.
  ///
  /// In en, this message translates to:
  /// **'Sequence Recall'**
  String get gameSequenceRecall;

  /// No description provided for @gameSpotChange.
  ///
  /// In en, this message translates to:
  /// **'Spot the Change'**
  String get gameSpotChange;

  /// No description provided for @dailyRoutine.
  ///
  /// In en, this message translates to:
  /// **'Daily Routine'**
  String get dailyRoutine;

  /// No description provided for @memoryLane.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane'**
  String get memoryLane;

  /// No description provided for @backToRoleSelection.
  ///
  /// In en, this message translates to:
  /// **'Back to role selection'**
  String get backToRoleSelection;

  /// No description provided for @patientLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient Mode'**
  String get patientLoginTitle;

  /// No description provided for @patientUserIdFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient User ID'**
  String get patientUserIdFieldLabel;

  /// No description provided for @incorrectPatientLoginError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect User ID or password'**
  String get incorrectPatientLoginError;

  /// No description provided for @rememberThisDeviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Remember this device'**
  String get rememberThisDeviceLabel;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @whatIsIt.
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get whatIsIt;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @saveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get saveReminder;

  /// No description provided for @noRemindersYet.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet.\nTap \"Add Reminder\" to set up medicine, water, activity or appointment times.'**
  String get noRemindersYet;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @routineTypeMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get routineTypeMedicine;

  /// No description provided for @routineTypeHydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get routineTypeHydration;

  /// No description provided for @routineTypeActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get routineTypeActivity;

  /// No description provided for @routineTypeAppointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get routineTypeAppointment;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'{type} reminder'**
  String reminderNotificationTitle(Object type);

  /// No description provided for @noMemoriesYetPatient.
  ///
  /// In en, this message translates to:
  /// **'No memories added yet.\nAsk your caregiver to add some family photos.'**
  String get noMemoriesYetPatient;

  /// No description provided for @whoIsThis.
  ///
  /// In en, this message translates to:
  /// **'Who is this?'**
  String get whoIsThis;

  /// No description provided for @rememberedCorrectly.
  ///
  /// In en, this message translates to:
  /// **'You remembered! 🌟'**
  String get rememberedCorrectly;

  /// No description provided for @thisIsWhoItIs.
  ///
  /// In en, this message translates to:
  /// **'This is who it is 💛'**
  String get thisIsWhoItIs;

  /// No description provided for @playTheSong.
  ///
  /// In en, this message translates to:
  /// **'Play the song'**
  String get playTheSong;

  /// No description provided for @playingSong.
  ///
  /// In en, this message translates to:
  /// **'Playing…'**
  String get playingSong;

  /// No description provided for @iWouldRatherJustSeeIt.
  ///
  /// In en, this message translates to:
  /// **'I\'d rather just see it'**
  String get iWouldRatherJustSeeIt;

  /// No description provided for @memoryMatchLevel.
  ///
  /// In en, this message translates to:
  /// **'Memory Match • Level {level}'**
  String memoryMatchLevel(Object level);

  /// No description provided for @matchedPairs.
  ///
  /// In en, this message translates to:
  /// **'Matched {matched} of {total} pairs'**
  String matchedPairs(Object matched, Object total);

  /// No description provided for @readyStartMatching.
  ///
  /// In en, this message translates to:
  /// **'I\'m Ready — Start Matching'**
  String get readyStartMatching;

  /// No description provided for @memorizeCardsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Take your time to memorize the cards.'**
  String get memorizeCardsPrompt;

  /// No description provided for @tapWhenReady.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below whenever you feel ready.'**
  String get tapWhenReady;

  /// No description provided for @sequenceRecallLevel.
  ///
  /// In en, this message translates to:
  /// **'Sequence Recall • Level {level}'**
  String sequenceRecallLevel(Object level);

  /// No description provided for @watchThePattern.
  ///
  /// In en, this message translates to:
  /// **'Watch the pattern...'**
  String get watchThePattern;

  /// No description provided for @yourTurnTap.
  ///
  /// In en, this message translates to:
  /// **'Your turn — tap {current} of {total}'**
  String yourTurnTap(Object current, Object total);

  /// No description provided for @spotChangeLevel.
  ///
  /// In en, this message translates to:
  /// **'Spot the Change • Level {level}'**
  String spotChangeLevel(Object level);

  /// No description provided for @memorizePicturePrompt.
  ///
  /// In en, this message translates to:
  /// **'Take your time to memorize the picture.'**
  String get memorizePicturePrompt;

  /// No description provided for @getReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready...'**
  String get getReady;

  /// No description provided for @whichOneChanged.
  ///
  /// In en, this message translates to:
  /// **'Which one changed? ({trial} of {total})'**
  String whichOneChanged(Object trial, Object total);

  /// No description provided for @correctExclaim.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correctExclaim;

  /// No description provided for @thatsNotIt.
  ///
  /// In en, this message translates to:
  /// **'That\'s not it'**
  String get thatsNotIt;

  /// No description provided for @imReady.
  ///
  /// In en, this message translates to:
  /// **'I\'m Ready'**
  String get imReady;

  /// No description provided for @roundComplete.
  ///
  /// In en, this message translates to:
  /// **'{gameName} • Round complete'**
  String roundComplete(Object gameName);

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreLabel(Object score);

  /// No description provided for @accuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {percent}%'**
  String accuracyLabel(Object percent);

  /// No description provided for @difficultyIncreased.
  ///
  /// In en, this message translates to:
  /// **'Difficulty increased! 🎉'**
  String get difficultyIncreased;

  /// No description provided for @difficultyDecreased.
  ///
  /// In en, this message translates to:
  /// **'Difficulty adjusted down a little'**
  String get difficultyDecreased;

  /// No description provided for @difficultySame.
  ///
  /// In en, this message translates to:
  /// **'Difficulty stays the same'**
  String get difficultySame;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @reasonAccuracyLow.
  ///
  /// In en, this message translates to:
  /// **'Accuracy below 40% — lowering difficulty immediately.'**
  String get reasonAccuracyLow;

  /// No description provided for @reasonExcellentRound.
  ///
  /// In en, this message translates to:
  /// **'Excellent round (accuracy ≥95%, fast) — raising difficulty.'**
  String get reasonExcellentRound;

  /// No description provided for @reasonTwoStrongRounds.
  ///
  /// In en, this message translates to:
  /// **'Two consecutive strong rounds — raising difficulty.'**
  String get reasonTwoStrongRounds;

  /// No description provided for @reasonGoodRound.
  ///
  /// In en, this message translates to:
  /// **'Good round — one more like this raises difficulty.'**
  String get reasonGoodRound;

  /// No description provided for @reasonTwoWeakRounds.
  ///
  /// In en, this message translates to:
  /// **'Two consecutive weak rounds — lowering difficulty.'**
  String get reasonTwoWeakRounds;

  /// No description provided for @reasonBelowTargetRound.
  ///
  /// In en, this message translates to:
  /// **'Below-target round — one more like this lowers difficulty.'**
  String get reasonBelowTargetRound;

  /// No description provided for @reasonSteadyPerformance.
  ///
  /// In en, this message translates to:
  /// **'Steady performance — holding difficulty.'**
  String get reasonSteadyPerformance;

  /// No description provided for @recallCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Recall Check-in'**
  String get recallCheckIn;

  /// No description provided for @recallPromptQuestion.
  ///
  /// In en, this message translates to:
  /// **'Did you do this today?'**
  String get recallPromptQuestion;

  /// No description provided for @recallYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, I did'**
  String get recallYes;

  /// No description provided for @recallNo.
  ///
  /// In en, this message translates to:
  /// **'No, not yet'**
  String get recallNo;

  /// No description provided for @recallNotSure.
  ///
  /// In en, this message translates to:
  /// **'I don\'t remember'**
  String get recallNotSure;

  /// No description provided for @recallFeedbackCorrectDone.
  ///
  /// In en, this message translates to:
  /// **'That\'s right — you did! 🌟'**
  String get recallFeedbackCorrectDone;

  /// No description provided for @recallFeedbackGentleCorrectionDone.
  ///
  /// In en, this message translates to:
  /// **'Actually, you did do this earlier today 💛'**
  String get recallFeedbackGentleCorrectionDone;

  /// No description provided for @recallFeedbackAcknowledgeNotDone.
  ///
  /// In en, this message translates to:
  /// **'Thanks for letting us know 💛'**
  String get recallFeedbackAcknowledgeNotDone;

  /// No description provided for @recallOfferMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Would you like to mark it done now?'**
  String get recallOfferMarkDone;

  /// No description provided for @markDoneNow.
  ///
  /// In en, this message translates to:
  /// **'Mark done now'**
  String get markDoneNow;

  /// No description provided for @noRecallItemsYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing to check in on right now.\nCome back after your next reminder time.'**
  String get noRecallItemsYet;

  /// No description provided for @recallNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get recallNext;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Care'**
  String get appTitle;

  /// No description provided for @whoIsUsingApp.
  ///
  /// In en, this message translates to:
  /// **'Who is using the app right now?'**
  String get whoIsUsingApp;

  /// No description provided for @roleCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get roleCaregiver;

  /// No description provided for @roleCaregiverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage patients, routines and progress'**
  String get roleCaregiverSubtitle;

  /// No description provided for @rolePatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get rolePatient;

  /// No description provided for @rolePatientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your User ID and password to play and use your routine'**
  String get rolePatientSubtitle;

  /// No description provided for @deviceNotSetUpMessage.
  ///
  /// In en, this message translates to:
  /// **'This device hasn\'t been set up yet.\nAsk your caregiver to sign in and add a patient profile first.'**
  String get deviceNotSetUpMessage;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get changeLanguage;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @emailValidatorError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailValidatorError;

  /// No description provided for @passwordValidatorError.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordValidatorError;

  /// No description provided for @caregiverSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Caregiver sign in'**
  String get caregiverSignInSubtitle;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInButton;

  /// No description provided for @newCaregiverCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'New caregiver? Create an account'**
  String get newCaregiverCreateAccount;

  /// No description provided for @createCaregiverAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Caregiver Account'**
  String get createCaregiverAccountTitle;

  /// No description provided for @yourNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourNameLabel;

  /// No description provided for @enterYourNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourNameError;

  /// No description provided for @atLeast6CharsError.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6CharsError;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @checkEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account, then come back and log in.'**
  String get checkEmailMessage;

  /// No description provided for @backToLogIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Log In'**
  String get backToLogIn;

  /// No description provided for @caregiverDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Dashboard'**
  String get caregiverDashboardTitle;

  /// No description provided for @signOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutTooltip;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTooltip;

  /// No description provided for @progressDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress Dashboard'**
  String get progressDashboardTitle;

  /// No description provided for @progressDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See the patient\'s game scores, difficulty trend and routine adherence'**
  String get progressDashboardSubtitle;

  /// No description provided for @manageDailyRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Daily Routine'**
  String get manageDailyRoutineTitle;

  /// No description provided for @manageDailyRoutineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set medicine, hydration, activity and appointment reminders'**
  String get manageDailyRoutineSubtitle;

  /// No description provided for @manageMemoryLaneTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Memory Lane'**
  String get manageMemoryLaneTitle;

  /// No description provided for @manageMemoryLaneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add family photos, stories, and favorite songs'**
  String get manageMemoryLaneSubtitle;

  /// No description provided for @patientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patientsTitle;

  /// No description provided for @patientsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a patient profile or manage their login'**
  String get patientsSubtitle;

  /// No description provided for @addPatientButton.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatientButton;

  /// No description provided for @ageValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Age {age}'**
  String ageValueLabel(Object age);

  /// No description provided for @activeChip.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeChip;

  /// No description provided for @switchToButton.
  ///
  /// In en, this message translates to:
  /// **'Switch to'**
  String get switchToButton;

  /// No description provided for @setUpPatientProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Up Patient Profile'**
  String get setUpPatientProfileTitle;

  /// No description provided for @welcomeHeading.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeHeading;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up the patient\'s profile to get started.'**
  String get welcomeSubtitle;

  /// No description provided for @patientsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient\'s name'**
  String get patientsNameLabel;

  /// No description provided for @pleaseEnterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterNameError;

  /// No description provided for @ageFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageFieldLabel;

  /// No description provided for @enterValidAgeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age'**
  String get enterValidAgeError;

  /// No description provided for @preferredLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get preferredLanguageLabel;

  /// No description provided for @culturalThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Familiar/cultural theme for game content'**
  String get culturalThemeLabel;

  /// No description provided for @culturalThemeExplanation.
  ///
  /// In en, this message translates to:
  /// **'This only changes which everyday objects show up in the games at higher levels — not the app language.'**
  String get culturalThemeExplanation;

  /// No description provided for @themeGeneralNer.
  ///
  /// In en, this message translates to:
  /// **'General NER'**
  String get themeGeneralNer;

  /// No description provided for @themeAssam.
  ///
  /// In en, this message translates to:
  /// **'Assam'**
  String get themeAssam;

  /// No description provided for @themeManipur.
  ///
  /// In en, this message translates to:
  /// **'Manipur'**
  String get themeManipur;

  /// No description provided for @setPatientCredentialsLabel.
  ///
  /// In en, this message translates to:
  /// **'Set a Patient User ID and password for Patient view'**
  String get setPatientCredentialsLabel;

  /// No description provided for @credentialHandoffExplanation.
  ///
  /// In en, this message translates to:
  /// **'{name} will use these to log in on this device.'**
  String credentialHandoffExplanation(Object name);

  /// No description provided for @defaultPatientWord.
  ///
  /// In en, this message translates to:
  /// **'the patient'**
  String get defaultPatientWord;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @enterValidUserIdError.
  ///
  /// In en, this message translates to:
  /// **'Choose a User ID: lowercase letters, numbers or underscore, at least 3 characters'**
  String get enterValidUserIdError;

  /// No description provided for @passwordTooShortError.
  ///
  /// In en, this message translates to:
  /// **'At least 4 characters'**
  String get passwordTooShortError;

  /// No description provided for @passwordsDoNotMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatchError;

  /// No description provided for @userIdAlreadyTakenError.
  ///
  /// In en, this message translates to:
  /// **'This User ID is already taken. Please choose another.'**
  String get userIdAlreadyTakenError;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @addAMemoryButton.
  ///
  /// In en, this message translates to:
  /// **'Add a memory'**
  String get addAMemoryButton;

  /// No description provided for @noMemoriesAddedCaregiver.
  ///
  /// In en, this message translates to:
  /// **'No memories added yet.\nAdd a family photo, a place, and a short story to get started.'**
  String get noMemoriesAddedCaregiver;

  /// No description provided for @removeMemoryQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this memory?'**
  String get removeMemoryQuestionTitle;

  /// No description provided for @removeMemoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed for good.'**
  String removeMemoryConfirm(Object title);

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// No description provided for @tellUsAboutMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about this memory'**
  String get tellUsAboutMemoryTitle;

  /// No description provided for @whoIsThisRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Who is this? *'**
  String get whoIsThisRequiredLabel;

  /// No description provided for @placeOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Place (optional)'**
  String get placeOptionalLabel;

  /// No description provided for @whenWasThisOptional.
  ///
  /// In en, this message translates to:
  /// **'When was this? (optional)'**
  String get whenWasThisOptional;

  /// No description provided for @shortStoryOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'A short story (optional)'**
  String get shortStoryOptionalLabel;

  /// No description provided for @attachFavoriteSongOptional.
  ///
  /// In en, this message translates to:
  /// **'Attach a favorite song (optional)'**
  String get attachFavoriteSongOptional;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @viewedTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {Viewed {count} time} other {Viewed {count} times}}'**
  String viewedTimes(num count);

  /// No description provided for @recognizedCountSuffix.
  ///
  /// In en, this message translates to:
  /// **'recognized {recognized}/{presented} times'**
  String recognizedCountSuffix(Object recognized, Object presented);

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Progress'**
  String progressTitle(Object name);

  /// No description provided for @levelValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelValueLabel(Object level);

  /// No description provided for @roundsLoggedLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} rounds logged'**
  String roundsLoggedLabel(Object count);

  /// No description provided for @accuracyTrendSuffix.
  ///
  /// In en, this message translates to:
  /// **'accuracy trend'**
  String get accuracyTrendSuffix;

  /// No description provided for @noRoundsPlayedYet.
  ///
  /// In en, this message translates to:
  /// **'No rounds played yet.'**
  String get noRoundsPlayedYet;

  /// No description provided for @nowLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Now: Level {level}'**
  String nowLevelLabel(Object level);

  /// No description provided for @routineAdherenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine Adherence — last 7 days'**
  String get routineAdherenceTitle;

  /// No description provided for @completedMissedLabel.
  ///
  /// In en, this message translates to:
  /// **'{done} completed • {missed} missed'**
  String completedMissedLabel(Object done, Object missed);

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// No description provided for @alertsTitleWithCount.
  ///
  /// In en, this message translates to:
  /// **'Alerts ({count} new)'**
  String alertsTitleWithCount(Object count);

  /// No description provided for @markReadButton.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get markReadButton;

  /// No description provided for @recallAccuracyTitle.
  ///
  /// In en, this message translates to:
  /// **'Recall Check-in accuracy — last 7 days'**
  String get recallAccuracyTitle;

  /// No description provided for @recallAccuracyExplanation.
  ///
  /// In en, this message translates to:
  /// **'How often the patient\'s own memory of doing a routine task matched what was actually logged.'**
  String get recallAccuracyExplanation;

  /// No description provided for @noRecallCheckinsYet.
  ///
  /// In en, this message translates to:
  /// **'No recall check-ins answered yet.'**
  String get noRecallCheckinsYet;

  /// No description provided for @recallStatsLabel.
  ///
  /// In en, this message translates to:
  /// **'{correct} matched • {mismatched} mismatched • {total} check-ins answered'**
  String recallStatsLabel(Object correct, Object mismatched, Object total);

  /// No description provided for @recentMismatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent mismatches'**
  String get recentMismatchesTitle;

  /// No description provided for @mismatchLine.
  ///
  /// In en, this message translates to:
  /// **'{date} — {title} (actually: {status})'**
  String mismatchLine(Object date, Object title, Object status);

  /// No description provided for @statusNotDoneWord.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get statusNotDoneWord;

  /// No description provided for @memoryLaneEngagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane engagement'**
  String get memoryLaneEngagementTitle;

  /// No description provided for @memoryLaneEngagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A gentle reminiscence feature, not a cognitive test — these are just engagement signals.'**
  String get memoryLaneEngagementSubtitle;

  /// No description provided for @memoriesStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memoriesStatLabel;

  /// No description provided for @viewsStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get viewsStatLabel;

  /// No description provided for @recognizedStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Recognized'**
  String get recognizedStatLabel;

  /// No description provided for @recentSessionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent session history'**
  String get recentSessionHistoryTitle;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet.'**
  String get noSessionsYet;

  /// No description provided for @accuracyAvgLabel.
  ///
  /// In en, this message translates to:
  /// **'{accuracy}% accuracy • {ms}ms avg'**
  String accuracyAvgLabel(Object accuracy, Object ms);

  /// No description provided for @ptsLabel.
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String ptsLabel(Object score);

  /// No description provided for @choosePatientTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a patient'**
  String get choosePatientTitle;

  /// No description provided for @choosePatientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select who you\'re managing right now.'**
  String get choosePatientSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['as', 'en', 'mni'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return AppLocalizationsAs();
    case 'en':
      return AppLocalizationsEn();
    case 'mni':
      return AppLocalizationsMni();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
