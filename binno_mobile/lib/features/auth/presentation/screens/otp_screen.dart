import 'package:binno_app/design_system/components/binno_button.dart';
import 'package:binno_app/design_system/components/binno_text_field.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:binno_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    if (state is! OtpEntryState) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final errorText = _errorText(l10n, state);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(BinnoSpacing.x6),
          children: [
            Text(
              l10n.otpTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: BinnoSpacing.x2),
            Text(l10n.otpExplanation),
            const SizedBox(height: BinnoSpacing.x6),
            AutofillGroup(
              child: BinnoTextField(
                controller: _codeController,
                label: l10n.otpLabel,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: BinnoSpacing.x2),
              Text(errorText),
            ],
            if (state.attemptsLeft case final attempts?) ...[
              const SizedBox(height: BinnoSpacing.x2),
              Text(l10n.attemptsLeft(attempts)),
            ],
            if (state.challenge.retryAfter > 0) ...[
              const SizedBox(height: BinnoSpacing.x2),
              Text(l10n.retryAfter(state.challenge.retryAfter)),
            ],
            const SizedBox(height: BinnoSpacing.x6),
            BinnoButton(
              label: l10n.verifyOtpAction,
              state: state.submitting
                  ? BinnoButtonState.submitting
                  : BinnoButtonState.idle,
              onPressed: () => ref
                  .read(authControllerProvider.notifier)
                  .verifyOtp(_codeController.text),
            ),
            const SizedBox(height: BinnoSpacing.x2),
            TextButton(
              onPressed: state.challenge.retryAfter == 0 ? () {} : null,
              child: Text(l10n.resendOtpAction),
            ),
          ],
        ),
      ),
    );
  }

  String? _errorText(AppLocalizations l10n, OtpEntryState state) {
    return switch (state.error) {
      OtpError.invalid =>
        '${l10n.otpInvalidTitle}. ${l10n.otpInvalidExplanation}',
      OtpError.expired =>
        '${l10n.otpExpiredTitle}. ${l10n.otpExpiredExplanation}',
      OtpError.locked => '${l10n.otpLockedTitle}. ${l10n.otpLockedExplanation}',
      OtpError.rateLimited => l10n.retryAfter(state.challenge.retryAfter),
      OtpError.unexpected => l10n.genericErrorExplanation,
      null => null,
    };
  }
}
