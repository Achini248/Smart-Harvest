import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/repositories/message_repository.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final SendMessageUseCase _sendMessage;
  final GetMessagesUseCase _getMessages;
  final MessageRepository _repository;

  StreamSubscription<dynamic>? _messagesSub;

  MessageBloc({
    required SendMessageUseCase sendMessageUseCase,
    required GetMessagesUseCase getMessagesUseCase,
    required MessageRepository repository,
  })  : _sendMessage = sendMessageUseCase,
        _getMessages = getMessagesUseCase,
        _repository = repository,
        super(const MessageInitialState()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<OpenConversationEvent>(_onOpenConversation);
    on<SendMessageEvent>(_onSendMessage);
    on<MessageReceivedEvent>(_onMessageReceived);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<ClearMessageErrorEvent>(
        (_, emit) => emit(const MessageInitialState()));
  }

  Future<void> _onLoadConversations(
      LoadConversationsEvent e, Emitter<MessageState> emit) async {
    emit(const MessageLoadingState());
    final r = await _repository.getConversations(e.userId);
    r.fold(
      (f) => emit(MessageErrorState(message: f.message)),
      (convs) => convs.isEmpty
          ? emit(const MessageEmptyState(
              message: 'No conversations yet.'))
          : emit(ConversationsLoadedState(conversations: convs)),
    );
  }

  Future<void> _onOpenConversation(
      OpenConversationEvent e, Emitter<MessageState> emit) async {
    emit(const MessageLoadingState());

    // Cancel existing stream subscription
    await _messagesSub?.cancel();

    emit(ChatOpenState(
        conversationId: e.conversationId, messages: []));

    // Subscribe to real-time stream
    _messagesSub = _getMessages(
            GetMessagesParams(conversationId: e.conversationId))
        .listen(
      (result) {
        result.fold(
          (f) => add(
              ClearMessageErrorEvent()), // silently handle stream errors
          (messages) => add(
              MessageReceivedEvent(messages: messages)),
        );
      },
    );

    // Mark as read
    add(MarkAsReadEvent(
        conversationId: e.conversationId,
        userId: e.currentUserId));
  }

  void _onMessageReceived(
      MessageReceivedEvent e, Emitter<MessageState> emit) {
    if (state is ChatOpenState) {
      emit((state as ChatOpenState)
          .copyWith(messages: e.messages));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent e, Emitter<MessageState> emit) async {
    if (state is! ChatOpenState) return;
    final current = state as ChatOpenState;
    emit(current.copyWith(isSending: true));

    final r = await _sendMessage(
        SendMessageParams(message: e.message));
    r.fold(
      (f) => emit(
          MessageErrorState(message: f.message)),
      (_) => emit(current.copyWith(isSending: false)),
    );
  }

  Future<void> _onMarkAsRead(
      MarkAsReadEvent e, Emitter<MessageState> emit) async {
    await _repository.markAsRead(
        e.conversationId, e.userId);
  }

  @override
  Future<void> close() async {
    await _messagesSub?.cancel();
    return super.close();
  }
}
