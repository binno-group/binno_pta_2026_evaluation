// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'BINNO';

  @override
  String get homeTab => 'Bosh sahifa';

  @override
  String get catalogTab => 'Katalog';

  @override
  String get ordersTab => 'Buyurtmalar';

  @override
  String get profileTab => 'Profil';

  @override
  String get notificationsLabel => 'Bildirishnomalar';

  @override
  String get retryAction => 'Qayta urinish';

  @override
  String get emptyExplanation =>
      'Yangi ma\'lumot paydo bo\'lganda shu yerda ko\'rinadi.';

  @override
  String get genericErrorTitle => 'Ma\'lumotni yuklab bo\'lmadi';

  @override
  String get genericErrorExplanation =>
      'Vaqtinchalik xatolik yuz berdi. Qayta urinib ko\'ring.';

  @override
  String get deliveryAddressLabel => 'YETKAZISH MANZILI';

  @override
  String get deliveryAddressValue => 'Amir Temur 108';

  @override
  String get changeAction => 'O\'zgartirish';

  @override
  String get searchHint => 'Sement, armatura, g\'isht...';

  @override
  String get updatedTodayTitle => 'Bugun yangilangan';

  @override
  String get cementProduct => 'M400 sement · 50 kg qop';

  @override
  String get cementSeller => 'Metall Savdo · 47-do\'kon · 6,2 km';

  @override
  String get cementPrice => '48 000';

  @override
  String get priceUnit => 'so\'m / qop';

  @override
  String get rebarProduct => 'Armatura Ø12 · 11,7 m';

  @override
  String get rebarSeller => 'Baraka Qurilish · olib ketish';

  @override
  String get rebarPrice => '96 000';

  @override
  String get categoryCement => 'Sement';

  @override
  String get categoryRebar => 'Armatura';

  @override
  String get categoryBrick => 'G\'isht';

  @override
  String get catalogHeadline => 'M400 sement';

  @override
  String get catalogSummary => '20 taklif · 8 do\'kon';

  @override
  String get catalogSort => 'Narx bo\'yicha, arzonidan';

  @override
  String get cheapestLabel => 'ENG ARZON';

  @override
  String get updatedTodayStatus => 'Bugun yangilangan';

  @override
  String get stalePriceStatus => 'Narx eskirgan bo\'lishi mumkin';

  @override
  String get filterAction => 'Filtrlar';

  @override
  String get activeOrderTitle => 'Yetkazishga tayyorlanmoqda';

  @override
  String get activeOrderSubtitle => 'Sotuvchi 28-iyul ertalabga rejalashtirdi';

  @override
  String get orderConfirmedStatus => 'Sotuvchi tasdiqladi';

  @override
  String get paymentAcceptedStatus => 'To\'lov qabul qilindi';

  @override
  String get deliveredStatus => 'Yetkazildi';

  @override
  String get chatAction => 'Chat';

  @override
  String get reportProblemAction => 'Muammo bor';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileName => 'Aziz Qurilish';

  @override
  String get profilePhone => '+998 90 123 45 67';

  @override
  String get roleSwitcherTitle => 'Rolni almashtirish';

  @override
  String get availableRoles => 'Xaridor / Sotuvchi';

  @override
  String get activeSessionsTitle => 'Faol sessiyalar';

  @override
  String get phoneTitle => 'Telefon raqamingizni kiriting';

  @override
  String get phoneExplanation => 'Tasdiqlash kodi SMS orqali yuboriladi.';

  @override
  String get phoneLabel => 'Telefon raqami';

  @override
  String get phoneHint => '+998 90 123 45 67';

  @override
  String get requestOtpAction => 'Kod olish';

  @override
  String get otpTitle => 'Tasdiqlash kodini kiriting';

  @override
  String get otpExplanation => 'SMS orqali yuborilgan 6 xonali kodni kiriting.';

  @override
  String get otpLabel => 'Tasdiqlash kodi';

  @override
  String get verifyOtpAction => 'Tasdiqlash';

  @override
  String get resendOtpAction => 'Kodni qayta yuborish';

  @override
  String attemptsLeft(int count) {
    return 'Qolgan urinishlar: $count';
  }

  @override
  String retryAfter(int seconds) {
    return '$seconds soniyadan keyin qayta urinishingiz mumkin.';
  }

  @override
  String get otpExpiredTitle => 'Tasdiqlash kodi eskirgan';

  @override
  String get otpExpiredExplanation =>
      'Yangi kod so\'rang va qayta urinib ko\'ring.';

  @override
  String get otpInvalidTitle => 'Tasdiqlash kodi noto\'g\'ri';

  @override
  String get otpInvalidExplanation => 'Kodni tekshirib, qayta kiriting.';

  @override
  String get otpLockedTitle => 'Urinishlar vaqtincha cheklangan';

  @override
  String get otpLockedExplanation =>
      'Xavfsizlik sababli 30 daqiqadan keyin qayta urinishingiz mumkin.';

  @override
  String get registrationTitle => 'Profilni yakunlang';

  @override
  String get nameLabel => 'Ism';

  @override
  String get regionLabel => 'Hudud';

  @override
  String get completeRegistrationAction => 'Ro\'yxatdan o\'tishni yakunlash';

  @override
  String get sessionsEmptyTitle => 'Boshqa faol sessiya yo\'q';

  @override
  String get currentSession => 'Joriy sessiya';

  @override
  String get revokeSessionAction => 'Sessiyani bekor qilish';

  @override
  String get logoutAllAction => 'Barcha sessiyalardan chiqish';

  @override
  String get securityLogoutTitle =>
      'Sessiyalar xavfsizlik sababli bekor qilindi';

  @override
  String get securityLogoutExplanation =>
      'Akkauntingizni himoya qilish uchun qayta kiring.';

  @override
  String get signInAgainAction => 'Qayta kirish';
}
