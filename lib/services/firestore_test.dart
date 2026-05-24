import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTest {
  static Future<void> testConnection() async {
    try {
      print('🔄 Mencoba koneksi ke Firestore...');
      
      DocumentReference doc = await FirebaseFirestore.instance
          .collection('test')
          .add({
            'pesan': 'Firebase berhasil terhubung!',
            'waktu': DateTime.now().toString(),
          });
      
      print('✅ Firestore berhasil! ID dokumen: ${doc.id}');
    } catch (e) {
      print('❌ Firestore error: $e');
    }
  }
}