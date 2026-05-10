import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Chatbot.dart' as chatbot;
import 'models/complaint.dart';
import 'services/complaint_service.dart';

const kGreen = Color(0xFF2D5A27);
const kGreenLight = Color(0xFF4A8C3F);
const kGreenPale = Color(0xFFEAF2E6);
const kCream = Color(0xFFF5F0E8);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

// CUSTOMER COMPLAINT PAGE
class ComplaintPage extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserEmail;

  const ComplaintPage({
    Key? key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserEmail,
  }) : super(key: key);

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Complaint> get myComplaints =>
      ComplaintService.complaints.where((c) => c.customerId == widget.currentUserId).toList();

  @override
  Widget build(BuildContext context) {
    // revisi presentasi kemarin
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Keluhan & Feedback',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, // Tambahkan bold agar lebih tegas
          ),
        ),
        backgroundColor: kGreen,
        elevation: 0,
        actions: [
          // Chat Icon
          IconButton(
            icon: const Icon(
              Icons.message,
              color: Colors.white,
              size: 26,
            ),
            tooltip: 'Chat dengan Asisten',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const chatbot.ChatbotPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white, // Warna garis bawah tab aktif
          indicatorWeight: 3.0,
          labelColor: Colors
              .white, // Warna teks untuk tab yang SEDANG AKTIF (Putih terang)
          unselectedLabelColor: Colors
              .white54, // Warna teks untuk tab yang TIDAK AKTIF (Putih redup/transparan)

          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Buat Keluhan Baru'),
            Tab(text: 'Riwayat Keluhan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NewComplaintForm(
            currentUserId: widget.currentUserId,
            currentUserName: widget.currentUserName,
            currentUserEmail: widget.currentUserEmail,
            onSubmit: (complaint) {
              setState(() {
                ComplaintService.addComplaint(complaint);
              });

              _tabController.animateTo(
                  1); // Setelah disubmit, otomatis pindah ke tab Riwayat (Index 1)

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Keluhan berhasil disubmit'),
                  backgroundColor: kGreen,
                ),
              );
            },
          ),
          // Index 1: Riwayat Keluhan
          ComplaintHistoryTab(complaints: myComplaints),
        ],
      ),
    );
  }
}

// = COMPLAINT HISTORY TAB =
class ComplaintHistoryTab extends StatelessWidget {
  final List<Complaint> complaints;

  const ComplaintHistoryTab({Key? key, required this.complaints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: kGreenPale),
            const SizedBox(height: 16),
            const Text(
              'Tidak Ada Keluhan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda belum memiliki keluhan atau semua keluhan sudah terselesaikan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kGray, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return ComplaintCard(complaint: complaint);
      },
    );
  }
}

// COMPLAINT CARD
class ComplaintCard extends StatelessWidget {
  final Complaint complaint;

