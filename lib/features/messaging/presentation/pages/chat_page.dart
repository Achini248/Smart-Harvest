import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_event.dart';
import '../bloc/message_state.dart';
import '../widgets/message_bubble.dart';
import '../../domain/entities/message.dart';

class ChatPage extends StatefulWidget {
  final ConversationEntity conversation;
  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  String get _currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _currentUserName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'Me';

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    context.read<MessageBloc>().add(SendMessageEvent(
          message: MessageEntity(
            id: '',
            conversationId: widget.conversation.conversationId,
            senderId: _currentUserId,
            senderName: _currentUserName,
            receiverId: widget.conversation.otherUserId,
            receiverName: widget.conversation.otherUserName,
            content: text,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        ));
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      widget.conversation.otherUserAvatar != null
                          ? NetworkImage(
                              widget.conversation.otherUserAvatar!)
                          : null,
                  child:
                      widget.conversation.otherUserAvatar == null
                          ? Text(
                              widget.conversation.otherUserName
                                      .isNotEmpty
                                  ? widget.conversation
                                      .otherUserName[0]
                                      .toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : null,
                ),
                if (widget.conversation.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 11,
                      height: 11,
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
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.otherUserName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.conversation.isOnline)
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Messages list ────────────────────────────────────────
          Expanded(
            child: BlocConsumer<MessageBloc, MessageState>(
              listener: (context, state) {
                if (state is ChatOpenState) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is MessageLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen),
                  );
                }

                if (state is MessageErrorState) {
                  return Center(
                    child: Text(state.message,
                        style: const TextStyle(
                            color: AppColors.error)),
                  );
                }

                List<MessageEntity> messages = [];
                if (state is ChatOpenState) {
                  messages = state.messages;
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor:
                              Colors.grey.shade200,
                          backgroundImage: widget.conversation
                                      .otherUserAvatar !=
                                  null
                              ? NetworkImage(widget
                                  .conversation.otherUserAvatar!)
                              : null,
                          child: widget.conversation
                                      .otherUserAvatar ==
                                  null
                              ? Text(
                                  widget.conversation.otherUserName
                                          .isNotEmpty
                                      ? widget.conversation
                                          .otherUserName[0]
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.conversation.otherUserName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Say hi to start the conversation!',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isMe =
                        msg.senderId == _currentUserId;

                    // Show date separator if needed
                    bool showDate = i == 0 ||
                        !_sameDay(messages[i - 1].createdAt,
                            msg.createdAt);

                    return Column(
                      children: [
                        if (showDate)
                          _DateDivider(date: msg.createdAt),
                        MessageBubble(
                            message: msg, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // ── Input bar ────────────────────────────────────────────
          _ChatInputBar(
            controller: _msgCtrl,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInputBar(
      {required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(
                color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          // Emoji icon
          IconButton(
            icon: Icon(Icons.sentiment_satisfied_alt_outlined,
                color: Colors.grey.shade500),
            onPressed: () {},
          ),

          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Write a message...',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Attachment icon
          IconButton(
            icon: Icon(Icons.attach_file_outlined,
                color: Colors.grey.shade500),
            onPressed: () {},
          ),

          // Send / mic button
          BlocBuilder<MessageBloc, MessageState>(
            builder: (context, state) {
              final isSending = state is ChatOpenState &&
                  state.isSending;
              return AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final hasText =
                      controller.text.trim().isNotEmpty;
                  return GestureDetector(
                    onTap: hasText ? onSend : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: hasText
                            ? AppColors.textPrimary
                            : AppColors.textPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Icon(
                              hasText
                                  ? Icons.send_rounded
                                  : Icons.mic_none_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
