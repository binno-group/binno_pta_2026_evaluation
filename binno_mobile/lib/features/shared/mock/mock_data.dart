import '../widgets/binno_labels.dart';

/// Static data for the mock stage.
///
/// The data looks **real**: actual product names (M400 cement, rebar Ø12),
/// prices ending in 000, real place names. No lorem, `$0`, or `0.0 ★`.
///
/// Once the API is ready this file is replaced by a repository in the
/// `data/` layer; the screens stay unchanged.
class MockStore {
  const MockStore({
    required this.name,
    required this.unitNumber,
    this.complex,
    this.block,
    this.verified = false,
    this.rating = 0,
    this.reviewCount = 0,
    this.responseMinutes = 30,
    this.responseSamples = 0,
    this.phone,
    this.initials,
  });

  final String name;

  /// e.g. "47-do'kon".
  final String unitNumber;

  /// e.g. "Qo'yliq"; `null` for a standalone store.
  final String? complex;

  /// e.g. "B-blok".
  final String? block;

  final bool verified;
  final double rating;
  final int reviewCount;
  final int responseMinutes;
  final int responseSamples;
  final String? phone;
  final String? initials;

  /// e.g. "Metall Savdo · 47-do'kon".
  String get title => '$name · $unitNumber';

  /// e.g. "Qo'yliq, B-blok, 47-do'kon"; a standalone store gets just the unit.
  String get locationChain {
    if (complex == null) return unitNumber;
    if (block == null) return '$complex, $unitNumber';
    return '$complex, $block, $unitNumber';
  }

  /// e.g. "Qo'yliq, B-blok".
  String get complexBlock {
    if (complex == null) return '';
    if (block == null) return complex!;
    return '$complex, $block';
  }

  bool get isNew => reviewCount < 3;
}

class MockOffer {
  const MockOffer({
    required this.store,
    required this.productTitle,
    required this.thumbLabel,
    required this.price,
    required this.unit,
    required this.declaredQty,
    this.freshness = BinnoFreshness.normal,
    this.deliveryFee,
    this.pickupAvailable = false,
    this.distanceKm,
    this.updatedLabel,
  });

  final MockStore store;
  final String productTitle;
  final String thumbLabel;
  final int price;
  final String unit;
  final int declaredQty;
  final BinnoFreshness freshness;

  /// The zone tariff, set per store. `null` means pickup only.
  final int? deliveryFee;

  final bool pickupAvailable;
  final double? distanceKm;

  /// e.g. "Bugun 08:20", "6 kun oldin".
  final String? updatedLabel;

  bool get deliveryOnly => deliveryFee != null && !pickupAvailable;
}

abstract class MockData {
  // ── Stores ────────────────────────────────────────────────────────────────
  static const metallSavdo = MockStore(
    name: 'Metall Savdo',
    unitNumber: '47-do\'kon',
    complex: 'Qo\'yliq',
    block: 'B-blok',
    verified: true,
    rating: 4.8,
    reviewCount: 36,
    responseMinutes: 30,
    responseSamples: 34,
    phone: '+998 71 200 40 40',
    initials: 'MS',
  );

  static const barakaQurilish = MockStore(
    name: 'Baraka Qurilish',
    unitNumber: '9-do\'kon',
    complex: 'Qo\'yliq',
    block: 'A-blok',
    rating: 0,
    reviewCount: 0,
    responseMinutes: 25,
    responseSamples: 7,
    initials: 'BQ',
  );

  static const sardorSavdo = MockStore(
    name: 'Sardor Savdo',
    unitNumber: '51-do\'kon',
    complex: 'Qo\'yliq',
    block: 'A-blok',
    rating: 4.3,
    reviewCount: 8,
    responseMinutes: 45,
    responseSamples: 8,
    initials: 'SS',
  );

  static const nurliBeton = MockStore(
    name: 'Nurli Beton',
    unitNumber: '14-do\'kon',
    complex: 'Qo\'yliq',
    block: 'A-blok',
    rating: 4.6,
    reviewCount: 12,
    responseMinutes: 50,
    responseSamples: 12,
    initials: 'NB',
  );

