import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/message_model.dart';

abstract class MessageRemoteDataSource {
  Future<MessageModel> sendMessage(MessageModel message);
  Future<List<MessageModel>> getMessages(String conversationId);
  Stream<List<MessageModel>> watchMessages(String conversationId);
  Future<List<ConversationModel>> getConversations(String userId);
  Future<void> markAsRead(String conversationId, String userId);
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final FirebaseFirestore _db;

  MessageRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _messages =>
      _db.collection('messages');
  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection('conversations');

  // ── Conversation ID helper (deterministic, order-independent) ────────────
  String _convId(String a, String b) {
    final ids = [a, b]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final convId =
          _convId(message.senderId, message.receiverId);
      final now = DateTime.now();

      // Write message
      final ref = _messages.doc();
      final m = MessageModel(
        id: ref.id,
        conversationId: convId,
        senderId: message.senderId,
        senderName: message.senderName,
        receiverId: message.receiverId,
        receiverName: message.receiverName,
        content: message.content,
        isRead: false,
        createdAt: now,
      );
      await ref.set(m.toFirestore());

      // Update / create conversation summary
      await _conversations.doc(convId).set({
        'participants': [message.senderId, message.receiverId],
        'participantNames': {
          message.senderId: message.senderName,
          message.receiverId: message.receiverName,
        },
        'lastMessage': message.content,
        'lastMessageAt': Timestamp.fromDate(now),
        'lastSenderId': message.senderId,
        'unreadCount': {
          message.receiverId: FieldValue.increment(1),
        },
      }, SetOptions(merge: true));

      return m;
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Failed to send message.');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(
      String conversationId) async {
    try {
      final snap = await _messages
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('createdAt')
          .get();
      return snap.docs.map(MessageModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Failed to load messages.');
    }
  }

  @override
  Stream<List<MessageModel>> watchMessages(
      String conversationId) {
    return _messages
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map(MessageModel.fromFirestore).toList())
        .handleError((e) {
      throw ServerException(
          message: e is FirebaseException
              ? e.message ?? 'Stream error.'
              : e.toString());
    });
  }

  @override
  Future<List<ConversationModel>> getConversations(
      String userId) async {
    try {
      final snap = await _conversations
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true)
          .get();
      return snap.docs
          .map((d) => ConversationModel.fromFirestore(d, userId))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Failed to load conversations.');
    }
  }

  @override
  Future<void> markAsRead(
      String conversationId, String userId) async {
    try {
      await _conversations.doc(conversationId).update({
        'unreadCount.$userId': 0,
      });
      // Mark individual messages as read
      final snap = await _messages
          .where('conversationId', isEqualTo: conversationId)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Failed to mark as read.');
    }
  }
}
