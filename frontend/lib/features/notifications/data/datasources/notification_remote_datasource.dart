// lib/features/notifications/data/datasources/notification_remote_datasource.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel>       markAsRead(String id);
  Future<void>                    deleteNotification(String id);
  Stream<List<NotificationModel>> watchNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _db;

  NotificationRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('notifications');

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final snap = await _col
          .where('ownerId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snap.docs
          .map((d) => NotificationModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load notifications.');
    }
  }

  @override
  Future<NotificationModel> markAsRead(String id) async {
    try {
      final ref = _col.doc(id);
      await ref.update({'isRead': true});
      final doc = await ref.get();
      return NotificationModel.fromJson({...doc.data()!, 'id': doc.id});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to mark as read.');
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to delete notification.');
    }
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    return _col
        .where('ownerId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromJson({...d.data(), 'id': d.id}))
            .toList())
        .handleError((e) {
      throw ServerException(
          message: e is FirebaseException ? e.message ?? 'Stream error.' : e.toString());
    });
  }
}
