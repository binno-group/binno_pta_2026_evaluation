import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_uz.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('uz')];

  /// No description provided for @appName.
  ///
  /// In uz, this message translates to:
  /// **'BINNO'**
  String get appName;

  /// No description provided for @homeTab.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifa'**
  String get homeTab;

  /// No description provided for @catalogTab.
  ///
  /// In uz, this message translates to:
  /// **'Katalog'**
  String get catalogTab;

  /// No description provided for @ordersTab.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar'**
  String get ordersTab;

  /// No description provided for @profileTab.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profileTab;

  /// No description provided for @notificationsLabel.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notificationsLabel;

  /// No description provided for @retryAction.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get retryAction;

  /// No description provided for @emptyExplanation.
  ///
  /// In uz, this message translates to:
  /// **'Yangi ma\'lumot paydo bo\'lganda shu yerda ko\'rinadi.'**
  String get emptyExplanation;

  /// No description provided for @genericErrorTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotni yuklab bo\'lmadi'**
  String get genericErrorTitle;

  /// No description provided for @genericErrorExplanation.
  ///
  /// In uz, this message translates to:
  /// **'Vaqtinchalik xatolik yuz berdi. Qayta urinib ko\'ring.'**
  String get genericErrorExplanation;

  /// No description provided for @deliveryAddressLabel.
  ///
  /// In uz, this message translates to:
  /// **'YETKAZISH MANZILI'**
  String get deliveryAddressLabel;

  /// No description provided for @deliveryAddressValue.
  ///
  /// In uz, this message translates to:
  /// **'Amir Temur 108'**
  String get deliveryAddressValue;

  /// No description provided for @changeAction.
  ///
  /// In uz, this message translates to:
  /// **'O\'zgartirish'**
  String get changeAction;

  /// No description provided for @searchHint.
  ///
  /// In uz, this message translates to:
  /// **'Sement, armatura, g\'isht...'**
  String get searchHint;

  /// No description provided for @updatedTodayTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugun yangilangan'**
  String get updatedTodayTitle;

  /// No description provided for @cementProduct.
  ///
  /// In uz, this message translates to:
  /// **'M400 sement · 50 kg qop'**
  String get cementProduct;

  /// No description provided for @cementSeller.
  ///
  /// In uz, this message translates to:
  /// **'Metall Savdo · 47-do\'kon · 6,2 km'**
  String get cementSeller;

  /// No description provided for @cementPrice.
  ///
  /// In uz, this message translates to:
  /// **'48 000'**
  String get cementPrice;

  /// No description provided for @priceUnit.
  ///
  /// In uz, this message translates to:
  /// **'so\'m / qop'**
  String get priceUnit;

  /// No description provided for @rebarProduct.
  ///
  /// In uz, this message translates to:
  /// **'Armatura Ø12 · 11,7 m'**
  String get rebarProduct;

  /// No description provided for @rebarSeller.
  ///
  /// In uz, this message translates to:
  /// **'Baraka Qurilish · olib ketish'**
  String get rebarSeller;

  /// No description provided for @rebarPrice.
  ///
  /// In uz, this message translates to:
  /// **'96 000'**
  String get rebarPrice;

  /// No description provided for @categoryCement.
  ///
  /// In uz, this message translates to:
  /// **'Sement'**
  String get categoryCement;

  /// No description provided for @categoryRebar.
  ///
  /// In uz, this message translates to:
  /// **'Armatura'**
  String get categoryRebar;

  /// No description provided for @categoryBrick.
  ///
  /// In uz, this message translates to:
  /// **'G\'isht'**
  String get categoryBrick;

  /// No description provided for @catalogHeadline.
  ///
  /// In uz, this message translates to:
  /// **'M400 sement'**
  String get catalogHeadline;

  /// No description provided for @catalogSummary.
  ///
  /// In uz, this message translates to:
  /// **'20 taklif · 8 do\'kon'**
  String get catalogSummary;

  /// No description provided for @catalogSort.
  ///
  /// In uz, this message translates to:
  /// **'Narx bo\'yicha, arzonidan'**
  String get catalogSort;

  /// No description provided for @cheapestLabel.
  ///
  /// In uz, this message translates to:
  /// **'ENG ARZON'**
  String get cheapestLabel;

  /// No description provided for @updatedTodayStatus.
  ///
  /// In uz, this message translates to:
  /// **'Bugun yangilangan'**
  String get updatedTodayStatus;

  /// No description provided for @stalePriceStatus.
  ///
  /// In uz, this message translates to:
  /// **'Narx eskirgan bo\'lishi mumkin'**
  String get stalePriceStatus;

  /// No description provided for @filterAction.
  ///
  /// In uz, this message translates to:
  /// **'Filtrlar'**
  String get filterAction;

  /// No description provided for @activeOrderTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazishga tayyorlanmoqda'**
  String get activeOrderTitle;

  /// No description provided for @activeOrderSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvchi 28-iyul ertalabga rejalashtirdi'**
  String get activeOrderSubtitle;

  /// No description provided for @orderConfirmedStatus.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvchi tasdiqladi'**
  String get orderConfirmedStatus;

  /// No description provided for @paymentAcceptedStatus.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov qabul qilindi'**
  String get paymentAcceptedStatus;

  /// No description provided for @deliveredStatus.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazildi'**
  String get deliveredStatus;

  /// No description provided for @chatAction.
  ///
  /// In uz, this message translates to:
  /// **'Chat'**
  String get chatAction;

  /// No description provided for @reportProblemAction.
  ///
  /// In uz, this message translates to:
  /// **'Muammo bor'**
  String get reportProblemAction;

  /// No description provided for @profileTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In uz, this message translates to:
  /// **'Aziz Qurilish'**
  String get profileName;

  /// No description provided for @profilePhone.
  ///
  /// In uz, this message translates to:
  /// **'+998 90 123 45 67'**
  String get profilePhone;

  /// No description provided for @roleSwitcherTitle.
  ///
  /// In uz, this message translates to:
  /// **'Rolni almashtirish'**
  String get roleSwitcherTitle;

  /// No description provided for @availableRoles.
  ///
  /// In uz, this message translates to:
  /// **'Xaridor / Sotuvchi'**
  String get availableRoles;

  /// No description provided for @activeSessionsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Faol sessiyalar'**
  String get activeSessionsTitle;

  /// No description provided for @phoneTitle.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqamingizni kiriting'**
  String get phoneTitle;

  /// No description provided for @phoneExplanation.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodi SMS orqali yuboriladi.'**
  String get phoneExplanation;

  /// No description provided for @phoneLabel.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In uz, this message translates to:
  /// **'+998 90 123 45 67'**
  String get phoneHint;

  /// No description provided for @requestOtpAction.
  ///
  /// In uz, this message translates to:
  /// **'Kod olish'**
  String get requestOtpAction;

  /// No description provided for @otpTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodini kiriting'**
  String get otpTitle;

  /// No description provided for @otpExplanation.
  ///
  /// In uz, this message translates to:
  /// **'SMS orqali yuborilgan 6 xonali kodni kiriting.'**
  String get otpExplanation;

  /// No description provided for @otpLabel.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodi'**
  String get otpLabel;

  /// No description provided for @verifyOtpAction.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get verifyOtpAction;

  /// No description provided for @resendOtpAction.
  ///
  /// In uz, this message translates to:
  /// **'Kodni qayta yuborish'**
  String get resendOtpAction;

  /// No description provided for @attemptsLeft.
  ///
  /// In uz, this message translates to:
  /// **'Qolgan urinishlar: {count}'**
  String attemptsLeft(int count);

  /// No description provided for @retryAfter.
  ///
  /// In uz, this message translates to:
  /// **'{seconds} soniyadan keyin qayta urinishingiz mumkin.'**
  String retryAfter(int seconds);

  /// No description provided for @otpExpiredTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodi eskirgan'**
  String get otpExpiredTitle;

  /// No description provided for @otpExpiredExplanation.
  ///
  /// In uz, this message translates to:
  /// **'Yangi kod so\'rang va qayta urinib ko\'ring.'**
  String get otpExpiredExplanation;

  /// No description provided for @otpInvalidTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodi noto\'g\'ri'**
  String get otpInvalidTitle;

  /// No description provided for @otpInvalidExplanation.
  ///
  /// In uz, this message translates to:
  /// **'Kodni tekshirib, qayta kiriting.'**
  String get otpInvalidExplanation;

  /// No description provided for @otpLockedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Urinishlar vaqtincha cheklangan'**
  String get otpLockedTitle;

  /// No description provided for @otpLockedExplanation.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik sababli 30 daqiqadan keyin qayta urinishingiz mumkin.'**
  String get otpLockedExplanation;

  /// No description provided for @registrationTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilni yakunlang'**
  String get registrationTitle;

  /// No description provided for @nameLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ism'**
  String get nameLabel;

  /// No description provided for @regionLabel.
  ///
  /// In uz, this message translates to:
  /// **'Hudud'**
  String get regionLabel;

  /// No description provided for @completeRegistrationAction.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tishni yakunlash'**
  String get completeRegistrationAction;

  /// No description provided for @sessionsEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa faol sessiya yo\'q'**
  String get sessionsEmptyTitle;

  /// No description provided for @currentSession.
  ///
  /// In uz, this message translates to:
  /// **'Joriy sessiya'**
  String get currentSession;

  /// No description provided for @revokeSessionAction.
  ///
  /// In uz, this message translates to:
  /// **'Sessiyani bekor qilish'**
  String get revokeSessionAction;

  /// No description provided for @logoutAllAction.
  ///
  /// In uz, this message translates to:
  /// **'Barcha sessiyalardan chiqish'**
  String get logoutAllAction;

  /// No description provided for @securityLogoutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sessiyalar xavfsizlik sababli bekor qilindi'**
  String get securityLogoutTitle;

  /// No description provided for @securityLogoutExplanation.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntingizni himoya qilish uchun qayta kiring.'**
  String get securityLogoutExplanation;

  /// No description provided for @signInAgainAction.
  ///
  /// In uz, this message translates to:
  /// **'Qayta kirish'**
  String get signInAgainAction;
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
      <String>['uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