  static const nurliMetall = MockStore(
    name: 'Nurli Metall',
    unitNumber: '4-do\'kon',
    complex: 'Sergeli bozori',
    block: 'A-blok',
    rating: 0,
    reviewCount: 0,
    initials: 'NM',
  );

  /// Other outlets of the Baraka Qurilish owner.
  /// Each is a separate store: ratings and stock are not merged.
  static const barakaD = MockStore(
    name: 'Baraka Qurilish',
    unitNumber: '22-do\'kon',
    complex: 'Qo\'yliq',
    block: 'D-blok',
    rating: 4.2,
    reviewCount: 6,
    responseMinutes: 35,
    responseSamples: 6,
    initials: 'BQ',
  );

  static const barakaSergeli = MockStore(
    name: 'Baraka Qurilish',
    unitNumber: '7-do\'kon',
    complex: 'Sergeli bozori',
    block: 'B-blok',
    rating: 0,
    reviewCount: 0,
    initials: 'BQ',
  );

  static const metallSavdo12 = MockStore(
    name: 'Metall Savdo',
    unitNumber: '12-do\'kon',
    complex: 'Qo\'yliq',
    block: 'D-blok',
    rating: 4.5,
    reviewCount: 14,
    responseMinutes: 40,
    responseSamples: 14,
    initials: 'MS',
  );

  // ── Offers ────────────────────────────────────────────────────────────────
  static const cementMetall = MockOffer(
    store: metallSavdo,
    productTitle: 'M400 sement, 50 kg qop',
    thumbLabel: 'M400',
    price: 48000,
    unit: 'qop',
    declaredQty: 120,
    freshness: BinnoFreshness.fresh,
    deliveryFee: 120000,
    distanceKm: 6.2,
    updatedLabel: 'Bugun 08:20',
  );

  static const cementBaraka = MockOffer(
    store: barakaQurilish,
    productTitle: 'M400 sement, 50 kg qop',
    thumbLabel: 'M400',
    price: 49500,
    unit: 'qop',
    declaredQty: 340,
    freshness: BinnoFreshness.fresh,
    deliveryFee: 120000,
    pickupAvailable: true,
    distanceKm: 6.4,
  );

  static const cementSardor = MockOffer(
    store: sardorSavdo,
    productTitle: 'M400 sement, 50 kg qop',
    thumbLabel: 'M400',
    price: 45000,
    unit: 'qop',
    declaredQty: 80,
    freshness: BinnoFreshness.stale,
    pickupAvailable: true,
    distanceKm: 7.1,
  );

  static const cementNurli = MockOffer(
    store: nurliBeton,
    productTitle: 'M400 sement, 50 kg qop',
    thumbLabel: 'M400',
    price: 50000,
    unit: 'qop',
    declaredQty: 210,
    freshness: BinnoFreshness.expired,
    deliveryFee: 130000,
    distanceKm: 8.4,
    updatedLabel: '6 kun oldin',
  );

  /// Metall Savdo's own rebar; this is what the store page shows.
  static const armaturaMetall = MockOffer(
    store: metallSavdo,
    productTitle: 'Armatura Ø12 · 11,7 m',
    thumbLabel: 'Ø12',
    price: 94000,
    unit: 'dona',
    declaredQty: 480,
    freshness: BinnoFreshness.fresh,
    deliveryFee: 120000,
    distanceKm: 6.2,
    updatedLabel: 'Bugun 08:20',
  );

  /// The "2 more stores" case: one owner, three different outlets.
  static const cementBarakaD = MockOffer(
    store: barakaD,
    productTitle: 'M400 sement, 50 kg qop',
    thumbLabel: 'M400',
    price: 50500,
    unit: 'qop',
    declaredQty: 160,
    freshness: BinnoFreshness.normal,
    deliveryFee: 140000,
    distanceKm: 7.8,
    updatedLabel: '2 kun oldin',
  );

  static const cementBarakaSergeli = MockOffer(
    store: barakaSergeli,
    productTitle: 'M400 sement, 50 kg qop',
    thumbLabel: 'M400',
    price: 49000,
    unit: 'qop',
    declaredQty: 95,
    freshness: BinnoFreshness.stale,
    pickupAvailable: true,
    distanceKm: 12.4,
    updatedLabel: '4 kun oldin',
  );

