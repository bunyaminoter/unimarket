import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimarket/models/user_model.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final UserModel targetUser;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.targetUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatDetailViewModel>().listenToMessages(widget.chatId);
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatDetailViewModel>().sendMessage(text);
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              radius: 18,
              child: Text(
                widget.targetUser.initials,
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: AppSizes.fontSm,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              widget.targetUser.displayName,
              style: GoogleFonts.poppins(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatDetailViewModel>(
              builder: (context, vm, child) {
                if (vm.messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Sohbet başlatın. Tüm mesajlar uçtan uca şifrelidir.',
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse:
                      true, // En yeni mesaj en altta (listView reverse olduğundan index 0 en altta)
                  padding: const EdgeInsets.all(AppSizes.md),
                  itemCount: vm.messages.length,
                  itemBuilder: (context, index) {
                    final message = vm.messages[index];
                    final isMe = message.senderId == currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSizes.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(AppSizes.radiusLg),
                            topRight: const Radius.circular(AppSizes.radiusLg),
                            bottomLeft: Radius.circular(
                              isMe ? AppSizes.radiusLg : 0,
                            ),
                            bottomRight: Radius.circular(
                              isMe ? 0 : AppSizes.radiusLg,
                            ),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: GoogleFonts.poppins(
                            color: isMe ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // E2EE Info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Mesajlar Uçtan Uca Şifrelenmektedir.',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Message Input
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + AppSizes.sm,
              top: AppSizes.sm,
              left: AppSizes.md,
              right: AppSizes.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _msgController,
                      style: GoogleFonts.poppins(),
                      decoration: const InputDecoration(
                        hintText: 'Mesaj yaz...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
