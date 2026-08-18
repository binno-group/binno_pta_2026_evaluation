import '../../src.dart';

/// The request/error interception point for the Dio client.
///
/// Empty in the mock stage; authentication headers and error mapping land
/// here once the app is wired to the backend API.
class DioInterceptors extends Interceptor {}
