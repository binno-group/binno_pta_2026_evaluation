import 'package:binno_app/design_system/components/binno_button.dart';
import 'package:binno_app/design_system/components/binno_text_field.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:binno_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _regionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final submitting = state is RegistrationEntryState && state.submitting;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(BinnoSpacing.x6),
          children: [
            Text(
              l10n.registrationTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: BinnoSpacing.x6),
            BinnoTextField(
              controller: _nameController,
              label: l10n.nameLabel,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: BinnoSpacing.x4),
            BinnoTextField(
              controller: _regionController,
              label: l10n.regionLabel,
            ),
            const SizedBox(height: BinnoSpacing.x6),
            BinnoButton(
              label: l10n.completeRegistrationAction,
              state: submitting
                  ? BinnoButtonState.submitting
                  : BinnoButtonState.idle,
              onPressed: () => ref
                  .read(authControllerProvider.notifier)
                  .completeRegistration(
                    _nameController.text,
                    _regionController.text,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
