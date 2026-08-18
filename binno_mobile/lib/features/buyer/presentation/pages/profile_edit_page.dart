import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/theme.dart';
import '../../../app/presentation/widgets/widgets.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/binno_chrome.dart';

/// Editing the user's details.
///
/// The title sits in the app bar (§5). Tapping the avatar opens an
/// iOS-style action sheet: camera or gallery. The chosen image becomes
/// the avatar.
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _name = TextEditingController(text: MockData.buyerName);
  final _phone = TextEditingController(text: MockData.buyerPhone);
  final _email = TextEditingController();

  /// The path of the chosen avatar image (gallery/camera).
  String? _avatarPath;

  bool get _canSave => _name.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _save() {
    binnoSnack(context, 'Ma\'lumotlar saqlandi');
    Navigator.of(context).maybePop();
  }

  /// iOS action sheet — avatar manbasini so'raydi (§5).
  Future<void> _pickAvatar() async {
    final choice = await showCupertinoModalPopup<String>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('Profil rasmi'),
        message: const Text('Rasmni qayerdan olamiz?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop('camera'),
            child: const Text('Kamera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop('gallery'),
            child: const Text('Galereya'),
          ),
          if (_avatarPath != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(sheetContext).pop('remove'),
              child: const Text('Rasmni o\'chirish'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('Bekor qilish'),
        ),
      ),
    );

    if (!mounted || choice == null) return;

    if (choice == 'remove') {
      setState(() => _avatarPath = null);
      return;
    }

    final source =
        choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (!mounted || file == null) return;
      setState(() => _avatarPath = file.path);
    } catch (_) {
      if (!mounted) return;
      binnoSnack(context, 'Rasmni ochib bo\'lmadi — ruxsatni tekshiring');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      background: AppColors.surface,
      child: Column(
        children: [
          // Appbar: orqaga + sarlavha (§5).
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: [
                  InkResponse(
                    onTap: () => Navigator.of(context).maybePop(),
                    radius: 24,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 26,
                        color: AppColors.navy950,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      'Ma\'lumotlarni tahrirlash',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(19),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        _Avatar(path: _avatarPath),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: AppDimens.shadowCard,
                            ),
                            child: const Icon(
                              Icons.photo_camera_rounded,
                              size: 16,
                              color: AppColors.navy950,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _pickAvatar,
                    child: Text('Rasmni o\'zgartirish', style: AppText.link()),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _name,
                  label: 'F.I.Sh.',
                  hint: 'Familiya Ism Sharif',
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phone,
                  label: 'Telefon',
                  hint: '+998 90 000 00 00',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _email,
                  label: 'E-pochta',
                  hint: 'ism@pochta.uz',
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                ),
              ],
            ),
          ),
          BinnoFooter(
            topBorder: true,
            children: [
              AppButton(
                label: 'Saqlash',
                onPressed: _canSave ? _save : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The avatar: shows the image when one is chosen, initials otherwise.
class _Avatar extends StatelessWidget {
  const _Avatar({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.navy950,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: path == null
          ? Text('AK', style: AppText.display(32, color: AppColors.white))
          : Image.file(
              File(path!),
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Text(
                'AK',
                style: AppText.display(32, color: AppColors.white),
              ),
            ),
    );
  }
}
