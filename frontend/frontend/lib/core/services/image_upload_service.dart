// lib/core/services/image_upload_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  ImageUploadService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  /// Opens the image source picker (gallery / camera) and returns the chosen
  /// [XFile], or null if the user cancelled.
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    return _picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
  }

  /// Uploads [imageFile] to Firebase Storage under
  /// `product_images/{userId}/{timestamp}.jpg` and returns the public
  /// download URL.
  Future<String> uploadProductImage({
    required File imageFile,
    required String userId,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref('product_images/$userId/$fileName');

    final task = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return task.ref.getDownloadURL();
  }

  /// Shows a bottom sheet to let the user choose Gallery or Camera, then
  /// uploads the image and returns the download URL.  Returns null if the
  /// user cancels at any step.
  Future<String?> pickAndUpload({required String userId}) async {
    final file = await pickImage();
    if (file == null) return null;
    return uploadProductImage(
      imageFile: File(file.path),
      userId: userId,
    );
  }
}