  static const armaturaBaraka = MockOffer(
    store: barakaQurilish,
    productTitle: 'Armatura Ø12 · 11,7 m',
    thumbLabel: 'Ø12',
    price: 96000,
    unit: 'dona',
    declaredQty: 640,
    freshness: BinnoFreshness.fresh,
    pickupAvailable: true,
  );

  /// Search results, sorted by price, cheapest first.
  static const searchResults = <MockOffer>[
    cementSardor,
    cementMetall,
    cementBaraka,
    cementNurli,
  ];

  /// All stores for the global search "Stores" tab.
  static const allStores = <MockStore>[
    metallSavdo,
    barakaQurilish,
    sardorSavdo,
    nurliBeton,
    metallSavdo12,
    barakaD,
    barakaSergeli,
    nurliMetall,
  ];

  /// Assorted products for the global search "Products" tab.
  static const allProducts = <MockOffer>[
    cementMetall,
    armaturaMetall,
    cementBaraka,
    armaturaBaraka,
    cementSardor,
    cementBarakaD,
    cementNurli,
    cementBarakaSergeli,
  ];

  /// The complex page, grouped by block.
  static const complexGroups = <String, List<MockOffer>>{
    'A-blok': [cementSardor, cementBaraka],
    'B-blok': [cementMetall],
  };

  // ── Order ─────────────────────────────────────────────────────────────────
  static const orderId = '#A-4821';
  static const orderQty = 40;
  static const goodsAmount = 1920000; // 40 × 48 000
  static const deliveryFee = 120000;
  static const totalAmount = 2040000; // total = goods + delivery

  static const invoiceNumber = 'BIN-202607-00142';
  static const buyerName = 'Aziz Karimov';
  static const buyerPhone = '+998 90 123 45 67';
  static const buyerAddress = 'Amir Temur 108';
  static const buyerDistrict = 'Yunusobod t.';
  static const deliveryDate = '28-iyul, ertalab';
  static const buyerTin = '305 812 447';

  static const refundQty = 6;
  static const refundAmount = 288000; // 6 × 48 000

  // ── Categories ────────────────────────────────────────────────────────────
  /// Only categories with live offers are shown (§4.4).
  /// Order matters: the first four appear on the home page (3D-style
  /// icons), the rest in the catalogue. Each carries an image icon.
  static const categories = <MockCategory>[
    MockCategory('Sement', 128, 'assets/products/sement.png'),
    MockCategory('Armatura', 96, 'assets/products/armatura.png'),
    MockCategory('G\'isht', 74, 'assets/products/gisht.png'),
    MockCategory('Bo\'yoq', 42, 'assets/products/boyoq.png'),
    MockCategory('Metallprokat', 38, 'assets/products/metallprokat.png'),
    MockCategory('Izolyatsiya', 27, 'assets/products/izolyatsiya.png'),
    MockCategory('Keramika', 31, 'assets/products/keramika.png'),
    MockCategory('Gilam', 34, 'assets/products/gilam.png'),
  ];

  /// Image icon by product label (thumbLabel), used on offer cards.
  static String? productAsset(String thumbLabel) {
    if (thumbLabel.startsWith('Ø')) return 'assets/products/armatura.png';
    if (thumbLabel.startsWith('M400') || thumbLabel.startsWith('M5')) {
      return 'assets/products/sement.png';
    }
    if (thumbLabel.startsWith('M1')) return 'assets/products/gisht.png';
    if (thumbLabel.startsWith('QQ')) return 'assets/products/sement.png';
    return null;
  }

  static const complexes = <MockComplex>[
    MockComplex(
      name: 'Qo\'yliq qurilish bozori',
      district: 'Yashnobod t.',
      blockCount: 4,
      storeCount: 86,
      offerCount: 312,
    ),
    MockComplex(
      name: 'Sergeli bozori',
      district: 'Sergeli t.',
      blockCount: 3,
      storeCount: 41,
      offerCount: 158,
    ),
    MockComplex(
      name: 'Chilonzor qurilish saroyi',
      district: 'Chilonzor t.',
      blockCount: 2,
      storeCount: 28,
      offerCount: 94,
    ),
  ];

