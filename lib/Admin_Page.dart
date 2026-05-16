import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
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

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardTab(),
    ProductManagementTab(),
    OrderManagementTab(),
    ComplaintManagementTab(),
    UserManagementTab(),
    ReportsTab(),
  ];

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
      return [
        IconButton(
          onPressed: _addProductFromAppBar,
          icon: const Icon(Icons.add),
          tooltip: 'Tambah Produk',
        ),
      ];
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

  void _addProductFromAppBar() {
    // Move to product tab and then open tambah produk modal via a callback in the product tab state.
    if (_selectedIndex == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gunakan tombol Tambah Produk di tab produk untuk menambahkan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: kGreen,
        elevation: 0,
        actions: _getAppBarActions(),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
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
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  '24',
                  Icons.shopping_cart,
                  kGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Pendapatan',
                  'Rp 1.250.000',
                  Icons.attach_money,
                  kGreenLight,
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
                  _getPendingComplaintCount().toString(),
                  Icons.report_problem,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Produk Terlaris',
                  'Nugget Lele',
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
          _buildRecentOrdersList(),

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
          _buildPendingComplaintsList(),
        ],
      ),
    );
  }

  int _getPendingComplaintCount() {
    final umkmProducts = _getUMKMProducts();
    return ComplaintService.complaints.where((complaint) {
      final isPending =
          complaint.status == ComplaintStatus.submitted ||
          complaint.status == ComplaintStatus.inProgress ||
          complaint.status == ComplaintStatus.reviewed ||
          complaint.status == ComplaintStatus.waitingCustomer;
      // Filter hanya keluhan dari produk UMKM yang ada
      final isUMKMProduct =
          complaint.productName != null &&
          umkmProducts.contains(complaint.productName);
      return isPending && isUMKMProduct;
    }).length;
  }

  List<String> _getUMKMProducts() {
    return [
      'Nugget Lele',
      'Sempol Jamur',
      'Tahu Walik',
      'Jangkrik Krispi',
      'Sinom',
      'Sate Jamur',
    ];
  }

  List<Complaint> _getPendingComplaints() {
    final umkmProducts = _getUMKMProducts();
    return ComplaintService.complaints.where((complaint) {
      final isPending =
          complaint.status == ComplaintStatus.submitted ||
          complaint.status == ComplaintStatus.inProgress ||
          complaint.status == ComplaintStatus.reviewed ||
          complaint.status == ComplaintStatus.waitingCustomer;
      // Filter hanya keluhan dari produk UMKM yang ada
      final isUMKMProduct =
          complaint.productName != null &&
          umkmProducts.contains(complaint.productName);
      return isPending && isUMKMProduct;
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
    Color color,
  ) {
    return Card(
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
              style: TextStyle(
                fontSize: 20,
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

  Widget _buildRecentOrdersList() {
    final orders = [
      {
        'id': '001',
        'customer': 'John Doe',
        'status': 'Dikemas',
        'total': 'Rp 50.000',
      },
      {
        'id': '002',
        'customer': 'Jane Smith',
        'status': 'Dikirim',
        'total': 'Rp 75.000',
      },
      {
        'id': '003',
        'customer': 'Bob Johnson',
        'status': 'Selesai',
        'total': 'Rp 30.000',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('Order #${order['id']} - ${order['customer']}'),
            subtitle: Text('Total: ${order['total']}'),
            trailing: Text(
              order['status']!,
              style: TextStyle(
                color: _getStatusColor(order['status']!),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingComplaintsList() {
    final pendingComplaints = _getPendingComplaints();

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
            title: Text(
              'Keluhan #${complaint.id} - ${complaint.productName ?? complaint.subject}',
            ),
            subtitle: Text('Dari: ${complaint.customerName}'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dikemas':
        return Colors.blue;
      case 'Dikirim':
        return Colors.orange;
      case 'Selesai':
        return Colors.green;
      default:
        return kGray;
    }
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

  void _toggleProductStatus(int index) {
    final updatedProduct = Map<String, dynamic>.from(_products[index]);
    updatedProduct['active'] = !(updatedProduct['active'] as bool);
    ProductService.updateProduct(index, updatedProduct);
    setState(() {});
  }

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
                child: const Text('Batal'),
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
                child: const Text('Update'),
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
                ElevatedButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Produk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                  ),
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
                  child: ExpansionTile(
                    leading: _buildProductImageWidget(product['image']),
                    title: Text(
                      product['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: product['active'] ? kDark : kGray,
                      ),
                    ),
                    subtitle: Text(
                      'Rp ${product['price']} • Stok: ${product['stock']} • ${product['category']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: product['active'],
                          onChanged: (value) => _toggleProductStatus(index),
                          activeThumbColor: kGreen,
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editProduct(index);
                            } else if (value == 'delete') {
                              _deleteProduct(index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text('Edit Produk'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus Produk'),
                                ],
                              ),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert, color: Colors.black),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deskripsi Produk',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: kCream,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kBorder),
                              ),
                              child: Text(
                                product['description']?.toString().isNotEmpty == true
                                    ? product['description']
                                    : 'Tidak ada deskripsi produk',
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: kDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Status: ${product['active'] ? 'Aktif' : 'Tidak Aktif'}',
                                  style: TextStyle(
                                    color: product['active']
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
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

// ========== ORDER MANAGEMENT TAB ==========
class OrderManagementTab extends StatefulWidget {
  const OrderManagementTab({Key? key}) : super(key: key);

  @override
  State<OrderManagementTab> createState() => _OrderManagementTabState();
}

class _OrderManagementTabState extends State<OrderManagementTab> {
  String _selectedStatus = 'Semua';
  final List<String> _statusOptions = [
    'Semua',
    'Dikemas',
    'Dikirim',
    'Selesai',
  ];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '001',
      'customer': 'John Doe',
      'status': 'Dikemas',
      'total': 50000,
      'date': '2024-01-15',
      'items': ['Nasi Gudeg x2'],
    },
    {
      'id': '002',
      'customer': 'Jane Smith',
      'status': 'Dikirim',
      'total': 75000,
      'date': '2024-01-14',
      'items': ['Keripik Tempe x3', 'Nasi Gudeg x1'],
    },
    {
      'id': '003',
      'customer': 'Bob Johnson',
      'status': 'Selesai',
      'total': 30000,
      'date': '2024-01-13',
      'items': ['Batik Jogja x1'],
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedStatus == 'Semua') return _orders;
    return _orders
        .where((order) => order['status'] == _selectedStatus)
        .toList();
  }

  void _updateOrderStatus(int index, String newStatus) {
    setState(() {
      _orders[index]['status'] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              items: _statusOptions.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
              decoration: InputDecoration(
                labelText: 'Filter Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text('Order #${order['id']} - ${order['customer']}'),
                    subtitle: Text(
                      'Total: Rp ${order['total']} • ${order['date']}',
                    ),
                    trailing: Text(
                      order['status'],
                      style: TextStyle(
                        color: _getStatusColor(order['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Items: ${order['items'].join(', ')}'),
                            const SizedBox(height: 8),
                            const Text('Update Status:'),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: ['Dikemas', 'Dikirim', 'Selesai'].map((
                                status,
                              ) {
                                return ElevatedButton(
                                  onPressed: order['status'] == status
                                      ? null
                                      : () => _updateOrderStatus(
                                          _orders.indexWhere(
                                            (o) => o['id'] == order['id'],
                                          ),
                                          status,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: order['status'] == status
                                        ? kGray
                                        : kGreen,
                                  ),
                                  child: Text(status),
                                );
                              }).toList(),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dikemas':
        return Colors.blue;
      case 'Dikirim':
        return Colors.orange;
      case 'Selesai':
        return Colors.green;
      default:
        return kGray;
    }
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

  List<Map<String, dynamic>> get _complaints {
    return ComplaintService.complaints
        .map(
          (complaint) => {
            'id': complaint.id,
            'customer': complaint.customerName,
            'subject': complaint.subject,
            'description': complaint.description,
            'priority': _priorityToString(complaint.priority),
            'status': _statusToString(complaint.status),
            'product': complaint.productName ?? 'Umum',
            'date': complaint.createdDate.toString().split(' ')[0],
            'chat': complaint.chat,
          },
        )
        .toList();
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

  List<Map<String, dynamic>> get _filteredComplaints {
    return _complaints.where((complaint) {
      final priorityMatch =
          _selectedPriority == 'Semua' ||
          complaint['priority'] == _selectedPriority;
      final statusMatch =
          _selectedStatus == 'Semua' || complaint['status'] == _selectedStatus;
      return priorityMatch && statusMatch;
    }).toList();
  }

  void _updateComplaintStatus(int index, String newStatus) {
    setState(() {
      _complaints[index]['status'] = newStatus;
    });
  }

  void _replyToComplaint(int index) {
    final complaintMap = _filteredComplaints[index];
    final originalComplaint = ComplaintService.getComplaintById(
      complaintMap['id'],
    )!;
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Chat Keluhan #${complaintMap['id']}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: originalComplaint.chat.length,
                    itemBuilder: (context, chatIndex) {
                      final chat = originalComplaint.chat[chatIndex];
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
                  ),
                ),
                const Divider(),
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
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          final updatedChat =
                              List<Map<String, dynamic>>.from(
                                originalComplaint.chat,
                              )..add({
                                'sender': 'admin',
                                'message': messageController.text,
                                'time': DateTime.now()
                                    .toString()
                                    .substring(0, 16)
                                    .replaceAll('T', ' '),
                              });
                          final updatedComplaint = originalComplaint.copyWith(
                            chat: updatedChat,
                            adminResponse: messageController.text,
                          );
                          ComplaintService.updateComplaint(
                            originalComplaint.id,
                            updatedComplaint,
                          );
                          setState(() {});
                          messageController.clear();
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredComplaints.length,
              itemBuilder: (context, index) {
                final complaint = _filteredComplaints[index];
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
                                    'Keluhan #${complaint['id']} - ${complaint['subject']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${complaint['customer']} • ${complaint['date']}',
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  complaint['priority'],
                                  style: TextStyle(
                                    color: complaint['priority'] == 'Tinggi'
                                        ? Colors.red
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  complaint['status'],
                                  style: TextStyle(
                                    color: _getStatusColor(complaint['status']),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Deskripsi: ${complaint['description']}'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _replyToComplaint(index),
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Balas Chat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: complaint['status'],
                                items: ['Pending', 'Diproses', 'Selesai'].map((
                                  status,
                                ) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: (value) => _updateComplaintStatus(
                                  _complaints.indexWhere(
                                    (c) => c['id'] == complaint['id'],
                                  ),
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
class ReportsTab extends StatelessWidget {
  const ReportsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                            spots: [
                              const FlSpot(0, 100000),
                              const FlSpot(1, 150000),
                              const FlSpot(2, 120000),
                              const FlSpot(3, 180000),
                              const FlSpot(4, 200000),
                              const FlSpot(5, 170000),
                              const FlSpot(6, 220000),
                            ],
                            isCurved: true,
                            color: kGreen,
                            barWidth: 4,
                            belowBarData: BarAreaData(
                              show: true,
                              color: kGreen.withValues(alpha: 0.1),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur export laporan sedang dikembangkan'),
                  ),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Export Laporan'),
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
                child: _buildStatCard('Total Penjualan', 'Rp 5.200.000'),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Order Berhasil', '156')),
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
              style: const TextStyle(
                fontSize: 18,
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