  const ComplaintCard({Key? key, required this.complaint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComplaintDetailPage(complaint: complaint),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.id,
                          style: const TextStyle(
                            fontSize: 11,
                            color: kGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint.subject,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(complaint.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getStatusText(complaint.status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(complaint.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category & Priority
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kGreenPale,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      complaint.category,
                      style: const TextStyle(
                        fontSize: 10,
                        color: kGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _getPriorityIcon(complaint.priority),
                    size: 14,
                    color: _getPriorityColor(complaint.priority),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getPriorityText(complaint.priority),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getPriorityColor(complaint.priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date
              Text(
                'Tanggal: ${DateFormat('dd MMM yyyy', 'id_ID').format(complaint.createdDate)}',
                style: const TextStyle(fontSize: 10, color: kGray),
              ),

              // Progress indicator
              if (complaint.status != ComplaintStatus.closed &&
                  complaint.status != ComplaintStatus.rejected)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _getComplaintProgress(complaint.status),
                        minHeight: 4,
                        backgroundColor: kBorder.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(complaint.status),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return Colors.grey;
      case ComplaintStatus.reviewed:
        return Colors.blue;
      case ComplaintStatus.inProgress:
        return Colors.orange;
      case ComplaintStatus.waitingCustomer:
        return Colors.purple;
      case ComplaintStatus.resolved:
        return Colors.green;
      case ComplaintStatus.closed:
        return kGreen;
      case ComplaintStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 'Diajukan';
      case ComplaintStatus.reviewed:
        return 'Ditinjau';
      case ComplaintStatus.inProgress:
        return 'Sedang Ditangani';
      case ComplaintStatus.waitingCustomer:
        return 'Menunggu Anda';
      case ComplaintStatus.resolved:
        return 'Terselesaikan';
      case ComplaintStatus.closed:
        return 'Ditutup';
      case ComplaintStatus.rejected:
        return 'Ditolak';
    }
  }

  Color _getPriorityColor(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return Colors.green;
      case ComplaintPriority.medium:
        return Colors.orange;
      case ComplaintPriority.high:
        return Colors.red;
      case ComplaintPriority.urgent:
        return Colors.deepOrange;
    }
  }

  String _getPriorityText(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return 'Rendah';
      case ComplaintPriority.medium:
        return 'Sedang';
      case ComplaintPriority.high:
        return 'Tinggi';
      case ComplaintPriority.urgent:
        return 'Mendesak';
    }
  }

  IconData _getPriorityIcon(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return Icons.arrow_downward;
      case ComplaintPriority.medium:
        return Icons.arrow_forward;
      case ComplaintPriority.high:
        return Icons.arrow_upward;
      case ComplaintPriority.urgent:
        return Icons.priority_high;
    }
  }

  double _getComplaintProgress(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 0.2;
      case ComplaintStatus.reviewed:
        return 0.4;
      case ComplaintStatus.inProgress:
        return 0.6;
      case ComplaintStatus.waitingCustomer:
        return 0.5;
      case ComplaintStatus.resolved:
        return 0.9;
      case ComplaintStatus.closed:
        return 1.0;
      case ComplaintStatus.rejected:
        return 0.0;
    }
  }
}

// COMPLAINT DETAIL PAGE
class ComplaintDetailPage extends StatelessWidget {
  final Complaint complaint;

  const ComplaintDetailPage({Key? key, required this.complaint})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Keluhan'),
        backgroundColor: kGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              complaint.id,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              complaint.subject,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kDark,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(complaint.status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusText(complaint.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(complaint.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kGreenPale,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            complaint.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _getPriorityIcon(complaint.priority),
                          size: 16,
                          color: _getPriorityColor(complaint.priority),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getPriorityText(complaint.priority),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getPriorityColor(complaint.priority),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Informasi Pelanggan
            _buildSection(
              'Informasi Pelanggan',
              [
                _buildDetailRow('Nama', complaint.customerName),
                _buildDetailRow('Email', complaint.customerEmail),
              ],
            ),
            const SizedBox(height: 16),

            // Deskripsi Keluhan
            _buildSection(
              'Deskripsi Keluhan',
              [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    complaint.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: kDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tanggal
            _buildSection(
              'Tanggal',
              [
                _buildDetailRow(
                  'Diajukan',
                  DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                      .format(complaint.createdDate),
                ),
                if (complaint.resolvedDate != null)
                  _buildDetailRow(
                    'Terselesaikan',
                    DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                        .format(complaint.resolvedDate!),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Respons Admin
            if (complaint.adminResponse != null)
              _buildSection(
                'Respons dari Admin',
                [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kGreenPale,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kGreen.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      complaint.adminResponse!,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: kDark,
                      ),
                    ),
                  ),
                ],
              ),
            if (complaint.adminResponse != null) const SizedBox(height: 16),

            // Chat History
            if (complaint.chat.isNotEmpty)
              _buildSection(
                'Riwayat Chat',
                [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: complaint.chat.length,
                      itemBuilder: (context, index) {
                        final chat = complaint.chat[index];
                        final isAdmin = chat['sender'] == 'admin';
                        return Align(
                          alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                            decoration: BoxDecoration(
                              color: isAdmin ? kGreen : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chat['message'],
                                  style: TextStyle(
                                    color: isAdmin ? Colors.white : kDark,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  chat['time'],
                                  style: TextStyle(
                                    color: isAdmin ? Colors.white70 : kGray,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            if (complaint.chat.isNotEmpty) const SizedBox(height: 16),

            // Resolusi
            if (complaint.resolution != null)
              _buildSection(
                'Penyelesaian',
                [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      complaint.resolution!,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: kDark,
                      ),
                    ),
                  ),
                ],
              ),
            if (complaint.resolution != null) const SizedBox(height: 16),

            // Rating Kepuasan
            if (complaint.status == ComplaintStatus.resolved ||
                complaint.status == ComplaintStatus.closed)
              _buildSection(
                'Kepuasan Resolusi',
                [
                  if (complaint.rating > 0)
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            size: 20,
                            color: index < complaint.rating
                                ? Colors.amber
                                : Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${complaint.rating}/5',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kDark,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Belum dinilai',
                      style: TextStyle(color: kGray, fontSize: 13),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: kGray, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: kDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return Colors.grey;
      case ComplaintStatus.reviewed:
        return Colors.blue;
      case ComplaintStatus.inProgress:
        return Colors.orange;
      case ComplaintStatus.waitingCustomer:
        return Colors.purple;
      case ComplaintStatus.resolved:
        return Colors.green;
      case ComplaintStatus.closed:
        return kGreen;
      case ComplaintStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 'Diajukan';
      case ComplaintStatus.reviewed:
        return 'Ditinjau';
      case ComplaintStatus.inProgress:
        return 'Sedang Ditangani';
      case ComplaintStatus.waitingCustomer:
        return 'Menunggu Anda';
      case ComplaintStatus.resolved:
        return 'Terselesaikan';
      case ComplaintStatus.closed:
        return 'Ditutup';
      case ComplaintStatus.rejected:
        return 'Ditolak';
    }
  }

  Color _getPriorityColor(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return Colors.green;
      case ComplaintPriority.medium:
        return Colors.orange;
      case ComplaintPriority.high:
        return Colors.red;
      case ComplaintPriority.urgent:
        return Colors.deepOrange;
    }
  }

  String _getPriorityText(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return 'Rendah';
      case ComplaintPriority.medium:
        return 'Sedang';
      case ComplaintPriority.high:
        return 'Tinggi';
      case ComplaintPriority.urgent:
        return 'Mendesak';
    }
  }

  IconData _getPriorityIcon(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return Icons.arrow_downward;
      case ComplaintPriority.medium:
        return Icons.arrow_forward;
      case ComplaintPriority.high:
        return Icons.arrow_upward;
      case ComplaintPriority.urgent:
        return Icons.priority_high;
    }
  }
}

// NEW COMPLAINT FORM
class NewComplaintForm extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserEmail;
  final Function(Complaint) onSubmit;

  const NewComplaintForm({
    Key? key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserEmail,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<NewComplaintForm> createState() => _NewComplaintFormState();
}

class _NewComplaintFormState extends State<NewComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;
  String _selectedCategory = complaintCategories.first;
  ComplaintPriority _selectedPriority = ComplaintPriority.medium;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      final complaint = Complaint(
        id: 'CMP-${DateTime.now().millisecondsSinceEpoch}',
        customerId: widget.currentUserId,
        customerName: widget.currentUserName,
        customerEmail: widget.currentUserEmail,
        subject: _subjectController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        status: ComplaintStatus.submitted,
        priority: _selectedPriority,
        createdDate: DateTime.now(),
      );

      widget.onSubmit(complaint);

      _subjectController.clear();
      _descriptionController.clear();
      _selectedCategory = complaintCategories.first;
      _selectedPriority = ComplaintPriority.medium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kGreenPale,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: kGreen, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Silakan jelaskan keluhan atau feedback Anda dengan detail agar kami dapat menangani lebih cepat.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kGreen,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Kategori
            Text(
              'Kategori',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                underline: SizedBox(),
                items: complaintCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Prioritas
            Text(
              'Prioritas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<ComplaintPriority>(
                value: _selectedPriority,
                isExpanded: true,
                underline: SizedBox(),
                items: ComplaintPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Icon(
                          _getPriorityIcon(priority),
                          size: 16,
                          color: _getPriorityColor(priority),
                        ),
                        const SizedBox(width: 8),
                        Text(_getPriorityText(priority)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPriority = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Subjek
            Text(
              'Subjek/Judul',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectController,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Contoh: Produk Rusak Saat Tiba',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGreen, width: 2),
                ),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Subjek tidak boleh kosong';
                }
                if (value.length < 5) {
                  return 'Subjek minimal 5 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Deskripsi
            Text(
              'Deskripsi Detail',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 6,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText:
                    'Jelaskan keluhan atau feedback Anda secara detail...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGreen, width: 2),
                ),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                if (value.length < 20) {
                  return 'Deskripsi minimal 20 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitComplaint,
                icon: const Icon(Icons.send),
                label: const Text(
                  'Kirim Keluhan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return Colors.green;
      case ComplaintPriority.medium:
        return Colors.orange;
      case ComplaintPriority.high:
        return Colors.red;
      case ComplaintPriority.urgent:
        return Colors.deepOrange;
    }
  }

  String _getPriorityText(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return 'Rendah';
      case ComplaintPriority.medium:
        return 'Sedang';
      case ComplaintPriority.high:
        return 'Tinggi';
      case ComplaintPriority.urgent:
        return 'Mendesak';
    }
  }

  IconData _getPriorityIcon(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return Icons.arrow_downward;
      case ComplaintPriority.medium:
        return Icons.arrow_forward;
      case ComplaintPriority.high:
        return Icons.arrow_upward;
      case ComplaintPriority.urgent:
        return Icons.priority_high;
    }
  }
}

// = ADMIN COMPLAINT MANAGEMENT =
class AdminComplaintPage extends StatefulWidget {
  const AdminComplaintPage({Key? key}) : super(key: key);

  @override
  State<AdminComplaintPage> createState() => _AdminComplaintPageState();
}

class _AdminComplaintPageState extends State<AdminComplaintPage> {
  final List<Complaint> allComplaints = [
    Complaint(
      id: 'CMP-001',
      customerId: 'USR-001',
      customerName: 'Budi Santoso',
      customerEmail: 'budi@email.com',
      subject: 'Produk Rusak Saat Tiba',
      description: 'Produk yang saya terima sudah rusak, layar retak.',
      category: 'Produk Rusak',
      status: ComplaintStatus.resolved,
      priority: ComplaintPriority.high,
      createdDate: DateTime.now().subtract(const Duration(days: 5)),
      resolvedDate: DateTime.now().subtract(const Duration(days: 2)),
      adminResponse: 'Kami akan mengirimkan pengganti...',
      resolution: 'Produk diganti dengan yang baru',
      rating: 4,
    ),
    Complaint(
      id: 'CMP-002',
      customerId: 'USR-001',
      customerName: 'Budi Santoso',
      customerEmail: 'budi@email.com',
      subject: 'Pengiriman Terlambat',
      description: 'Pesanan saya sudah 10 hari tapi belum tiba.',
      category: 'Pengiriman',
      status: ComplaintStatus.inProgress,
      priority: ComplaintPriority.medium,
      createdDate: DateTime.now().subtract(const Duration(days: 10)),
      adminResponse: 'Tim logistik sedang mengecek lokasi paket Anda.',
    ),
    Complaint(
      id: 'CMP-003',
      customerId: 'USR-002',
      customerName: 'Siti Nurhaliza',
      customerEmail: 'siti@email.com',
      subject: 'Produk Tidak Sesuai dengan Deskripsi',
      description: 'Ukuran produk tidak sesuai dengan yang tertera di website.',
      category: 'Produk Tidak Sesuai',
      status: ComplaintStatus.reviewed,
      priority: ComplaintPriority.medium,
      createdDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  String _filterStatus = 'Semua';
  String _filterPriority = 'Semua';

  List<Complaint> get filteredComplaints {
    return allComplaints.where((c) {
      bool statusMatch = _filterStatus == 'Semua' ||
          _getStatusText(c.status) ==
              _filterStatus; // atau dapat dibuat mapping lebih baik
      bool priorityMatch = _filterPriority == 'Semua' ||
          _getPriorityText(c.priority) == _filterPriority;

      return statusMatch && priorityMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Keluhan'),
        backgroundColor: kGreen,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Statistics
          Container(
            color: kGreen,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    allComplaints.length.toString(),
                    Icons.list,
                    kGreenLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Baru',
                    allComplaints
                        .where((c) => c.status == ComplaintStatus.submitted)
                        .length
                        .toString(),
                    Icons.new_releases,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Terselesaikan',
                    allComplaints
                        .where((c) => c.status == ComplaintStatus.resolved)
                        .length
                        .toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                      'Status',
                      [
                        'Semua',
                        'Diajukan',
                        'Ditinjau',
                        'Sedang Ditangani',
                        'Terselesaikan'
                      ],
                      _filterStatus, (value) {
                    setState(() => _filterStatus = value);
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                      'Prioritas',
                      ['Semua', 'Rendah', 'Sedang', 'Tinggi', 'Mendesak'],
                      _filterPriority, (value) {
                    setState(() => _filterPriority = value);
                  }),
                ),
              ],
            ),
          ),

          // Complaints List
          Expanded(
            child: filteredComplaints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox,
                            size: 80, color: kBorder.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text(
                          'Tidak ada keluhan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kGray,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = filteredComplaints[index];
                      return AdminComplaintCard(
                        complaint: complaint,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminComplaintDetailPage(
                                complaint: complaint,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, List<String> options, String selected,
      Function(String) onSelected) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return options.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$label: $selected',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  String _getStatusText(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 'Diajukan';
      case ComplaintStatus.reviewed:
        return 'Ditinjau';
      case ComplaintStatus.inProgress:
        return 'Sedang Ditangani';
      case ComplaintStatus.waitingCustomer:
        return 'Menunggu Anda';
      case ComplaintStatus.resolved:
        return 'Terselesaikan';
      case ComplaintStatus.closed:
        return 'Ditutup';
      case ComplaintStatus.rejected:
        return 'Ditolak';
    }
  }

  String _getPriorityText(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return 'Rendah';
      case ComplaintPriority.medium:
        return 'Sedang';
      case ComplaintPriority.high:
        return 'Tinggi';
      case ComplaintPriority.urgent:
        return 'Mendesak';
    }
  }
}

// = ADMIN COMPLAINT CARD =
class AdminComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;

  const AdminComplaintCard({
    Key? key,
    required this.complaint,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.id,
                          style: const TextStyle(
                            fontSize: 11,
                            color: kGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint.subject,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint.customerName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(complaint.status)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(complaint.status),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(complaint.status),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        _getPriorityIcon(complaint.priority),
                        size: 16,
                        color: _getPriorityColor(complaint.priority),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return Colors.grey;
      case ComplaintStatus.reviewed:
        return Colors.blue;
      case ComplaintStatus.inProgress:
        return Colors.orange;
      case ComplaintStatus.waitingCustomer:
        return Colors.purple;
      case ComplaintStatus.resolved:
        return Colors.green;
      case ComplaintStatus.closed:
        return kGreen;
      case ComplaintStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 'Diajukan';
      case ComplaintStatus.reviewed:
        return 'Ditinjau';
      case ComplaintStatus.inProgress:
        return 'Sedang Ditangani';
      case ComplaintStatus.waitingCustomer:
        return 'Menunggu Anda';
      case ComplaintStatus.resolved:
        return 'Terselesaikan';
      case ComplaintStatus.closed:
        return 'Ditutup';
      case ComplaintStatus.rejected:
        return 'Ditolak';
    }
  }

  Color _getPriorityColor(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return Colors.green;
      case ComplaintPriority.medium:
        return Colors.orange;
      case ComplaintPriority.high:
        return Colors.red;
      case ComplaintPriority.urgent:
        return Colors.deepOrange;
    }
  }

  IconData _getPriorityIcon(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return Icons.arrow_downward;
      case ComplaintPriority.medium:
        return Icons.arrow_forward;
      case ComplaintPriority.high:
        return Icons.arrow_upward;
      case ComplaintPriority.urgent:
        return Icons.priority_high;
    }
  }
}

// = ADMIN COMPLAINT DETAIL PAGE
class AdminComplaintDetailPage extends StatefulWidget {
  final Complaint complaint;

  const AdminComplaintDetailPage({Key? key, required this.complaint})
      : super(key: key);

  @override
  State<AdminComplaintDetailPage> createState() =>
      _AdminComplaintDetailPageState();
}

class _AdminComplaintDetailPageState extends State<AdminComplaintDetailPage> {
  late TextEditingController _responseController;
  late TextEditingController _resolutionController;
  late ComplaintStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _responseController =
        TextEditingController(text: widget.complaint.adminResponse ?? '');
    _resolutionController =
        TextEditingController(text: widget.complaint.resolution ?? '');
    _selectedStatus = widget.complaint.status;
  }

  @override
  void dispose() {
    _responseController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Keluhan'),
        backgroundColor: kGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Complaint Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.complaint.id,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.complaint.subject,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dari: ${widget.complaint.customerName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kGray,
                      ),
                    ),
                    Text(
                      'Email: ${widget.complaint.customerEmail}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi Keluhan
            _buildSection(
              'Deskripsi Keluhan',
              [
                Text(
                  widget.complaint.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: kDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Management
            Text(
              'Perbarui Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<ComplaintStatus>(
                value: _selectedStatus,
                isExpanded: true,
                underline: SizedBox(),
                items: ComplaintStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Admin Response
            Text(
              'Respons dari Admin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _responseController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Berikan respons kepada pelanggan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGreen, width: 2),
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),

            // Resolution
            Text(
              'Penyelesaian',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _resolutionController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Jelaskan bagaimana masalah diselesaikan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGreen, width: 2),
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Keluhan berhasil diperbarui'),
                      backgroundColor: kGreen,
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  String _getStatusText(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 'Diajukan';
      case ComplaintStatus.reviewed:
        return 'Ditinjau';
      case ComplaintStatus.inProgress:
        return 'Sedang Ditangani';
      case ComplaintStatus.waitingCustomer:
        return 'Menunggu Anda';
      case ComplaintStatus.resolved:
        return 'Terselesaikan';
      case ComplaintStatus.closed:
        return 'Ditutup';
      case ComplaintStatus.rejected:
        return 'Ditolak';
    }
  }
}