  // ── Buyer orders ──────────────────────────────────────────────────────────
  static const buyerOrders = <MockOrderSummary>[
    MockOrderSummary(
      id: orderId,
      product: 'M400 sement · 40 qop',
      thumbLabel: 'M400',
      storeTitle: 'Metall Savdo · 47-do\'kon',
      dateLabel: '25-iyul, 09:38',
      total: totalAmount,
      state: MockOrderState.preparing,
    ),
    MockOrderSummary(
      id: '#A-4818',
      product: 'Armatura Ø12 · 120 dona',
      thumbLabel: 'Ø12',
      storeTitle: 'Baraka Qurilish · 9-do\'kon',
      dateLabel: '25-iyul, 08:05',
      total: 11520000,
      state: MockOrderState.awaitingConfirmation,
    ),
    // Awaiting payment: confirmed but not yet paid (§5.3).
    MockOrderSummary(
      id: '#A-4816',
      product: 'Quruq qorishma · 60 qop',
      thumbLabel: 'QQ',
      storeTitle: 'Nurli Beton · 14-do\'kon',
      dateLabel: '25-iyul, 07:40',
      total: 1980000,
      state: MockOrderState.awaitingPayment,
    ),
    MockOrderSummary(
      id: '#A-4809',
      product: 'M400 sement · 25 qop',
      thumbLabel: 'M400',
      storeTitle: 'Baraka Qurilish · 22-do\'kon',
      dateLabel: '24-iyul, 16:10',
      total: 1402500,
      state: MockOrderState.delivering,
    ),
    MockOrderSummary(
      id: '#A-4790',
      product: 'M400 sement · 40 qop',
      thumbLabel: 'M400',
      storeTitle: 'Metall Savdo · 47-do\'kon',
      dateLabel: '22-iyul',
      total: 2040000,
      state: MockOrderState.refund,
    ),
    MockOrderSummary(
      id: '#A-4702',
      product: 'G\'isht M150 · 2 000 dona',
      thumbLabel: 'M150',
      storeTitle: 'Sardor Savdo · 51-do\'kon',
      dateLabel: '14-iyul',
      total: 3600000,
      state: MockOrderState.closed,
    ),
  ];

  // ── Delivery addresses ────────────────────────────────────────────────────
  static const addresses = <MockAddress>[
    MockAddress(
      label: 'Uy',
      line: 'Amir Temur 108, 42-xonadon',
      district: 'Yunusobod t.',
      receiver: 'Aziz · +998 90 123 45 67',
      latitude: 41.352810,
      longitude: 69.288940,
      isDefault: true,
    ),
    MockAddress(
      label: 'Obyekt',
      line: 'Chinobod 14, qurilish maydoni',
      district: 'Mirzo Ulug\'bek t.',
      receiver: 'Jasur usta · +998 93 445 12 08',
      latitude: 41.324700,
      longitude: 69.334500,
    ),
  ];

  // ── Notifications ─────────────────────────────────────────────────────────
  static const notifications = <MockNotification>[
    MockNotification(
      title: 'Sotuvchi buyurtmani tasdiqladi',
      body: 'Metall Savdo · 47-do\'kon — 40 qop mavjud. '
          'To\'lov varaqasi tayyor.',
      time: 'Bugun 10:04',
      kind: MockNotificationKind.order,
      unread: true,
    ),
    MockNotification(
      title: 'To\'lov varaqasi 24 soatdan keyin tugaydi',
      body: 'BIN-202607-00142 · 2 040 000 so\'m. '
          'Muddat tugasa zaxira bo\'shatiladi.',
      time: 'Bugun 09:12',
      kind: MockNotificationKind.payment,
      unread: true,
    ),
    MockNotification(
      title: 'Bu do\'kon tasdiqlamadi',
      body: 'Armatura Ø12 buyurtmasi bo\'yicha yaqin muqobillar tayyor — '
          'tanlovni siz qilasiz.',
      time: 'Kecha 16:40',
      kind: MockNotificationKind.order,
    ),
    MockNotification(
      title: 'Narx yangilandi',
      body: 'Kuzatuvdagi M400 sement 49 500 dan 48 000 so\'mga tushdi.',
      time: '26-iyul',
      kind: MockNotificationKind.price,
    ),
    MockNotification(
      title: 'Qaytarish muddati o\'tdi',
      body: 'Sotuvchining qaytarish majburiyati: 3 ish kuni. '
          'Operator tekshiruvga oldi.',
      time: '25-iyul',
      kind: MockNotificationKind.refund,
    ),
  ];

