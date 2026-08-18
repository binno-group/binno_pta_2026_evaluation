sealed class DomainFailure {
  const DomainFailure();
}

final class RateLimitedFailure extends DomainFailure {
  const RateLimitedFailure(this.retryAfter);
  final int retryAfter;
}

final class InvalidCodeFailure extends DomainFailure {
  const InvalidCodeFailure(this.attemptsLeft);
  final int attemptsLeft;
}

final class ExpiredFailure extends DomainFailure {
  const ExpiredFailure();
}

final class TokenReuseDetectedFailure extends DomainFailure {
  const TokenReuseDetectedFailure();
}

final class OfflineFailure extends DomainFailure {
  const OfflineFailure();
}

final class UnauthorizedFailure extends DomainFailure {
  const UnauthorizedFailure();
}

final class UnexpectedFailure extends DomainFailure {
  const UnexpectedFailure();
}
