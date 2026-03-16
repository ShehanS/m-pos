// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'என் ஆப்';

  @override
  String get welcome => 'மீண்டும் வருக';

  @override
  String get welcomeSubtitle => 'தொடர உள்நுழையவும்';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get username => 'பயனர்பெயர்';

  @override
  String get confirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get signIn => 'உள்நுழைவு';

  @override
  String get signUp => 'பதிவு செய்யவும்';

  @override
  String get signOut => 'வெளியேறு';

  @override
  String get signInWithGoogle => 'Google மூலம் தொடரவும்';

  @override
  String get forgotPassword => 'கடவுச்சொல் மறந்தீர்களா?';

  @override
  String get forgotPasswordTitle => 'கடவுச்சொல்லை மீட்டமைக்கவும்';

  @override
  String get forgotPasswordSubtitle => 'மீட்டமைப்பு இணைப்பைப் பெற உங்கள் மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get sendResetLink => 'மீட்டமைப்பு இணைப்பை அனுப்பவும்';

  @override
  String resetEmailSent(String email) {
    return '$email க்கு மீட்டமைப்பு மின்னஞ்சல் அனுப்பப்பட்டது';
  }

  @override
  String get noAccount => 'கணக்கு இல்லையா? ';

  @override
  String get haveAccount => 'ஏற்கனவே கணக்கு உள்ளதா? ';

  @override
  String get createAccount => 'கணக்கை உருவாக்கவும்';

  @override
  String get createAccountSubtitle => 'இன்றே எங்களுடன் இணையுங்கள்';

  @override
  String get home => 'முகப்பு';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get language => 'மொழி';

  @override
  String get theme => 'தீம்';

  @override
  String get darkMode => 'இருண்ட பயன்முறை';

  @override
  String get lightMode => 'ஒளி பயன்முறை';

  @override
  String get english => 'ஆங்கிலம்';

  @override
  String get sinhala => 'சிங்களம்';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get saveChanges => 'மாற்றங்களைச் சேமிக்கவும்';

  @override
  String get editProfile => 'சுயவிவரத்தைத் திருத்தவும்';

  @override
  String get displayName => 'காட்சிப் பெயர்';

  @override
  String get emailVerified => 'மின்னஞ்சல் சரிபார்க்கப்பட்டது';

  @override
  String get emailNotVerified => 'மின்னஞ்சல் சரிபார்க்கப்படவில்லை';

  @override
  String get verifyEmail => 'மின்னஞ்சலை சரிபார்க்கவும்';

  @override
  String memberSince(String date) {
    return '$date முதல் உறுப்பினர்';
  }

  @override
  String hi(String name) {
    return 'வணக்கம், $name!';
  }

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get error => 'பிழை';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get cancel => 'ரத்துசெய்';

  @override
  String get confirm => 'உறுதிப்படுத்தவும்';

  @override
  String get delete => 'நீக்கவும்';

  @override
  String get validationEmailRequired => 'மின்னஞ்சல் தேவை';

  @override
  String get validationEmailInvalid => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get validationPasswordRequired => 'கடவுச்சொல் தேவை';

  @override
  String get validationPasswordLength => 'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get validationPasswordMatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get validationUsernameRequired => 'பயனர்பெயர் தேவை';

  @override
  String get validationUsernameLength => 'பயனர்பெயர் குறைந்தது 3 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get onboardingTitle1 => 'இணைந்திருங்கள்';

  @override
  String get onboardingSubtitle1 => 'நிகழ்நேர அறிவிப்புகள் மற்றும் புதுப்பிப்புகளைப் பெறுங்கள்';

  @override
  String get onboardingTitle2 => 'பல மொழி';

  @override
  String get onboardingSubtitle2 => 'ஆங்கிலம், சிங்களம் மற்றும் தமிழில் கிடைக்கிறது';

  @override
  String get onboardingTitle3 => 'பாதுகாப்பான';

  @override
  String get onboardingSubtitle3 => 'Firebase Authentication மூலம் பாதுகாக்கப்பட்டது';

  @override
  String get getStarted => 'தொடங்குங்கள்';

  @override
  String get next => 'அடுத்து';

  @override
  String get skip => 'தவிர்க்கவும்';

  @override
  String get fcmToken => 'FCM டோக்கன்';

  @override
  String get copyToken => 'டோக்கனை நகலெடுக்கவும்';

  @override
  String get tokenCopied => 'டோக்கன் clipboard க்கு நகலெடுக்கப்பட்டது';

  @override
  String get notificationPermission => 'அறிவிப்புகளை இயக்கவும்';

  @override
  String get notificationPermissionDesc => 'முக்கியமான புதுப்பிப்புகள் மற்றும் எச்சரிக்கைகளைப் பெறுங்கள்';

  @override
  String get enable => 'இயக்கவும்';

  @override
  String get deny => 'மறுக்கவும்';

  @override
  String get required => 'அவசியம்';

  @override
  String get select => 'தேர்ந்தெடுக்கவும்';

  @override
  String get change => 'மாற்றவும்';

  @override
  String get updateProfile => 'உங்கள் விவரங்களை இங்கே புதுப்பிக்கவும்';

  @override
  String get firstName => 'முதல் பெயர்';

  @override
  String get lastName => 'கடைசி பெயர்';

  @override
  String get address => 'முகவரி';

  @override
  String get contact => 'தொடர்பு எண்';
}
