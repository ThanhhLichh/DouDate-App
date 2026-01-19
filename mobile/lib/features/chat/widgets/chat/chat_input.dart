import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/conversation_controller.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isSending;

  const ChatInput({super.key, required this.onSend, this.isSending = false});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _textController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _hasText = _textController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_hasText && !widget.isSending) {
      final text = _textController.text.trim();
      _textController.clear();
      widget.onSend(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Chỉ select quickEmoji từ ConversationController
    final quickEmoji = context.select<ConversationController, String>(
      (c) => c.settings?.quickEmoji ?? '❤️',
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(12),
        vertical: context.space(8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Camera button - dùng read() thay vì watch()
            _CameraButton(isSending: widget.isSending),

            // Image picker button
            _ImagePickerButton(isSending: widget.isSending),

            // Text input
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(16),
                  vertical: context.space(8),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(context.space(20)),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: context.sp(AppDimensions.fontS)),
                  decoration: InputDecoration(
                    hintText: 'Aa',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: context.sp(AppDimensions.fontS),
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),

            ResponsiveHelper.horizontalSpace(context, AppDimensions.spaceS),

            // Send button or Quick Emoji button
            GestureDetector(
              onTap: _hasText
                  ? _handleSend
                  : (widget.isSending ? null : () => widget.onSend(quickEmoji)),
              child: Container(
                width: context.space(36),
                height: context.space(36),
                decoration: BoxDecoration(
                  color: _hasText
                      ? const Color(0xFF0084FF)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: widget.isSending
                    ? Padding(
                        padding: EdgeInsets.all(context.space(8)),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : _hasText
                    ? Icon(
                        Icons.send,
                        color: Colors.white,
                        size: context.space(18),
                      )
                    : Text(
                        quickEmoji,
                        style: TextStyle(fontSize: AppDimensions.iconS),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tách riêng camera button để tránh rebuild
class _CameraButton extends StatelessWidget {
  final bool isSending;

  const _CameraButton({required this.isSending});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.camera_alt,
        color: const Color(0xFF0084FF),
        size: context.space(AppDimensions.iconM),
      ),
      onPressed: isSending
          ? null
          : () => context.read<ChatController>().sendImageFromCamera(),
    );
  }
}

// Tách riêng image picker button
class _ImagePickerButton extends StatelessWidget {
  final bool isSending;

  const _ImagePickerButton({required this.isSending});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.photo,
        color: const Color(0xFF0084FF),
        size: context.space(AppDimensions.iconM),
      ),
      onPressed: isSending
          ? null
          : () => context.read<ChatController>().sendImagesFromGallery(),
    );
  }
}
