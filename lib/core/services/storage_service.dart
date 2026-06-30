import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required String path,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref().child('$path/$fileName');
    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  Future<void> deleteImage(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }
}
