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
    );
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