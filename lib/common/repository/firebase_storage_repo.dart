import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final commonFirebaseStorageProvider = Provider<FirebaseStorageRepository>(
    (ref) =>
        FirebaseStorageRepository(firebaseStorage: FirebaseStorage.instance));

class FirebaseStorageRepository {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageRepository({required this.firebaseStorage});

  Future<String> storeToFirebase(String path, File file) async {
    UploadTask uploadTask = firebaseStorage.ref().child(path).putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}
