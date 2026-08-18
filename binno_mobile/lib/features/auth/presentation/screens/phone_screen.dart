import 'package:binno_app/core/auth_session/auth_session.dart';
import 'package:binno_app/design_system/components/binno_button.dart';
import 'package:binno_app/design_system/components/binno_error_state.dart';
import 'package:binno_app/design_system/components/binno_reference_components.dart';
import 'package:binno_app/design_system/components/binno_text_field.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:binno_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:binno_app/features/auth/presentation/screens/registration_screen.dart';
import 'package:binno_app/features/auth/presentation/widgets/phone_input_formatter.dart';
import 'package:binno_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final session = ref.watch(authSessionProvider);
    final l10n = AppLocalizations.of(context);
    if (session.status == AuthSessionStatus.securityLogout) {
      return Scaffold(
        body: BinnoErrorState(
          title: l10n.securityLogoutTitle,
          explanation: l10n.securityLogoutExplanation,
          actionLabel: l10n.signInAgainAction,
          onRetry: () => session.clear(),
        ),
      );
    }
    return switch (state) {
      OtpEntryState() => const OtpScreen(),
      RegistrationEntryState() => const RegistrationScreen(),
      AuthenticatedState() => const SizedBox.shrink(),
      PhoneEntryState(:final submitting) => _PhoneForm(
          controller: _phoneController,
          submitting: submitting,
          onSubmit: () => ref
              .read(authControllerProvider.notifier)
              .requestOtp(_phoneController.text),
        ),
    };
  }
}

class _PhoneForm extends StatelessWidget {
  const _PhoneForm({
    required this.controller,
    required this.submitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            BinnoHeroHeader(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName.toLowerCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 72),
                  Text(
                    l10n.phoneTitle,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: colors.onPrimary,
                        ),
                  ),
                  const SizedBox(height: BinnoSpacing.x2),
                  Text(
                    l10n.phoneExplanation,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.72),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BinnoSpacing.x6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BinnoSpacing.x6),
              child: AutofillGroup(
                child: BinnoTextField(
                  controller: controller,
                  label: l10n.phoneLabel,
                  hint: l10n.phoneHint,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [PhoneInputFormatter()],
                ),
              ),
            ),
            const SizedBox(height: BinnoSpacing.x6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BinnoSpacing.x6),
              child: BinnoButton(
                label: l10n.requestOtpAction,
                state: submitting
                    ? BinnoButtonState.submitting
                    : BinnoButtonState.idle,
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
