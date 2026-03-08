// lib/l10n/app_localizations.dart
// This is a simplified localizations class.
// In production, generate this with: flutter gen-l10n
// after setting up l10n.yaml and ARB files.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('si', 'LK'),
    Locale('ta', 'LK'),
  ];

  bool get isSinhala => locale.languageCode == 'si';
  bool get isTamil => locale.languageCode == 'ta';
  bool get isEnglish => locale.languageCode == 'en';

  // Returns the font family based on locale
  String get fontFamily {
    if (isSinhala) return 'NotoSansSinhala';
    if (isTamil) return 'NotoSansTamil';
    return 'Poppins';
  }

  // Translations map
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'appTitle': 'My App',
      'welcome': 'Welcome Back',
      'welcomeSubtitle': 'Sign in to continue',
      'email': 'Email',
      'password': 'Password',
      'username': 'Username',
      'confirmPassword': 'Confirm Password',
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'signOut': 'Sign Out',
      'signInWithGoogle': 'Continue with Google',
      'forgotPassword': 'Forgot Password?',
      'forgotPasswordTitle': 'Reset Password',
      'forgotPasswordSubtitle': 'Enter your email to receive a reset link',
      'sendResetLink': 'Send Reset Link',
      'noAccount': "Don't have an account? ",
      'haveAccount': 'Already have an account? ',
      'createAccount': 'Create Account',
      'createAccountSubtitle': 'Join us today',
      'home': 'Home',
      'profile': 'Profile',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'language': 'Language',
      'theme': 'Theme',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'english': 'English',
      'sinhala': 'Sinhala',
      'tamil': 'Tamil',
      'selectLanguage': 'Select Language',
      'saveChanges': 'Save Changes',
      'editProfile': 'Edit Profile',
      'displayName': 'Display Name',
      'emailVerified': 'Email Verified',
      'emailNotVerified': 'Email Not Verified',
      'verifyEmail': 'Verify Email',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'validationEmailRequired': 'Email is required',
      'validationEmailInvalid': 'Enter a valid email address',
      'validationPasswordRequired': 'Password is required',
      'validationPasswordLength': 'Password must be at least 6 characters',
      'validationPasswordMatch': 'Passwords do not match',
      'validationUsernameRequired': 'Username is required',
      'validationUsernameLength': 'Username must be at least 3 characters',
      'onboardingTitle1': 'Stay Connected',
      'onboardingSubtitle1': 'Get real-time notifications and updates',
      'onboardingTitle2': 'Multilingual',
      'onboardingSubtitle2': 'Available in English, Sinhala and Tamil',
      'onboardingTitle3': 'Secure',
      'onboardingSubtitle3': 'Protected with Firebase Authentication',
      'getStarted': 'Get Started',
      'next': 'Next',
      'skip': 'Skip',
      'fcmToken': 'FCM Token',
      'copyToken': 'Copy Token',
      'tokenCopied': 'Token copied to clipboard',
      'notificationPermission': 'Enable Notifications',
      'notificationPermissionDesc': 'Get important updates and alerts',
      'enable': 'Enable',
      'deny': 'Deny',
    },
    'si': {
      'appTitle': 'මගේ යෙදුම',
      'welcome': 'නැවත සාදරයෙන් පිළිගනිමු',
      'welcomeSubtitle': 'ඉදිරියට යාමට ප්‍රවේශ වන්න',
      'email': 'විද්‍යුත් තැපෑල',
      'password': 'මුරපදය',
      'username': 'පරිශීලක නාමය',
      'confirmPassword': 'මුරපදය තහවුරු කරන්න',
      'signIn': 'ප්‍රවේශ වන්න',
      'signUp': 'ලියාපදිංචි වන්න',
      'signOut': 'ඉවත් වන්න',
      'signInWithGoogle': 'Google සමඟ ඉදිරියට යන්න',
      'forgotPassword': 'මුරපදය අමතක වුණාද?',
      'forgotPasswordTitle': 'මුරපදය යළි සකසන්න',
      'forgotPasswordSubtitle': 'යළි සකසන ලිපිය ලබා ගැනීමට ඔබේ ඊමේල් ඇතුළු කරන්න',
      'sendResetLink': 'යළි සකස් කිරීමේ සබැඳිය යවන්න',
      'noAccount': 'ගිණුමක් නැද්ද? ',
      'haveAccount': 'දැනටමත් ගිණුමක් තිබේද? ',
      'createAccount': 'ගිණුම සාදන්න',
      'createAccountSubtitle': 'අද අපත් සමඟ එකතු වන්න',
      'home': 'මුල් පිටුව',
      'profile': 'පැතිකඩ',
      'settings': 'සැකසුම්',
      'notifications': 'දැනුම්දීම්',
      'language': 'භාෂාව',
      'theme': 'තේමාව',
      'darkMode': 'අඳුරු ප්‍රකාරය',
      'lightMode': 'ආලෝකමත් ප්‍රකාරය',
      'english': 'ඉංග්‍රීසි',
      'sinhala': 'සිංහල',
      'tamil': 'දෙමළ',
      'selectLanguage': 'භාෂාව තෝරන්න',
      'saveChanges': 'වෙනස්කම් සුරකින්න',
      'editProfile': 'පැතිකඩ සංස්කරණය',
      'displayName': 'දර්ශන නාමය',
      'emailVerified': 'ඊමේල් සත්‍යාපනය කළා',
      'emailNotVerified': 'ඊමේල් සත්‍යාපනය කර නැත',
      'verifyEmail': 'ඊමේල් සත්‍යාපනය කරන්න',
      'loading': 'පූරණය වෙමින්...',
      'error': 'දෝෂය',
      'retry': 'නැවත උත්සාහ කරන්න',
      'cancel': 'අවලංගු කරන්න',
      'confirm': 'තහවුරු කරන්න',
      'delete': 'මකන්න',
      'validationEmailRequired': 'ඊමේල් අවශ්‍යයි',
      'validationEmailInvalid': 'වලංගු ඊමේල් ලිපිනයක් ඇතුළු කරන්න',
      'validationPasswordRequired': 'මුරපදය අවශ්‍යයි',
      'validationPasswordLength': 'මුරපදය අකුරු 6 ක් වත් විය යුතුය',
      'validationPasswordMatch': 'මුරපද නොගැලපේ',
      'validationUsernameRequired': 'පරිශීලක නාමය අවශ්‍යයි',
      'validationUsernameLength': 'පරිශීලක නාමය අකුරු 3 ක් වත් විය යුතුය',
      'onboardingTitle1': 'සම්බන්ධ වී සිටින්න',
      'onboardingSubtitle1': 'තත්‍ය කාලීන දැනුම්දීම් සහ යාවත්කාලීන ලබා ගන්න',
      'onboardingTitle2': 'බහු භාෂා',
      'onboardingSubtitle2': 'ඉංග්‍රීසි, සිංහල සහ දෙමළ භාෂාවලින් ලබා ගත හැක',
      'onboardingTitle3': 'ආරක්ෂිතයි',
      'onboardingSubtitle3': 'Firebase Authentication මඟින් ආරක්ෂිතයි',
      'getStarted': 'ආරම්භ කරන්න',
      'next': 'ඊළඟ',
      'skip': 'මඟ හරින්න',
      'fcmToken': 'FCM ටෝකනය',
      'copyToken': 'ටෝකනය පිටපත් කරන්න',
      'tokenCopied': 'ටෝකනය clipboard වෙත පිටපත් කළා',
      'notificationPermission': 'දැනුම්දීම් සබල කරන්න',
      'notificationPermissionDesc': 'වැදගත් යාවත්කාලීන සහ ඇඟවීම් ලබා ගන්න',
      'enable': 'සබල කරන්න',
      'deny': 'ප්‍රතික්ෂේප කරන්න',
    },
    'ta': {
      'appTitle': 'என் ஆப்',
      'welcome': 'மீண்டும் வருக',
      'welcomeSubtitle': 'தொடர உள்நுழையவும்',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'username': 'பயனர்பெயர்',
      'confirmPassword': 'கடவுச்சொல்லை உறுதிப்படுத்தவும்',
      'signIn': 'உள்நுழைவு',
      'signUp': 'பதிவு செய்யவும்',
      'signOut': 'வெளியேறு',
      'signInWithGoogle': 'Google மூலம் தொடரவும்',
      'forgotPassword': 'கடவுச்சொல் மறந்தீர்களா?',
      'forgotPasswordTitle': 'கடவுச்சொல்லை மீட்டமைக்கவும்',
      'forgotPasswordSubtitle': 'மீட்டமைப்பு இணைப்பைப் பெற உங்கள் மின்னஞ்சலை உள்ளிடவும்',
      'sendResetLink': 'மீட்டமைப்பு இணைப்பை அனுப்பவும்',
      'noAccount': 'கணக்கு இல்லையா? ',
      'haveAccount': 'ஏற்கனவே கணக்கு உள்ளதா? ',
      'createAccount': 'கணக்கை உருவாக்கவும்',
      'createAccountSubtitle': 'இன்றே எங்களுடன் இணையுங்கள்',
      'home': 'முகப்பு',
      'profile': 'சுயவிவரம்',
      'settings': 'அமைப்புகள்',
      'notifications': 'அறிவிப்புகள்',
      'language': 'மொழி',
      'theme': 'தீம்',
      'darkMode': 'இருண்ட பயன்முறை',
      'lightMode': 'ஒளி பயன்முறை',
      'english': 'ஆங்கிலம்',
      'sinhala': 'சிங்களம்',
      'tamil': 'தமிழ்',
      'selectLanguage': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'saveChanges': 'மாற்றங்களைச் சேமிக்கவும்',
      'editProfile': 'சுயவிவரத்தைத் திருத்தவும்',
      'displayName': 'காட்சிப் பெயர்',
      'emailVerified': 'மின்னஞ்சல் சரிபார்க்கப்பட்டது',
      'emailNotVerified': 'மின்னஞ்சல் சரிபார்க்கப்படவில்லை',
      'verifyEmail': 'மின்னஞ்சலை சரிபார்க்கவும்',
      'loading': 'ஏற்றுகிறது...',
      'error': 'பிழை',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'cancel': 'ரத்துசெய்',
      'confirm': 'உறுதிப்படுத்தவும்',
      'delete': 'நீக்கவும்',
      'validationEmailRequired': 'மின்னஞ்சல் தேவை',
      'validationEmailInvalid': 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்',
      'validationPasswordRequired': 'கடவுச்சொல் தேவை',
      'validationPasswordLength': 'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்',
      'validationPasswordMatch': 'கடவுச்சொற்கள் பொருந்தவில்லை',
      'validationUsernameRequired': 'பயனர்பெயர் தேவை',
      'validationUsernameLength': 'பயனர்பெயர் குறைந்தது 3 எழுத்துகள் இருக்க வேண்டும்',
      'onboardingTitle1': 'இணைந்திருங்கள்',
      'onboardingSubtitle1': 'நிகழ்நேர அறிவிப்புகள் மற்றும் புதுப்பிப்புகளைப் பெறுங்கள்',
      'onboardingTitle2': 'பல மொழி',
      'onboardingSubtitle2': 'ஆங்கிலம், சிங்களம் மற்றும் தமிழில் கிடைக்கிறது',
      'onboardingTitle3': 'பாதுகாப்பான',
      'onboardingSubtitle3': 'Firebase Authentication மூலம் பாதுகாக்கப்பட்டது',
      'getStarted': 'தொடங்குங்கள்',
      'next': 'அடுத்து',
      'skip': 'தவிர்க்கவும்',
      'fcmToken': 'FCM டோக்கன்',
      'copyToken': 'டோக்கனை நகலெடுக்கவும்',
      'tokenCopied': 'டோக்கன் clipboard க்கு நகலெடுக்கப்பட்டது',
      'notificationPermission': 'அறிவிப்புகளை இயக்கவும்',
      'notificationPermissionDesc': 'முக்கியமான புதுப்பிப்புகள் மற்றும் எச்சரிக்கைகளைப் பெறுங்கள்',
      'enable': 'இயக்கவும்',
      'deny': 'மறுக்கவும்',
    },
  };

  String translate(String key) {
    final langCode = locale.languageCode;
    final lang = _localizedStrings[langCode] ?? _localizedStrings['en']!;
    return lang[key] ?? _localizedStrings['en']![key] ?? key;
  }

  // Convenience getters
  String get appTitle => translate('appTitle');
  String get welcome => translate('welcome');
  String get welcomeSubtitle => translate('welcomeSubtitle');
  String get email => translate('email');
  String get password => translate('password');
  String get username => translate('username');
  String get confirmPassword => translate('confirmPassword');
  String get signIn => translate('signIn');
  String get signUp => translate('signUp');
  String get signOut => translate('signOut');
  String get signInWithGoogle => translate('signInWithGoogle');
  String get forgotPassword => translate('forgotPassword');
  String get forgotPasswordTitle => translate('forgotPasswordTitle');
  String get forgotPasswordSubtitle => translate('forgotPasswordSubtitle');
  String get sendResetLink => translate('sendResetLink');
  String get noAccount => translate('noAccount');
  String get haveAccount => translate('haveAccount');
  String get createAccount => translate('createAccount');
  String get createAccountSubtitle => translate('createAccountSubtitle');
  String get home => translate('home');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get notifications => translate('notifications');
  String get language => translate('language');
  String get theme => translate('theme');
  String get darkMode => translate('darkMode');
  String get lightMode => translate('lightMode');
  String get english => translate('english');
  String get sinhala => translate('sinhala');
  String get tamil => translate('tamil');
  String get selectLanguage => translate('selectLanguage');
  String get saveChanges => translate('saveChanges');
  String get editProfile => translate('editProfile');
  String get displayName => translate('displayName');
  String get emailVerified => translate('emailVerified');
  String get emailNotVerified => translate('emailNotVerified');
  String get verifyEmail => translate('verifyEmail');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get delete => translate('delete');
  String get validationEmailRequired => translate('validationEmailRequired');
  String get validationEmailInvalid => translate('validationEmailInvalid');
  String get validationPasswordRequired => translate('validationPasswordRequired');
  String get validationPasswordLength => translate('validationPasswordLength');
  String get validationPasswordMatch => translate('validationPasswordMatch');
  String get validationUsernameRequired => translate('validationUsernameRequired');
  String get validationUsernameLength => translate('validationUsernameLength');
  String get onboardingTitle1 => translate('onboardingTitle1');
  String get onboardingSubtitle1 => translate('onboardingSubtitle1');
  String get onboardingTitle2 => translate('onboardingTitle2');
  String get onboardingSubtitle2 => translate('onboardingSubtitle2');
  String get onboardingTitle3 => translate('onboardingTitle3');
  String get onboardingSubtitle3 => translate('onboardingSubtitle3');
  String get getStarted => translate('getStarted');
  String get next => translate('next');
  String get skip => translate('skip');
  String get fcmToken => translate('fcmToken');
  String get copyToken => translate('copyToken');
  String get tokenCopied => translate('tokenCopied');
  String get notificationPermission => translate('notificationPermission');
  String get notificationPermissionDesc => translate('notificationPermissionDesc');
  String get enable => translate('enable');
  String get deny => translate('deny');

  String hi(String name) => translate('hi').replaceAll('{name}', name);
  String memberSince(String date) => translate('memberSince').replaceAll('{date}', date);
  String resetEmailSent(String email) => translate('resetEmailSent').replaceAll('{email}', email);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'si', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
