import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  bool get isArabic => locale.languageCode == 'ar';

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    assert(result != null, 'AppLocalizations not found in context');

    return result!;
  }

  String get appName => 'Newsly';

  String get profile => isArabic ? 'الملف الشخصي' : 'Profile';
  String get preferences => isArabic ? 'التفضيلات' : 'Preferences';

  String get darkMode => isArabic ? 'الوضع الداكن' : 'Dark Mode';
  String get changeAppearance =>
      isArabic ? 'تغيير مظهر التطبيق' : 'Change the appearance of Newsly';

  String get language => isArabic ? 'اللغة' : 'Language';
  String get chooseLanguage => isArabic ? 'اختر اللغة' : 'Choose Language';

  String get fontSize => isArabic ? 'حجم الخط' : 'Font Size';
  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';
  String get saveNotificationPreference => isArabic
      ? 'حفظ تفضيلات الإشعارات'
      : 'Save your notification preference';

  String get logOut => isArabic ? 'تسجيل الخروج' : 'Log Out';
  String get signOutAccount =>
      isArabic ? 'الخروج من حسابك' : 'Sign out of your account';

  String get editName => isArabic ? 'تعديل الاسم' : 'Edit Name';
  String get fullName => isArabic ? 'الاسم بالكامل' : 'Full name';
  String get enterName => isArabic ? 'أدخل اسمك' : 'Enter your name';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get save => isArabic ? 'حفظ' : 'Save';

  String get nameCannotBeEmpty =>
      isArabic ? 'لا يمكن ترك الاسم فارغًا.' : 'Name cannot be empty.';

  String get nameUpdated =>
      isArabic ? 'تم تحديث الاسم بنجاح.' : 'Name updated successfully.';

  String get nameUpdateFailed =>
      isArabic ? 'تعذر تحديث الاسم.' : 'Could not update your name.';

  String get addYourName => isArabic ? 'أضف اسمك' : 'Add your name';
  String get noEmail => isArabic ? 'لا يوجد بريد إلكتروني' : 'No email available';

  String get chooseFromGallery =>
      isArabic ? 'اختر من المعرض' : 'Choose from gallery';

  String get removeProfilePicture =>
      isArabic ? 'حذف الصورة الشخصية' : 'Remove profile picture';

  String get profilePictureUpdated =>
      isArabic ? 'تم تحديث الصورة الشخصية بنجاح.' : 'Profile picture updated successfully.';

  String get profilePictureRemoved =>
      isArabic ? 'تم حذف الصورة الشخصية.' : 'Profile picture removed.';

  String get small => isArabic ? 'صغير' : 'Small';
  String get medium => isArabic ? 'متوسط' : 'Medium';
  String get large => isArabic ? 'كبير' : 'Large';

  String get fontSizeUpdated =>
      isArabic ? 'تم تحديث حجم الخط.' : 'Font size updated.';

  String get english => 'English';
  String get arabic => 'العربية';

  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get savedNews => isArabic ? 'الأخبار المحفوظة' : 'Saved News';
  String get search => isArabic ? 'بحث' : 'Search';
  String get categories => isArabic ? 'التصنيفات' : 'Categories';
  String get readMore => isArabic ? 'اقرأ المزيد' : 'Read More';

  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get welcomeBack => isArabic ? 'مرحبًا بعودتك' : 'Welcome Back';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'ar';

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}