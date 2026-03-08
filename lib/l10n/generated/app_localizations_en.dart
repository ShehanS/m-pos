// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My App';

  @override
  String get welcome => 'Welcome Back';

  @override
  String get welcomeSubtitle => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get username => 'Username';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle => 'Enter your email to receive a reset link';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String resetEmailSent(String email) {
    return 'Reset email sent to $email';
  }

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountSubtitle => 'Join us today';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get english => 'English';

  @override
  String get sinhala => 'Sinhala';

  @override
  String get tamil => 'Tamil';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get displayName => 'Display Name';

  @override
  String get emailVerified => 'Email Verified';

  @override
  String get emailNotVerified => 'Email Not Verified';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String hi(String name) {
    return 'Hi, $name!';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Enter a valid email address';

  @override
  String get validationPasswordRequired => 'Password is required';

  @override
  String get validationPasswordLength => 'Password must be at least 6 characters';

  @override
  String get validationPasswordMatch => 'Passwords do not match';

  @override
  String get validationUsernameRequired => 'Username is required';

  @override
  String get validationUsernameLength => 'Username must be at least 3 characters';

  @override
  String get onboardingTitle1 => 'Stay Connected';

  @override
  String get onboardingSubtitle1 => 'Get real-time notifications and updates';

  @override
  String get onboardingTitle2 => 'Multilingual';

  @override
  String get onboardingSubtitle2 => 'Available in English, Sinhala and Tamil';

  @override
  String get onboardingTitle3 => 'Secure';

  @override
  String get onboardingSubtitle3 => 'Protected with Firebase Authentication';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get fcmToken => 'FCM Token';

  @override
  String get copyToken => 'Copy Token';

  @override
  String get tokenCopied => 'Token copied to clipboard';

  @override
  String get notificationPermission => 'Enable Notifications';

  @override
  String get notificationPermissionDesc => 'Get important updates and alerts';

  @override
  String get enable => 'Enable';

  @override
  String get deny => 'Deny';
}
