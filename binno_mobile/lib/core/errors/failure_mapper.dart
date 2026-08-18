import 'package:binno_app/core/errors/domain_failure.dart';
import 'package:binno_app/core/errors/problem_details.dart';

abstract final class FailureMapper {
  static DomainFailure fromProblem(ProblemDetails problem) {
    final type = problem.type.split('/').last;
    return switch (type) {
      'rate_limited' => RateLimitedFailure(problem.retryAfter ?? 0),
      'invalid_code' => InvalidCodeFailure(problem.attemptsLeft ?? 0),
      'expired' => const ExpiredFailure(),
      'token_reuse_detected' => const TokenReuseDetectedFailure(),
      'unauthorized' => const UnauthorizedFailure(),
      _ => const UnexpectedFailure(),
    };
  }
}