  // ── Chat ──────────────────────────────────────────────────────────────────
  static const chatMessages = <MockMessage>[
    MockMessage(
      text: 'Assalomu alaykum. 40 qop M400 bugun tayyor bo\'ladimi?',
      time: '09:41',
      mine: true,
    ),
    MockMessage(
      text: 'Va alaykum assalom. Ha, qoldiq bor. Ertalabga yuklaymiz.',
      time: '09:46',
    ),
    MockMessage(
      text: 'Yetkazish Yunusobodga qancha turadi?',
      time: '09:47',
      mine: true,
    ),
    MockMessage(
      text: 'Yunusobod tumani bo\'yicha 120 000 so\'m — tarif qat\'iy, '
          'buyurtmada ham shu summa chiqadi.',
      time: '09:52',
    ),
    MockMessage(
      text: 'Yaxshi, buyurtma beraman.',
      time: '09:55',
      mine: true,
    ),
  ];

  // ── Store reviews ─────────────────────────────────────────────────────────
  static const reviews = <MockReview>[
    MockReview(
      author: 'Jasur N.',
      rating: 5,
      text: 'Qop butun keldi, tortib ko\'rdim — vazni joyida. '
          'Vaqtida yetkazishdi.',
      date: '24-iyul',
    ),
    MockReview(
      author: 'Otabek R.',
      rating: 4,
      text: 'Narx yaxshi. Yetkazish kelishilgan vaqtdan 2 soat kechikdi.',
      date: '19-iyul',
    ),
    MockReview(
      author: 'Aziz K.',
      rating: 5,
      text: 'Ikkinchi marta olyapman. Qoldiq har doim yangilangan turadi.',
      date: '11-iyul',
    ),
  ];

  // ── Search ────────────────────────────────────────────────────────────────
  static const recentSearches = <String>[
    'M400 sement',
    'armatura Ø12',
    'g\'isht M150',
    'keramik plita 60×60',
  ];

  static const popularSearches = <String>[
    'M400 sement',
    'M500 sement',
    'Armatura Ø12',
    'Armatura Ø10',
    'G\'isht M150',
    'Quruq qorishma',
    'Profnastil',
    'Penoplast',
  ];

  // ── Languages ─────────────────────────────────────────────────────────────
  static const languages = <MockLanguage>[
    MockLanguage(code: 'uz', name: 'O\'zbekcha', native: 'Lotin'),
    MockLanguage(code: 'uz-Cyrl', name: 'Ўзбекча', native: 'Кирилл'),
    MockLanguage(code: 'ru', name: 'Русский', native: 'Rus tili'),
  ];

