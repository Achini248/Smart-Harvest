import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_event.dart';
import '../bloc/message_state.dart';
import '../../domain/entities/message.dart';
import 'chat_page.dart';

class MessagesListPage extends StatefulWidget {
  const MessagesListPage({super.key});

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context
          .read<MessageBloc>()
          .add(LoadConversationsEvent(userId: uid));
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search,
                    color: Colors.grey.shade400, size: 20),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Conversations ────────────────────────────────────────
          Expanded(
            child: BlocBuilder<MessageBloc, MessageState>(
              builder: (context, state) {
                if (state is MessageLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen),
                  );
                }

                if (state is MessageEmptyState) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                              Icons.chat_bubble_outline,
                              size: 50,
                              color: AppColors.primaryGreen),
                        ),
                        const SizedBox(height: 16),
                        const Text('No Messages Yet',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text(
                            'Start a conversation with a farmer or buyer.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                if (state is MessageErrorState) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 54, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.primaryGreen),
                          onPressed: () {
                            final uid = FirebaseAuth
                                .instance.currentUser?.uid;
                            if (uid != null) {
                              context.read<MessageBloc>().add(
                                  LoadConversationsEvent(
                                      userId: uid));
                            }
                          },
                          child: const Text('Retry',
                              style:
                                  TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ConversationsLoadedState) {
                  final conversations = _searchQuery.isEmpty
                      ? state.conversations
                      : state.conversations
                          .where((c) => c.otherUserName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();

                  if (conversations.isEmpty) {
                    return Center(
                      child: Text(
                        'No results for "$_searchQuery"',
                        style: const TextStyle(
                            color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (_, i) {
                      final conv = conversations[i];
                      return _ConversationTile(
                        conversation: conv,
                        onTap: () {
                          final uid = FirebaseAuth
                              .instance.currentUser?.uid;
                          if (uid != null) {
                            context.read<MessageBloc>().add(
                                OpenConversationEvent(
                                  conversationId:
                                      conv.conversationId,
                                  currentUserId: uid,
                                ));
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<MessageBloc>(),
                                child: ChatPage(
                                  conversation: conv,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationEntity conversation;
  final VoidCallback onTap;
  const _ConversationTile(
      {required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── Avatar ───────────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      conversation.otherUserAvatar != null
                          ? NetworkImage(
                              conversation.otherUserAvatar!)
                          : null,
                  child: conversation.otherUserAvatar == null
                      ? Text(
                          conversation.otherUserName.isNotEmpty
                              ? conversation
                                  .otherUserName[0]
                                  .toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : null,
                ),
                if (conversation.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // ── Name + last message ───────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.otherUserName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    conversation.lastMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: conversation.unreadCount > 0
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: conversation.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Unread badge ──────────────────────────────────────
            if (conversation.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${conversation.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
