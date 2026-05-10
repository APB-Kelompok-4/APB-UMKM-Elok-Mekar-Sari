import '../models/complaint.dart';

class ComplaintService {
  static final List<Complaint> _complaints = [
    Complaint(
      id: 'CMP-001',
      customerId: 'USR-001',
      customerName: 'Budi Santoso',
      customerEmail: 'budi@email.com',
      subject: 'Produk Rusak Saat Tiba',
      description: 'Produk yang saya terima sudah rusak, layar retak.',
      category: 'Produk Rusak',
      productName: 'Keripik Tempe Original',
      status: ComplaintStatus.resolved,
      priority: ComplaintPriority.high,
      createdDate: DateTime.now().subtract(const Duration(days: 5)),
      resolvedDate: DateTime.now().subtract(const Duration(days: 2)),
      adminResponse: 'Kami akan mengirimkan pengganti...',
      resolution: 'Produk diganti dengan yang baru',
      rating: 4,
      chat: [
        {'sender': 'customer', 'message': 'Produk keripik tempe yang saya terima dalam kondisi rusak dan tidak layak konsumsi', 'time': '2024-01-15 10:30'},
        {'sender': 'admin', 'message': 'Mohon maaf atas ketidaknyamanannya. Bisa kirim foto produk yang rusak?', 'time': '2024-01-15 11:00'},
        {'sender': 'customer', 'message': 'Baik, saya kirim fotonya sekarang', 'time': '2024-01-15 11:15'},
      ],
    ),
    Complaint(
      id: 'CMP-002',
      customerId: 'USR-001',
      customerName: 'Budi Santoso',
      customerEmail: 'budi@email.com',
      subject: 'Pengiriman Terlambat',
      description: 'Pesanan saya sudah 10 hari tapi belum tiba.',
      category: 'Pengiriman',
      productName: 'Sinom',
      status: ComplaintStatus.inProgress,
      priority: ComplaintPriority.medium,
      createdDate: DateTime.now().subtract(const Duration(days: 10)),
      adminResponse: 'Tim logistik sedang mengecek lokasi paket Anda.',
      chat: [
        {'sender': 'customer', 'message': 'Pesanan saya belum sampai juga setelah seminggu', 'time': '2024-01-14 09:00'},
        {'sender': 'admin', 'message': 'Mohon maaf atas keterlambatan. Kami sedang cek dengan kurir. Nomor pesanan Anda?', 'time': '2024-01-14 09:30'},
      ],
    ),
    Complaint(
      id: 'CMP-003',
      customerId: 'USR-002',
      customerName: 'Siti Nurhaliza',
      customerEmail: 'siti@email.com',
      subject: 'Produk Tidak Sesuai dengan Deskripsi',
      description: 'Ukuran produk tidak sesuai dengan yang tertera di website.',
      category: 'Produk Tidak Sesuai',
      productName: 'Tahu Walik',
      status: ComplaintStatus.reviewed,
      priority: ComplaintPriority.medium,
      createdDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static List<Complaint> get complaints => _complaints;

  static void addComplaint(Complaint complaint) {
    _complaints.add(complaint);
  }

  static void updateComplaint(String id, Complaint updatedComplaint) {
    final index = _complaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      _complaints[index] = updatedComplaint;
    }
  }

  static Complaint? getComplaintById(String id) {
    return _complaints.firstWhere((c) => c.id == id);
  }
}