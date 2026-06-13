import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintStatus {
  submitted,
  reviewed,
  inProgress,
  waitingCustomer,
  resolved,
  closed,
  rejected
}

enum ComplaintPriority { low, medium, high, urgent }

class Complaint {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String subject;
  final String description;
  final String category;
  final String? productName;
  final ComplaintStatus status;
  final ComplaintPriority priority;
  final DateTime createdDate;
  final DateTime? resolvedDate;
  final String? adminResponse;
  final String? resolution;
  final int rating; // 1-5 untuk kepuasan resolusi
  final List<String> attachments; // File paths
  final List<Map<String, dynamic>> chat; // Chat messages
  final bool chatEnded; // Apakah sesi chat sudah diakhiri oleh admin

  Complaint({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.subject,
    required this.description,
    required this.category,
    this.productName,
    required this.status,
    required this.priority,
    required this.createdDate,
    this.resolvedDate,
    this.adminResponse,
    this.resolution,
    this.rating = 0,
    this.attachments = const [],
    this.chat = const [],
    this.chatEnded = false,
  });

  Complaint copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? subject,
    String? description,
    String? category,
    String? productName,
    ComplaintStatus? status,
    ComplaintPriority? priority,
    DateTime? createdDate,
    DateTime? resolvedDate,
    String? adminResponse,
    String? resolution,
    int? rating,
    List<String>? attachments,
    List<Map<String, dynamic>>? chat,
    bool? chatEnded,
  }) {
    return Complaint(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      productName: productName ?? this.productName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdDate: createdDate ?? this.createdDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      adminResponse: adminResponse ?? this.adminResponse,
      resolution: resolution ?? this.resolution,
      rating: rating ?? this.rating,
      attachments: attachments ?? this.attachments,
      chat: chat ?? this.chat,
      chatEnded: chatEnded ?? this.chatEnded,
    );
  }

  // ============ Firestore Serialization ============

  /// Convert Complaint ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'subject': subject,
      'description': description,
      'category': category,
      'productName': productName,
      'status': status.name,
      'priority': priority.name,
      'createdDate': Timestamp.fromDate(createdDate),
      'resolvedDate': resolvedDate != null ? Timestamp.fromDate(resolvedDate!) : null,
      'adminResponse': adminResponse,
      'resolution': resolution,
      'rating': rating,
      'attachments': attachments,
      'chatEnded': chatEnded,
    };
  }

  /// Buat Complaint dari Firestore document snapshot
  factory Complaint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Complaint(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Lainnya',
      productName: data['productName'],
      status: _parseStatus(data['status']),
      priority: _parsePriority(data['priority']),
      createdDate: data['createdDate'] != null
          ? (data['createdDate'] as Timestamp).toDate()
          : DateTime.now(),
      resolvedDate: data['resolvedDate'] != null
          ? (data['resolvedDate'] as Timestamp).toDate()
          : null,
      adminResponse: data['adminResponse'],
      resolution: data['resolution'],
      rating: data['rating'] ?? 0,
      attachments: List<String>.from(data['attachments'] ?? []),
      chat: [], // Chat diambil dari sub-collection terpisah
      chatEnded: data['chatEnded'] ?? false,
    );
  }

  static ComplaintStatus _parseStatus(String? value) {
    switch (value) {
      case 'submitted':
        return ComplaintStatus.submitted;
      case 'reviewed':
        return ComplaintStatus.reviewed;
      case 'inProgress':
        return ComplaintStatus.inProgress;
      case 'waitingCustomer':
        return ComplaintStatus.waitingCustomer;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'closed':
        return ComplaintStatus.closed;
      case 'rejected':
        return ComplaintStatus.rejected;
      default:
        return ComplaintStatus.submitted;
    }
  }

  static ComplaintPriority _parsePriority(String? value) {
    switch (value) {
      case 'low':
        return ComplaintPriority.low;
      case 'medium':
        return ComplaintPriority.medium;
      case 'high':
        return ComplaintPriority.high;
      case 'urgent':
        return ComplaintPriority.urgent;
      default:
        return ComplaintPriority.medium;
    }
  }
}

// COMPLAINT CATEGORIES
const List<String> complaintCategories = [
  'Kualitas Produk',
  'Pengiriman',
  'Layanan Pelanggan',
  'Pembayaran',
  'Produk Tidak Sesuai',
  'Produk Rusak',
  'Lainnya'
];