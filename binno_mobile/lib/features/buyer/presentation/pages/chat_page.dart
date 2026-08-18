import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/binno_chrome.dart';
import '../../../shared/widgets/binno_states.dart';
import '../../../shared/widgets/binno_store.dart';

/// Messaging with the store.
///
/// Chat is a channel for questions, not for making deals: the price is
/// fixed and there is no bargaining flow. Order state changes only through
/// the state machine.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final List<MockMessage> _messages =
      List<MockMessage>.from(MockData.chatMessages);

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(MockMessage(text: text, time: 'hozir', mine: true));
      _controller.clear();
    });
    // Yangi xabar ko'rinadigan joyga tushsin.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: AppDimens.motionBase,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const store = MockData.metallSavdo;

    return BinnoScreen(
      background: AppColors.surface,
      child: Column(
        children: [
          Container(
            color: AppColors.white,
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      children: [
                        InkResponse(
                          onTap: () => Navigator.of(context).maybePop(),
                          radius: 24,
                          child: const SizedBox(
                            width: AppDimens.hTapTarget,
                            height: AppDimens.hTapTarget,
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 26,
                              color: AppColors.navy950,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: BinnoStoreIdentity(
                            storeName: store.name,
                            locationLine: store.locationChain,
                            verified: store.verified,
                            initials: store.initials,
                            avatarSize: 42,
                            trailing: InkWell(
                              onTap: () => context.push(AppRoutes.store),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 12,
                                ),
                                child: Text(
                                  'Do\'kon',
                                  style: AppText.link(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const BinnoHairline(),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              children: [
                const _DayLabel('Bugun'),
                const SizedBox(height: 14),
                const _OrderContextCard(),
                const SizedBox(height: 16),
                for (final message in _messages) ...[
                  _Bubble(message: message),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          _Composer(controller: _controller, onSend: _send),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(AppDimens.rPill),
        ),
        child: Text(text, style: AppText.note()),
      ),
    );
  }
}

/// Keeps the conversation context: which order is being discussed.
class _OrderContextCard extends StatelessWidget {
  const _OrderContextCard();

  @override
  Widget build(BuildContext context) {
    return BinnoSoftCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      radius: AppDimens.rField,
      child: Row(
        children: [
          const BinnoThumb(label: 'M400', size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${MockData.orderId} · M400 sement, '
                  '${MockData.orderQty} qop',
                  style: AppText.s(13, FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sotuvchi tasdig\'ini kutmoqda',
                  style: AppText.meta(size: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final MockMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;

    return Row(
      mainAxisAlignment:
          mine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            decoration: BoxDecoration(
              color: mine ? AppColors.navy950 : AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppDimens.rTile),
                topRight: const Radius.circular(AppDimens.rTile),
                bottomLeft: Radius.circular(mine ? AppDimens.rTile : 4),
                bottomRight: Radius.circular(mine ? 4 : AppDimens.rTile),
              ),
              border: mine
                  ? null
                  : Border.all(color: AppColors.edge, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  style: AppText.s(
                    14,
                    FontWeight.w400,
                    height: 1.45,
                    color: mine ? AppColors.white : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: AppText.s(
                    10,
                    FontWeight.w400,
                    color: mine ? AppColors.onNavyMeta : AppColors.ink3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(AppDimens.rCardSm),
                  ),
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppText.s(14, FontWeight.w400),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Xabar yozing…',
                      hintStyle: AppText.s(
                        14,
                        FontWeight.w400,
                        color: AppColors.ink3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: AppColors.navy950,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onSend,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      size: 21,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
