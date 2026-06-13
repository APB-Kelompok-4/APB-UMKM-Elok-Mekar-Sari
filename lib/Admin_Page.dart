import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/complaint.dart';
import 'services/complaint_service.dart';
import 'services/product_service.dart';

const kGreen = Color(0xFF2D5A27);
const kGreenLight = Color(0xFF4A8C3F);
const kGreenPale = Color(0xFFEAF2E6);
const kCream = Color(0xFFF5F0E8);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

// ========== ADMIN PAGE ==========
class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard Admin';
      case 1:
        return 'Manajemen Produk';
      case 2:
        return 'Manajemen Order';
      case 3:
        return 'Manajemen Keluhan';
      case 4:
        return 'Pengguna';
      case 5:
        return 'Laporan';
      default:
        return 'Admin Panel';
    }
  }

  List<Widget> _getAppBarActions() {
    if (_selectedIndex == 1) {
      return [];
    }
    if (_selectedIndex == 5) {
      return [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur ekspor laporan tersedia di tampilan laporan')),
            );
          },
          icon: const Icon(Icons.download),
          tooltip: 'Ekspor Laporan',
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      DashboardTab(
        onTapPendingComplaints: () => _onItemTapped(3),
        onTapTotalOrders: () => _onItemTapped(2),
      ),
      const ProductManagementTab(),
      const OrderManagementTab(),
      const ComplaintManagementTab(),
      const UserManagementTab(),
      const ReportsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: kGreen,
        elevation: 0,
        actions: _getAppBarActions(),
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produk'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Keluhan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pengguna'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kGreen,
        unselectedItemColor: kGray,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ========== DASHBOARD TAB ==========
class DashboardTab extends StatelessWidget {
  final VoidCallback? onTapPendingComplaints;
  final VoidCallback? onTapTotalOrders;

  const DashboardTab({
    Key? key,
    this.onTapPendingComplaints,
    this.onTapTotalOrders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Complaint>>(
      stream: ComplaintService.streamAllComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kGreen));
        }
        final allComplaints = snapshot.data ?? [];
        
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, orderSnapshot) {
            if (orderSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kGreen));
            }
            final orderDocs = orderSnapshot.data?.docs ?? [];

            // Calculate total orders today
            final now = DateTime.now();
            final startOfToday = DateTime(now.year, now.month, now.day);
            final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

            final ordersTodayCount = orderDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              if (createdAt == null) return false;
              return createdAt.isAfter(startOfToday) && createdAt.isBefore(endOfToday);
            }).length;

            // Calculate total revenue from orders that are not cancelled
            final totalRevenue = orderDocs.fold<double>(0.0, (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['status'] == 'dibatalkan') return sum;
              final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
              return sum + price;
            });
            final formattedRevenue = 'Rp ${NumberFormat('#,###', 'id_ID').format(totalRevenue)}';

            // Calculate best selling product (top product)
            final productQuantities = <String, int>{};
            for (final doc in orderDocs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['status'] == 'dibatalkan') continue;
              final items = (data['items'] as List<dynamic>?) ?? [];
              for (final item in items) {
                if (item is Map) {
                  final name = item['productName'] as String? ?? '';
                  final qty = (item['quantity'] as num?)?.toInt() ?? 0;
                  if (name.isNotEmpty) {
                    productQuantities[name] = (productQuantities[name] ?? 0) + qty;
                  }
                }
              }
            }
            String topProduct = 'Tidak ada';
            int maxQty = 0;
            productQuantities.forEach((name, qty) {
              if (qty > maxQty) {
                maxQty = qty;
                topProduct = name;
              }
            });

            // Sort order docs by createdAt descending for recent orders list
            final sortedOrderDocs = List<QueryDocumentSnapshot>.from(orderDocs)
              ..sort((a, b) {
                final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
                final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
                if (aTs == null || bTs == null) return 0;
                return bTs.compareTo(aTs);
              });
            final recentOrderDocs = sortedOrderDocs.take(3).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard Utama',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Order Hari Ini',
                          ordersTodayCount.toString(),
                          Icons.shopping_cart,
                          kGreen,
                          onTap: onTapTotalOrders,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Pendapatan',
                          formattedRevenue,
                          Icons.attach_money,
                          kGreenLight,
                          onTap: onTapTotalOrders,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Keluhan Pending',
                          _getPendingComplaintCount(allComplaints).toString(),
                          Icons.report_problem,
                          Colors.orange,
                          onTap: onTapPendingComplaints,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Produk Terlaris',
                          topProduct,
                          Icons.star,
                          Colors.amber,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent Orders
                  const Text(
                    'Order Terbaru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentOrdersList(recentOrderDocs),

                  const SizedBox(height: 32),
                  // Pending Complaints
                  const Text(
                    'Keluhan Pending',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPendingComplaintsList(allComplaints),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _getPendingComplaintCount(List<Complaint> allComplaints) {
    return allComplaints.where((complaint) {
      return complaint.status == ComplaintStatus.submitted ||
          complaint.status == ComplaintStatus.inProgress ||
          complaint.status == ComplaintStatus.reviewed ||
          complaint.status == ComplaintStatus.waitingCustomer;
    }).length;
  }

  List<Complaint> _getPendingComplaints(List<Complaint> allComplaints) {
    return allComplaints.where((complaint) {
      return complaint.status == ComplaintStatus.submitted ||
          complaint.status == ComplaintStatus.inProgress ||
          complaint.status == ComplaintStatus.reviewed ||
          complaint.status == ComplaintStatus.waitingCustomer;
    }).toList();
  }

  String _priorityToString(ComplaintPriority priority) {
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

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: kGray),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrdersList(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return Card(
        color: kBg,
        margin: const EdgeInsets.only(bottom: 8),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Tidak ada order saat ini.',
            style: TextStyle(color: kGray),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final rawId = data['orderId'] as String? ?? docs[index].id;
        final status = data['status'] ?? 'pending';
        final recipientName = data['recipientName'] ?? '-';
        final totalPrice = data['totalPrice'] ?? 0;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        // Format nomor order
        String displayOrderId;
        if (createdAt != null) {
          final date = DateFormat('yyyyMMdd').format(createdAt);
          displayOrderId = 'EMS-$date-${rawId.substring(0,4).toUpperCase()}';
        } else {
          displayOrderId = 'EMS-${rawId.substring(0,8).toUpperCase()}';
        }

        String statusLabelDashboard;
        switch (status) {
          case 'pending':
            statusLabelDashboard = 'Menunggu Pembayaran';
            break;
          case 'diproses':
            statusLabelDashboard = 'Dikemas';
            break;
          case 'dikirim':
            statusLabelDashboard = 'Dikirim';
            break;
          case 'selesai':
            statusLabelDashboard = 'Selesai';
            break;
          case 'dibatalkan':
            statusLabelDashboard = 'Dibatalkan';
            break;
          default:
            statusLabelDashboard = status;
        }

        Color statusColorDashboard;
        switch (status) {
          case 'pending':
            statusColorDashboard = Colors.orange;
            break;
          case 'diproses':
            statusColorDashboard = Colors.blue;
            break;
          case 'dikirim':
            statusColorDashboard = Colors.orange;
            break;
          case 'selesai':
            statusColorDashboard = Colors.green;
            break;
          case 'dibatalkan':
            statusColorDashboard = Colors.red;
            break;
          default:
            statusColorDashboard = kGray;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('Order #$displayOrderId - $recipientName'),
            subtitle: Text('Total: Rp ${NumberFormat('#,###', 'id_ID').format(totalPrice)}'),
            trailing: Text(
              statusLabelDashboard,
              style: TextStyle(
                color: statusColorDashboard,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingComplaintsList(List<Complaint> allComplaints) {
    final pendingComplaints = _getPendingComplaints(allComplaints);

    if (pendingComplaints.isEmpty) {
      return Card(
        color: kBg,
        margin: const EdgeInsets.only(bottom: 8),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Tidak ada keluhan pending saat ini.',
            style: TextStyle(color: kGray),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingComplaints.length,
      itemBuilder: (context, index) {
        final complaint = pendingComplaints[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: onTapPendingComplaints,
            title: Text(
              'Keluhan #${complaint.id} - ${complaint.productName ?? complaint.subject}',
            ),
            subtitle: Text('Kategori: ${complaint.category} • Dari: ${complaint.customerName}'),
            trailing: Text(
              _priorityToString(complaint.priority),
              style: TextStyle(
                color:
                    complaint.priority == ComplaintPriority.high ||
                        complaint.priority == ComplaintPriority.urgent
                    ? Colors.red
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ========== PRODUCT MANAGEMENT TAB ==========
class ProductManagementTab extends StatefulWidget {
  const ProductManagementTab({Key? key}) : super(key: key);

  @override
  State<ProductManagementTab> createState() => _ProductManagementTabState();
}

class _ProductManagementTabState extends State<ProductManagementTab> {
  List<Map<String, dynamic>> get _products => ProductService.products;

  void _deleteProduct(int index) {
    ProductService.deleteProduct(index);
    setState(() {});
  }

  Widget _buildProductImageWidget(dynamic imageValue) {
    if (imageValue is Uint8List && imageValue.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          imageValue,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 48,
            height: 48,
            color: kBg,
            child: const Icon(Icons.broken_image, size: 20, color: Colors.red),
          ),
        ),
      );
    }

    if (imageValue is String) {
      if (imageValue.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imageValue,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 48,
              height: 48,
              color: kBg,
              child: const Icon(Icons.broken_image, size: 20, color: Colors.red),
            ),
          ),
        );
      }

      final imageFile = File(imageValue);
      if (imageFile.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            imageFile,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 48,
              height: 48,
              color: kBg,
              child: const Icon(Icons.broken_image, size: 20, color: Colors.red),
            ),
          ),
        );
      }
    }

    return Text(
      imageValue?.toString() ?? '📦',
      style: const TextStyle(fontSize: 32),
    );
  }

  Future<XFile?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return pickedFile;
    } catch (error, stackTrace) {
      debugPrint('Image pick failed: $error');
      debugPrint('$stackTrace');
      return null;
    }
  }

  Widget _buildSelectedImagePreview(
    String? selectedImagePath,
    Uint8List? selectedImageBytes,
  ) {
    return Builder(
      builder: (context) {
        try {
          if (selectedImageBytes != null && selectedImageBytes.isNotEmpty) {
            return Image.memory(
              selectedImageBytes,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: double.infinity,
                  color: kBg,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 36,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            );
          }

          if (selectedImagePath == null || selectedImagePath.isEmpty) {
            return Container(
              height: 100,
              width: double.infinity,
              color: kBg,
              child: const Center(child: Text('Belum memilih gambar')),
            );
          }

          final imageFile = File(selectedImagePath);
          if (!imageFile.existsSync()) {
            return Container(
              height: 100,
              width: double.infinity,
              color: kBg,
              child: const Center(child: Text('Gambar tidak ditemukan')),
            );
          }

          return Image.file(
            imageFile,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: double.infinity,
                color: kBg,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 36, color: Colors.red),
                ),
              );
            },
          );
        } catch (error, stackTrace) {
          debugPrint('Image preview failed: $error');
          debugPrint('$stackTrace');
          return Container(
            height: 100,
            width: double.infinity,
            color: kBg,
            child: const Center(
              child: Icon(Icons.error, size: 36, color: Colors.red),
            ),
          );
        }
      },
    );
  }

  void _addProduct() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController categoryController =
        TextEditingController(text: 'Makanan');
    String selectedCategory = 'Makanan';
    String? selectedImagePath;
    Uint8List? selectedImageBytes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tambah Produk Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga (Rp)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    onChanged: (value) => setState(() {
                      selectedCategory = value;
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upload Gambar Produk',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final pickedFile = await _pickImage();
                      if (pickedFile != null) {
                        try {
                          final bytes = await pickedFile.readAsBytes();
                          setState(() {
                            selectedImagePath = pickedFile.path;
                            selectedImageBytes = bytes.isNotEmpty ? bytes : null;
                          });
                        } catch (error, stackTrace) {
                          debugPrint('Read image bytes failed: $error');
                          debugPrint('$stackTrace');
                          setState(() {
                            selectedImagePath = pickedFile.path;
                            selectedImageBytes = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal memproses gambar. Coba lagi.'),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildSelectedImagePreview(
                        selectedImagePath,
                        selectedImageBytes,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Produk',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color: kGreen),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isNotEmpty &&
                                priceController.text.isNotEmpty &&
                                stockController.text.isNotEmpty &&
                                descriptionController.text.isNotEmpty) {
                              ProductService.addProduct({
                                'id': DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                'name': nameController.text,
                                'price': int.parse(priceController.text),
                                'stock': int.parse(stockController.text),
                                'category': selectedCategory,
                                'active': true,
                                'image': selectedImageBytes ?? selectedImagePath ?? '📦',
                                'description': descriptionController.text,
                                'isFile': selectedImagePath != null,
                              });
                              setState(() {});
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Produk berhasil ditambahkan'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Harap isi semua field'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            foregroundColor: Colors.black,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Tambah'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _editProduct(int index) {
    final product = _products[index];
    final TextEditingController nameController = TextEditingController(
      text: product['name'],
    );
    final TextEditingController priceController = TextEditingController(
      text: product['price'].toString(),
    );
    final TextEditingController stockController = TextEditingController(
      text: product['stock'].toString(),
    );
    final TextEditingController descriptionController = TextEditingController(
      text: product['description'],
    );
    final TextEditingController categoryController =
        TextEditingController(text: product['category']);
    String selectedCategory = product['category'];
    String? selectedImagePath;
    Uint8List? selectedImageBytes;

    if (product['image'] is Uint8List) {
      selectedImageBytes = product['image'];
    } else if (product['image'] is String && File(product['image']).existsSync()) {
      selectedImagePath = product['image'];
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            scrollable: true,
            title: const Text('Edit Produk'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Harga (Rp)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stok',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: categoryController,
                      onChanged: (value) => setState(() {
                        selectedCategory = value;
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Gambar Produk',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await _pickImage();
                        if (pickedFile != null) {
                          try {
                            final bytes = await pickedFile.readAsBytes();
                            setState(() {
                              selectedImagePath = pickedFile.path;
                              selectedImageBytes = bytes.isNotEmpty ? bytes : null;
                            });
                          } catch (error, stackTrace) {
                            debugPrint('Read image bytes failed: $error');
                            debugPrint('$stackTrace');
                            setState(() {
                              selectedImagePath = pickedFile.path;
                              selectedImageBytes = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal memproses gambar. Coba lagi.'),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: kBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildSelectedImagePreview(
                          selectedImagePath,
                          selectedImageBytes,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Produk',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      priceController.text.isNotEmpty &&
                      stockController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    final updatedProduct = {
                      ...product,
                      'name': nameController.text,
                      'price': int.parse(priceController.text),
                      'stock': int.parse(stockController.text),
                      'category': selectedCategory,
                      'image': selectedImageBytes ?? selectedImagePath ?? product['image'],
                      'description': descriptionController.text,
                      'isFile': selectedImagePath != null,
                    };
                    ProductService.updateProduct(index, updatedProduct);
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produk berhasil diupdate')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Harap isi semua field')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Manajemen Produk UMKM Elok Mekar Sari',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kDark,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tambah Produk'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 180,
                          child: _buildProductImageWidget(product['image']),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: product['active'] ? kDark : kGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${product['price']} • Stok: ${product['stock']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: kGray,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product['category'] ?? 'Kategori tidak tersedia',
                              style: TextStyle(
                                fontSize: 14,
                                color: kGray,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              product['description']?.toString().isNotEmpty == true
                                  ? product['description']
                                  : 'Tidak ada deskripsi produk',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: kDark,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _editProduct(index),
                                    icon: const Icon(Icons.edit, color: Colors.black),
                                    label: const Text(
                                      'Edit',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.black),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _deleteProduct(index),
                                    icon: const Icon(Icons.delete, color: Colors.black),
                                    label: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.black),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ========== ORDER MANAGEMENT TAB (FIREBASE) ==========
class OrderManagementTab extends StatefulWidget {
  const OrderManagementTab({Key? key}) : super(key: key);

  @override
  State<OrderManagementTab> createState() => _OrderManagementTabState();
}

class _OrderManagementTabState extends State<OrderManagementTab> {
  String _selectedStatus = 'Semua';
  final List<String> _statusOptions = ['Semua', 'pending', 'diproses', 'dikirim', 'selesai', 'dibatalkan'];

  // Label tampilan untuk setiap status
  String _statusLabel(String status) {
    switch (status) {
      case 'pending':     return 'Menunggu Pembayaran';
      case 'diproses':    return 'Sedang Diproses';
      case 'dikirim':     return 'Dalam Pengiriman';
      case 'selesai':     return 'Selesai';
      case 'dibatalkan':  return 'Dibatalkan';
      default:            return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':     return Colors.orange;
      case 'diproses':    return Colors.blue;
      case 'dikirim':     return Colors.purple;
      case 'selesai':     return kGreen;
      case 'dibatalkan':  return Colors.red;
      default:            return kGray;
    }
  }

  // Format nomor order: EMS-YYYYMMDD-XXXX
  String _formatOrderId(String rawId) {
    final short = rawId.substring(0, 4).toUpperCase();
    final now = DateTime.now();
    final date = '${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}';
    return 'EMS-$date-$short';
  }

  // Admin update status pesanan
  Future<void> _updateStatus(String orderId, String newStatus) async {
    final label = _statusLabel(newStatus);
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
        'statusLabel': label,
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': newStatus,
            'label': label,
            'timestamp': Timestamp.now(),
          }
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status diperbarui: $label'),
            backgroundColor: kGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter dropdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statusOptions.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s == 'Semua' ? 'Semua Pesanan' : _statusLabel(s)),
              )).toList(),
              onChanged: (v) => setState(() => _selectedStatus = v!),
              decoration: InputDecoration(
                labelText: 'Filter Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // Realtime order list dari Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .snapshots(), // tanpa orderBy — tidak butuh index
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kGreen));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Sort di Flutter: terbaru di atas
                var docs = List.from(snapshot.data?.docs ?? [])
                  ..sort((a, b) {
                    final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
                    final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
                    if (aTs == null || bTs == null) return 0;
                    return bTs.compareTo(aTs);
                  });

                // Filter by status
                if (_selectedStatus != 'Semua') {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return data['status'] == _selectedStatus;
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: kBorder),
                        const SizedBox(height: 12),
                        Text(
                          _selectedStatus == 'Semua'
                              ? 'Belum ada pesanan masuk'
                              : 'Tidak ada pesanan ${_statusLabel(_selectedStatus)}',
                          style: const TextStyle(color: kGray, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final rawId = data['orderId'] as String? ?? docs[index].id;
                    final status = data['status'] ?? 'pending';
                    final items = (data['items'] as List<dynamic>?) ?? [];
                    final productNames = items
                        .map((e) => '${e['productName']} x${e['quantity']}')
                        .join(', ');
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    final dateStr = createdAt != null
                        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(createdAt)
                        : '-';

                    // Format nomor order yang rapi
                    String displayOrderId;
                    if (createdAt != null) {
                      final date = DateFormat('yyyyMMdd').format(createdAt);
                      displayOrderId = 'EMS-$date-${rawId.substring(0,4).toUpperCase()}';
                    } else {
                      displayOrderId = 'EMS-${rawId.substring(0,8).toUpperCase()}';
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        title: Text(
                          displayOrderId,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['recipientName'] ?? '-',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              'Rp ${NumberFormat('#,###', 'id_ID').format(data['totalPrice'] ?? 0)} • $dateStr',
                              style: const TextStyle(fontSize: 12, color: kGray),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel(status),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(status),
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                // Produk
                                Text('Produk: $productNames',
                                    style: const TextStyle(fontSize: 13)),
                                const SizedBox(height: 4),
                                // Alamat
                                Text('Alamat: ${data['address'] ?? '-'}',
                                    style: const TextStyle(fontSize: 13, color: kGray)),
                                const SizedBox(height: 4),
                                Text('Pembayaran: ${data['paymentMethod'] ?? '-'}',
                                    style: const TextStyle(fontSize: 13, color: kGray)),
                                const SizedBox(height: 12),

                                // ===== STRUK PEMBAYARAN =====
                                if (data['strukBase64'] != null && (data['strukBase64'] as String).isNotEmpty) ...[
                                  const Text('Bukti Pembayaran:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      // Buka gambar full screen
                                      showDialog(
                                        context: context,
                                        builder: (_) => Dialog(
                                          backgroundColor: Colors.black,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AppBar(
                                                backgroundColor: Colors.black,
                                                leading: IconButton(
                                                  icon: const Icon(Icons.close, color: Colors.white),
                                                  onPressed: () => Navigator.pop(context),
                                                ),
                                                title: const Text('Struk Pembayaran',
                                                    style: TextStyle(color: Colors.white, fontSize: 14)),
                                              ),
                                              InteractiveViewer(
                                                child: Image.memory(
                                                  base64Decode(data['strukBase64'] as String),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 180,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: kBorder),
                                        color: kGreenPale,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.memory(
                                              base64Decode(data['strukBase64'] as String),
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              bottom: 0, left: 0, right: 0,
                                              child: Container(
                                                color: Colors.black.withOpacity(0.5),
                                                padding: const EdgeInsets.symmetric(vertical: 6),
                                                child: const Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                                    SizedBox(width: 4),
                                                    Text('Ketuk untuk perbesar',
                                                        style: TextStyle(color: Colors.white, fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (data['strukUploadedAt'] != null)
                                    Text(
                                      'Diunggah: ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format((data['strukUploadedAt'] as Timestamp).toDate())}',
                                      style: const TextStyle(fontSize: 11, color: kGray),
                                    ),
                                  const SizedBox(height: 12),
                                ] else if (data['paymentMethod'] != null &&
                                    !(data['paymentMethod'] as String).toLowerCase().contains('cod')) ...[
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
                                        SizedBox(width: 8),
                                        Text('Menunggu bukti pembayaran dari user',
                                            style: TextStyle(fontSize: 12, color: Colors.orange)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Tombol update status
                                const Text('Update Status:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: ['pending','diproses','dikirim','selesai','dibatalkan']
                                      .where((s) => s != status)
                                      .map((s) => ElevatedButton(
                                    onPressed: () => _updateStatus(rawId, s),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _statusColor(s),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      _statusLabel(s),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
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
}

// ========== COMPLAINT MANAGEMENT TAB ==========
class ComplaintManagementTab extends StatefulWidget {
  const ComplaintManagementTab({Key? key}) : super(key: key);

  @override
  State<ComplaintManagementTab> createState() => _ComplaintManagementTabState();
}

class _ComplaintManagementTabState extends State<ComplaintManagementTab> {
  String _selectedPriority = 'Semua';
  String _selectedStatus = 'Semua';
  final List<String> _priorityOptions = ['Semua', 'Tinggi', 'Sedang', 'Rendah'];
  final List<String> _statusOptions = [
    'Semua',
    'Pending',
    'Diproses',
    'Selesai',
  ];

  List<Complaint> _filterComplaints(List<Complaint> allComplaints) {
    return allComplaints.where((complaint) {
      final priorityStr = _priorityToString(complaint.priority);
      final statusStr = _statusToString(complaint.status);
      final priorityMatch =
          _selectedPriority == 'Semua' || priorityStr == _selectedPriority;
      final statusMatch =
          _selectedStatus == 'Semua' || statusStr == _selectedStatus;
      return priorityMatch && statusMatch;
    }).toList();
  }

  String _priorityToString(ComplaintPriority priority) {
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

  String _statusToString(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 'Pending';
      case ComplaintStatus.reviewed:
        return 'Diproses';
      case ComplaintStatus.inProgress:
        return 'Diproses';
      case ComplaintStatus.waitingCustomer:
        return 'Diproses';
      case ComplaintStatus.resolved:
        return 'Selesai';
      case ComplaintStatus.closed:
        return 'Selesai';
      case ComplaintStatus.rejected:
        return 'Selesai';
    }
  }

  void _updateComplaintStatus(Complaint complaint, String newStatus) {
    ComplaintStatus statusToSet = ComplaintStatus.submitted;
    if (newStatus == 'Diproses') statusToSet = ComplaintStatus.inProgress;
    if (newStatus == 'Selesai') statusToSet = ComplaintStatus.resolved;

    ComplaintService.updateStatus(complaint.id, statusToSet);
  }

  void _replyToComplaint(Complaint initialComplaint) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StreamBuilder<Complaint?>(
        stream: ComplaintService.streamComplaint(initialComplaint.id),
        builder: (context, snapshot) {
          final complaint = snapshot.data ?? initialComplaint;

          return AlertDialog(
            title: Text('Chat Keluhan #${complaint.id}'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: ComplaintService.streamChatMessages(complaint.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final chatMessages = snapshot.data ?? [];
                        if (chatMessages.isEmpty) {
                          return const Center(child: Text('Belum ada pesan chat.'));
                        }
                        return ListView.builder(
                          itemCount: chatMessages.length,
                          itemBuilder: (context, chatIndex) {
                            final chat = chatMessages[chatIndex];
                            final isAdmin = chat['sender'] == 'admin';
                            return Align(
                              alignment: isAdmin
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isAdmin ? kGreen : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
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
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  if (complaint.chatEnded)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Sesi chat ini telah diakhiri.',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: const InputDecoration(
                              hintText: 'Ketik balasan...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            if (messageController.text.isNotEmpty) {
                              final text = messageController.text;
                              messageController.clear();
                              await ComplaintService.sendChatMessage(
                                complaintId: complaint.id,
                                sender: 'admin',
                                message: text,
                              );
                              await ComplaintService.updateAdminResponse(
                                complaintId: complaint.id,
                                adminResponse: text,
                              );
                            }
                          },
                          icon: const Icon(Icons.send),
                          color: kGreen,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              if (!complaint.chatEnded)
                TextButton(
                  onPressed: () async {
                    await ComplaintService.endChatSession(complaint.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Akhiri Chat', style: TextStyle(color: Colors.red)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPriority,
                    items: _priorityOptions.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedPriority = value!);
                    },
                    decoration: InputDecoration(
                      labelText: 'Prioritas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                    },
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Complaints List
          Expanded(
            child: StreamBuilder<List<Complaint>>(
              stream: ComplaintService.streamAllComplaints(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kGreen));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final allComplaints = snapshot.data ?? [];
                final filteredComplaints = _filterComplaints(allComplaints);

                if (filteredComplaints.isEmpty) {
                  return const Center(child: Text('Tidak ada keluhan ditemukan.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredComplaints.length,
                  itemBuilder: (context, index) {
                    final complaint = filteredComplaints[index];
                    final priorityStr = _priorityToString(complaint.priority);
                    final statusStr = _statusToString(complaint.status);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Keluhan #${complaint.id} - ${complaint.subject}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${complaint.customerName} • ${complaint.createdDate.toString().split(' ')[0]}',
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      priorityStr,
                                      style: TextStyle(
                                        color: priorityStr == 'Tinggi' || priorityStr == 'Mendesak'
                                            ? Colors.red
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      statusStr,
                                      style: TextStyle(
                                        color: _getStatusColor(statusStr),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Deskripsi: ${complaint.description}'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _replyToComplaint(complaint),
                                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                                  label: const Text(
                                    'Balas Chat',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kGreen,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: statusStr,
                                    items: ['Pending', 'Diproses', 'Selesai'].map((
                                      status,
                                    ) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      );
                                    }).toList(),
                                    onChanged: (value) => _updateComplaintStatus(
                                      complaint,
                                      value!,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Status',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red;
      case 'Diproses':
        return Colors.orange;
      case 'Selesai':
        return Colors.green;
      default:
        return kGray;
    }
  }
}

// ========== USER MANAGEMENT TAB ==========
class UserManagementTab extends StatefulWidget {
  const UserManagementTab({Key? key}) : super(key: key);

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'User',
      'active': true,
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'UMKM',
      'active': true,
    },
    {
      'id': '3',
      'name': 'Bob Johnson',
      'email': 'bob@example.com',
      'role': 'User',
      'active': false,
    },
  ];

  void _toggleUserStatus(int index) {
    setState(() {
      _users[index]['active'] = !_users[index]['active'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: kGreen,
                child: Text(
                  user['name'][0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user['name']),
              subtitle: Text('${user['email']} • ${user['role']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user['active'] ? 'Aktif' : 'Blokir',
                    style: TextStyle(
                      color: user['active'] ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: user['active'],
                    onChanged: (value) => _toggleUserStatus(index),
                    activeThumbColor: kGreen,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ========== REPORTS TAB ==========
class ReportsTab extends StatefulWidget {
  const ReportsTab({Key? key}) : super(key: key);

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  Future<void> _exportLaporan(BuildContext context, List<QueryDocumentSnapshot> docs) async {
    try {
      final csvContent = StringBuffer();
      // CSV Header
      csvContent.writeln('ID Order,Tanggal,Nama Penerima,Total Harga,Status,Metode Pembayaran,Alamat');
      
      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final rawId = data['orderId'] as String? ?? doc.id;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final dateStr = createdAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt) : '-';
        final recipientName = data['recipientName'] ?? '-';
        final totalPrice = data['totalPrice'] ?? 0;
        final status = data['status'] ?? '-';
        final paymentMethod = data['paymentMethod'] ?? '-';
        final address = data['address'] ?? '-';
        
        final cleanName = recipientName.replaceAll(',', ' ').replaceAll('\n', ' ').trim();
        final cleanAddress = address.replaceAll(',', ' ').replaceAll('\n', ' ').trim();
        
        csvContent.writeln('$rawId,$dateStr,$cleanName,$totalPrice,$status,$paymentMethod,$cleanAddress');
      }

      if (kIsWeb) {
        // Trigger browser download via launchUrl with data URI
        final bytes = utf8.encode(csvContent.toString());
        final base64Csv = base64Encode(bytes);
        final uri = Uri.parse('data:text/csv;base64,$base64Csv');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Laporan berhasil diunduh'),
                backgroundColor: kGreen,
              ),
            );
          }
        } else {
          throw 'Could not launch CSV download URI';
        }
      } else {
        // Mobile platform (Android / iOS) - Use sharing directly to allow user to save/send the file reliably
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/laporan_penjualan.csv');
        await file.writeAsString(csvContent.toString());
        
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Laporan Penjualan',
          text: 'Berikut adalah laporan penjualan dari aplikasi APB-UMKM Elok Mekar Sari.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal export laporan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kGreen));
        }

        final orderDocs = snapshot.data?.docs ?? [];
        
        // Completed/successful orders (status == selesai)
        final completedOrders = orderDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'selesai';
        }).toList();

        // Total sales from completed orders
        final totalPenjualanVal = completedOrders.fold<double>(0.0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
          return sum + price;
        });
        final formattedTotalPenjualan = 'Rp ${NumberFormat('#,###', 'id_ID').format(totalPenjualanVal)}';
        
        // Count of completed/successful orders
        final orderBerhasilCount = completedOrders.length;

        // Calculate dynamic weekly/daily chart spots for the last 7 days
        final now = DateTime.now();
        final spots = <FlSpot>[];
        final dailySales = List.filled(7, 0.0);
        
        for (int i = 0; i < 7; i++) {
          final dayStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
          final dayEnd = dayStart.add(const Duration(days: 1));
          
          final sum = completedOrders.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            if (createdAt == null) return false;
            return createdAt.isAfter(dayStart) && createdAt.isBefore(dayEnd);
          }).fold<double>(0.0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
            return sum + price;
          });
          dailySales[i] = sum;
        }

        final allZero = dailySales.every((val) => val == 0.0);
        for (int i = 0; i < 7; i++) {
          spots.add(FlSpot(i.toDouble(), allZero ? (10000.0 * (i + 1)) : dailySales[i]));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Laporan & Statistik',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 20),

              // Sales Chart
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Penjualan Mingguan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: kGreen,
                                barWidth: 4,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: kGreen.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Export Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _exportLaporan(context, orderDocs),
                  icon: const Icon(Icons.download, color: Colors.black),
                  label: const Text(
                    'Export Laporan',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Summary Stats
              const Text(
                'Ringkasan Bulanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Total Penjualan', formattedTotalPenjualan),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Order Berhasil', orderBerhasilCount.toString())),
                ],
              ),
              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text(
                            'Apakah Anda yakin ingin logout dari akun admin?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/', // Navigate to login page
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.black,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: kGray),
            ),
          ],
        ),
      ),
    );
  }
}