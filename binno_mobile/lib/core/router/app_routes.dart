/// BINNO routes, for the **buyer app only**.
///
/// Two layers:
///  * **Tab roots** live inside the persistent bottom navigation (shell
///    branches); switch between them with `context.go`, stacks are kept.
///  * **Detail screens** live on the root navigator and open above the
///    bottom navigation with `context.push`.
abstract class AppRoutes {
  // ── Tabs ──────────────────────────────────────────────────────────────────
  static const home = '/home';
  static const catalog = '/catalog';
  static const orders = '/orders';
  static const profile = '/profile';

  // ── Discovery ─────────────────────────────────────────────────────────────
  static const search = '/search';
  static const searchResults = '/search/results';
  static const filters = '/search/filters';
  static const complex = '/complex';
  static const store = '/store';
  static const ownerStores = '/store/others';
  static const offer = '/offer';
  static const productRequest = '/product-request';
  static const emptyResults = '/search/empty';
  static const offline = '/offline';

  // ── Order flow ────────────────────────────────────────────────────────────
  static const orderDraft = '/order/draft';
  static const awaiting = '/order/awaiting';
  static const alternatives = '/order/alternatives';
  static const payment = '/order/payment';
  static const orderActive = '/order/active';
  static const refund = '/order/refund';
  static const refundTracker = '/order/refund-tracker';
  static const rating = '/order/rating';

  // ── Communication ─────────────────────────────────────────────────────────
  static const chat = '/chat';
  static const notifications = '/notifications';

  // ── Map ───────────────────────────────────────────────────────────────────
  /// Picking an address on the map. `?lat=&lng=` sets the starting point.
  static const mapPicker = '/map';

  // ── Profile sections ──────────────────────────────────────────────────────
  static const addresses = '/profile/addresses';
  static const profileEdit = '/profile/edit';
  static const legalInfo = '/profile/legal';
  static const language = '/profile/language';
  static const help = '/profile/help';

  // ── Dev ───────────────────────────────────────────────────────────────────
  /// The gallery of all screens. Removed from the production build.
  static const gallery = '/dev';
}