  // ── Help ──────────────────────────────────────────────────────────────────
  static const helpTopics = <MockHelpTopic>[
    MockHelpTopic(
      question: 'To\'lov qayerga tushadi?',
      answer: 'To\'lov to\'g\'ridan-to\'g\'ri sotuvchi hisobiga o\'tadi. '
          'BINNO pul ushlamaydi va hisobingizda saqlamaydi. Shuning uchun '
          'kvitansiya — nizoda sizning asosiy dalilingiz.',
    ),
    MockHelpTopic(
      question: 'Nega yetkazish vaqti aniq ko\'rsatilmaydi?',
      answer: 'Platforma bilmagan narsani da\'vo qilmaydi. Biz sotuvchi '
          'e\'lon qilgan sanani va holat bosqichlarini ko\'rsatamiz; '
          'daqiqali hisob yoki jonli kuzatuv yo\'q.',
    ),
    MockHelpTopic(
      question: '"E\'lon qilingan qoldiq" nima degani?',
      answer: 'Bu — sotuvchining o\'zi kiritgan miqdor. Platforma uni '
          'omborda tekshirmaydi. Haqiqiy tekshiruv nuqtasi — sotuvchi '
          'buyurtmani tasdiqlagan payt.',
    ),
    MockHelpTopic(
      question: 'Sotuvchi javob bermasa nima bo\'ladi?',
      answer: 'Tasdiqlash oynasi — 4 ish soati. Bu vaqtda sotuvchiga push, '
          'keyin SMS, so\'ng operator qo\'ng\'irog\'i boradi. Javob '
          'bo\'lmasa sizga yaqin muqobillar ro\'yxati chiqadi va tanlovni '
          'siz qilasiz — tizim o\'zi boshqa do\'konga o\'tkazmaydi.',
    ),
    MockHelpTopic(
      question: 'Pulni qanday qaytaraman?',
      answer: 'Qaytarish — sotuvchining oferta majburiyati: 3 ish kuni '
          'ichida bank orqali qaytaradi va kvitansiya yuklaydi. Operator '
          'tekshiradi, siz tasdiqlaganingizdan keyin nizo yopiladi.',
    ),
    MockHelpTopic(
      question: 'Narx nega o\'zgarib turadi?',
      answer: 'Narx buyurtma yaratilgan payt fiksatsiya qilinadi va '
          'keyin o\'zgarmaydi. Ro\'yxatdagi narx esa sotuvchi oxirgi marta '
          'yangilagan qiymat — shuning uchun eskirgan e\'lonlar '
          'ogohlantirish bilan pastda turadi.',
    ),
  ];
}

class MockAddress {
  const MockAddress({
    required this.label,
    required this.line,
    required this.district,
    required this.receiver,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  final String label;
  final String line;
  final String district;
  final String receiver;

  /// The zone tariff and the search centre are computed from this point (§4.1).
  final double latitude;
  final double longitude;

  final bool isDefault;
}

enum MockNotificationKind { order, payment, refund, price }

class MockNotification {
  const MockNotification({
    required this.title,
    required this.body,
    required this.time,
    required this.kind,
    this.unread = false,
  });

  final String title;
  final String body;
  final String time;
  final MockNotificationKind kind;
  final bool unread;
}

class MockMessage {
  const MockMessage({
    required this.text,
    required this.time,
    this.mine = false,
  });

  final String text;
  final String time;

  /// `true` when the buyer wrote the message.
  final bool mine;
}

class MockReview {
  const MockReview({
    required this.author,
    required this.rating,
    required this.text,
    required this.date,
  });

  final String author;
  final int rating;
  final String text;
  final String date;
}

class MockLanguage {
  const MockLanguage({
    required this.code,
    required this.name,
    required this.native,
  });

  final String code;
  final String name;
  final String native;
}

class MockHelpTopic {
  const MockHelpTopic({required this.question, required this.answer});

  final String question;
  final String answer;
}

class MockCategory {
  const MockCategory(this.name, this.offerCount, this.asset);

  final String name;
  final int offerCount;

  /// The category icon, `assets/products/<name>.png`.
  final String asset;
}

class MockComplex {
  const MockComplex({
    required this.name,
    required this.district,
    required this.blockCount,
    required this.storeCount,
    required this.offerCount,
    this.latitude = 41.253100,
    this.longitude = 69.334200,
  });

  final String name;
  final String district;
  final int blockCount;
  final int storeCount;
  final int offerCount;

  /// The complex centre; the shared pickup point is around here.
  final double latitude;
  final double longitude;

  String get summary =>
      '$blockCount blok · $storeCount do\'kon · $offerCount taklif';
}

/// Order state: the UI projection of the Master Spec §5.1 state machine.
enum MockOrderState {
  awaitingConfirmation,
  awaitingPayment,
  preparing,
  delivering,
  refund,
  closed,
}

class MockOrderSummary {
  const MockOrderSummary({
    required this.id,
    required this.product,
    required this.thumbLabel,
    required this.storeTitle,
    required this.dateLabel,
    required this.total,
    required this.state,
  });

  final String id;
  final String product;
  final String thumbLabel;

  /// The store name for the buyer; the buyer's name and district for the seller.
  final String storeTitle;

  final String dateLabel;
  final int total;
  final MockOrderState state;

  bool get isActive => state != MockOrderState.closed;
}
