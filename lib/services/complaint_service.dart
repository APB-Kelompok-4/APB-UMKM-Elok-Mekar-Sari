import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint.dart';

/// Service untuk mengelola keluhan menggunakan Firebase Firestore.
///
/// Struktur database di Firestore:
///   complaints/{complaintId}          → dokumen keluhan
///   complaints/{complaintId}/messages  → sub-collection chat messages
class ComplaintService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference _complaintsCol =
      _db.collection('complaints');

  // ============ COMPLAINTS ============

  /// Tambah keluhan baru ke Firestore
  static Future<void> addComplaint(Complaint complaint) async {
    await _complaintsCol.doc(complaint.id).set(complaint.toMap());
  }

  /// Update keluhan yang sudah ada di Firestore
  static Future<void> updateComplaint(
      String id, Complaint updatedComplaint) async {
    await _complaintsCol.doc(id).update(updatedComplaint.toMap());
  }

  /// Ambil satu complaint berdasarkan ID
  static Future<Complaint?> getComplaintById(String id) async {
    final doc = await _complaintsCol.doc(id).get();
    if (!doc.exists) return null;
    return Complaint.fromFirestore(doc);
  }

  /// Stream satu keluhan secara real-time
  static Stream<Complaint?> streamComplaint(String id) {
    return _complaintsCol.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Complaint.fromFirestore(doc);
    });
  }

  /// Stream semua keluhan (untuk admin)
  static Stream<List<Complaint>> streamAllComplaints() {
    return _complaintsCol
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Complaint.fromFirestore(doc))
              .toList();
          // Sort di client-side agar tidak butuh composite index
          list.sort((a, b) => b.createdDate.compareTo(a.createdDate));
          return list;
        });
  }

  /// Stream keluhan milik user tertentu
  static Stream<List<Complaint>> streamUserComplaints(String userId) {
    return _complaintsCol
        .where('customerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Complaint.fromFirestore(doc))
              .toList();
          // Sort di client-side agar tidak butuh composite index
          list.sort((a, b) => b.createdDate.compareTo(a.createdDate));
          return list;
        });
  }

  /// Ambil semua keluhan sekali (bukan stream) – untuk backward compat
  static Future<List<Complaint>> getAllComplaints() async {
    final snapshot = await _complaintsCol.get();
    final list = snapshot.docs
        .map((doc) => Complaint.fromFirestore(doc))
        .toList();
    // Sort di client-side agar tidak butuh index
    list.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return list;
  }

  // ============ CHAT MESSAGES (sub-collection) ============

  /// Referensi sub-collection messages untuk suatu complaint
  static CollectionReference _messagesCol(String complaintId) {
    return _complaintsCol.doc(complaintId).collection('messages');
  }

  /// Kirim pesan chat baru ke sub-collection messages
  static Future<void> sendChatMessage({
    required String complaintId,
    required String sender, // 'customer' atau 'admin'
    required String message,
  }) async {
    await _messagesCol(complaintId).add({
      'sender': sender,
      'message': message,
      'time': FieldValue.serverTimestamp(),
    });

    // Prune pesan lama agar tidak terlalu banyak (max 100, max usia 7 hari)
    await _pruneMessages(complaintId, maxMessages: 100, maxAge: const Duration(days: 7));
  }

  /// Stream pesan chat real-time untuk suatu complaint
  static Stream<List<Map<String, dynamic>>> streamChatMessages(
      String complaintId) {
    return _messagesCol(complaintId)
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = data['time'] as Timestamp?;
              return {
                'sender': data['sender'] ?? '',
                'message': data['message'] ?? '',
                'time': timestamp != null
                    ? _formatTimestamp(timestamp)
                    : '',
              };
            }).toList());
  }

  /// Format Timestamp ke string dd-MM-yyyy HH:mm
  static String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Hapus pesan terlama jika jumlah melebihi [maxMessages] atau sudah lebih lama dari [maxAge]
  static Future<void> _pruneMessages(String complaintId,
      {int maxMessages = 100, Duration maxAge = const Duration(days: 7)}) async {
    final cutoff = DateTime.now().subtract(maxAge);
    
    // Hapus pesan yang lebih lama dari maxAge
    final oldDocs = await _messagesCol(complaintId)
        .where('time', isLessThan: Timestamp.fromDate(cutoff))
        .get();

    final batch = _db.batch();
    for (var doc in oldDocs.docs) {
      batch.delete(doc.reference);
    }
    
    // Prune berdasarkan jumlah jika masih melebihi batas
    final snapshot = await _messagesCol(complaintId)
        .orderBy('time', descending: true)
        .get();

    if (snapshot.docs.length > maxMessages) {
      final toDelete = snapshot.docs.sublist(maxMessages);
      for (var doc in toDelete) {
        batch.delete(doc.reference);
      }
    }
    
    await batch.commit();
  }

  // ============ CHATBOT MESSAGES (Firestore) ============

  static CollectionReference _chatbotMessagesCol(String userId) {
    return _db.collection('chatbot_sessions').doc(userId).collection('messages');
  }

  /// Kirim pesan chatbot baru ke Firestore
  static Future<void> sendChatbotMessage({
    required String userId,
    required String message,
    required bool isBot,
  }) async {
    await _chatbotMessagesCol(userId).add({
      'message': message,
      'isBot': isBot,
      'time': FieldValue.serverTimestamp(),
    });

    // Prune pesan chatbot lama (max 50, max usia 3 hari)
    await _pruneChatbotMessages(userId, maxMessages: 50, maxAge: const Duration(days: 3));
  }

  /// Stream pesan chatbot real-time
  static Stream<List<Map<String, dynamic>>> streamChatbotMessages(String userId) {
    return _chatbotMessagesCol(userId)
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = data['time'] as Timestamp?;
              return {
                'id': doc.id,
                'message': data['message'] ?? '',
                'isBot': data['isBot'] ?? false,
                'time': timestamp != null ? timestamp.toDate() : DateTime.now(),
              };
            }).toList());
  }

  /// Hapus pesan chatbot yang melebihi batas atau sudah terlalu lama
  static Future<void> _pruneChatbotMessages(String userId,
      {int maxMessages = 50, Duration maxAge = const Duration(days: 3)}) async {
    final cutoff = DateTime.now().subtract(maxAge);
    final col = _chatbotMessagesCol(userId);

    // Hapus pesan chatbot yang lebih lama dari maxAge
    final oldDocs = await col
        .where('time', isLessThan: Timestamp.fromDate(cutoff))
        .get();

    final batch = _db.batch();
    for (var doc in oldDocs.docs) {
      batch.delete(doc.reference);
    }

    // Prune berdasarkan jumlah
    final snapshot = await col.orderBy('time', descending: true).get();
    if (snapshot.docs.length > maxMessages) {
      final toDelete = snapshot.docs.sublist(maxMessages);
      for (var doc in toDelete) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }

  // ============ ADMIN ACTIONS ============

  /// Admin mengakhiri sesi chat
  static Future<void> endChatSession(String complaintId) async {
    await _complaintsCol.doc(complaintId).update({'chatEnded': true});
  }

  /// Update status keluhan
  static Future<void> updateStatus(
      String complaintId, ComplaintStatus status) async {
    await _complaintsCol.doc(complaintId).update({'status': status.name});
  }

  /// Update respons admin dan resolusi
  static Future<void> updateAdminResponse({
    required String complaintId,
    String? adminResponse,
    String? resolution,
    ComplaintStatus? status,
    DateTime? resolvedDate,
  }) async {
    final Map<String, dynamic> updates = {};
    if (adminResponse != null) updates['adminResponse'] = adminResponse;
    if (resolution != null) updates['resolution'] = resolution;
    if (status != null) updates['status'] = status.name;
    if (resolvedDate != null) {
      updates['resolvedDate'] = Timestamp.fromDate(resolvedDate);
    }
    if (updates.isNotEmpty) {
      await _complaintsCol.doc(complaintId).update(updates);
    }
  }

  // ============ BACKWARD COMPATIBILITY ============
  // Properti statis untuk menjaga kompatibilitas dengan kode lama
  // yang menggunakan ComplaintService.complaints secara langsung.
  // Properti ini sekarang mengambil data dari Firestore secara sinkron
  // melalui cache terakhir. Untuk data real-time gunakan streams.

  static List<Complaint> _cachedComplaints = [];

  /// Getter untuk backward compat – mengembalikan cache terakhir
  static List<Complaint> get complaints => _cachedComplaints;

  /// Inisialisasi cache dari Firestore (panggil sekali di awal)
  static Future<void> initCache() async {
    _cachedComplaints = await getAllComplaints();
  }

  /// Refresh cache
  static Future<void> refreshCache() async {
    _cachedComplaints = await getAllComplaints();
  }
}