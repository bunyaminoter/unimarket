import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/chat/viewmodel/chat_viewmodel.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatListViewModel>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mesajlarım',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.fontLg,
          ),
        ),
      ),
      body: Consumer<ChatListViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.chats.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (vm.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Henüz bir mesajın yok.',
                    style: GoogleFonts.poppins(
                      fontSize: AppSizes.fontLg,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: vm.chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = vm.chats[index];
              final otherUser = vm.getOtherParticipantUser(chat.id);
              final userName = otherUser?.displayName ?? 'Yükleniyor...';

              // E2EE olduğu için güvenle gösterebiliriz
              final lastMsg = chat.lastMessage.isEmpty
                  ? 'Görsel veya Dosya'
                  : chat.lastMessage;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  radius: 24,
                  child: Text(
                    otherUser != null ? otherUser.initials : '?',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
                subtitle: Text(
                  lastMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: AppColors.textSecondary),
                ),
                onTap: () {
                  if (otherUser != null) {
                    context.pushNamed(
                      'chatDetail',
                      pathParameters: {'chatId': chat.id},
                      extra: otherUser,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
