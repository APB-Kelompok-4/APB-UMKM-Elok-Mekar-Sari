import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

const kGreen = Color(0xFF2D5A27);
const kGreenLight = Color(0xFF4A8C3F);
const kGreenPale = Color(0xFFEAF2E6);
const kCream = Color(0xFFF5F0E8);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

// ========== UMKM PAGE ==========
class UMKMPage extends StatefulWidget {
  const UMKMPage({Key? key}) : super(key: key);

  @override
  State<UMKMPage> createState() => _UMKMPageState();
}

class _UMKMPageState extends State<UMKMPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    UMKMDashboardTab(),
    ManageProductTab(),
    ManageOrderTab(),
    SalesReportTab(),
    ProfileTab(),
  ];

  static const List<String> _appBarTitles = <String>[
    'UMKM Panel',
    'Produk',
    'Order',
    'Laporan',
    'Profil',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: kGreen,
        elevation: 0,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
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

// ========== UMKM DASHBOARD TAB ==========
class UMKMDashboardTab extends StatelessWidget {
  const UMKMDashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard UMKM',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kDark,
            ),
          ),
          const SizedBox(height: 20),

          // Store Name
          Card(
            elevation: 2,
            color: kGreenPale,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '🏪',
                    style: TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Toko Elok Mekar Sari',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kDark,
                        ),
                      ),
                      Text(
                        'Produk Lokal Berkualitas',
                        style: TextStyle(
                          fontSize: 12,
                          color: kGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Pendapatan Bulan Ini',
                  'Rp 2.500.000',
                  Icons.attach_money,
                  kGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Order',
                  '45',
                  Icons.shopping_cart,
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
                  'Produk Aktif',
                  '12',
                  Icons.inventory,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Stok Menipis',
                  '2',
                  Icons.warning,
                  Colors.orange,
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

          // Top Products
          const Text(
            'Produk Terlaris',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopProductsList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: kGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersList() {
    final orders = [
      {
        'id': 'ORD001',
        'customer': 'Budi Santoso',
        'items': 'Nasi Gudeg x2',
        'status': 'Dikemas',
        'total': 50000
      },
      {
        'id': 'ORD002',
        'customer': 'Siti Nurhaliza',
        'items': 'Keripik Tempe x3',
        'status': 'Dikirim',
        'total': 45000
      },
      {
        'id': 'ORD003',
        'customer': 'Ahmad Wijaya',
        'items': 'Nasi Gudeg x1',
        'status': 'Pending',
        'total': 25000
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
            title: Text('${order['id']} - ${order['customer']}'),
            subtitle: Text(order['items'] as String),
            trailing: Text(
              order['status'] as String,
              style: TextStyle(
                color: _getStatusColor(order['status'] as String),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopProductsList() {
    final products = [
      {'name': 'Nugget Lele', 'sold': 35, 'revenue': 'Rp 525.000'},
      {'name': 'Sempol Jamur', 'sold': 28, 'revenue': 'Rp 420.000'},
      {'name': 'Tahu Walik', 'sold': 22, 'revenue': 'Rp 330.000'},
      {'name': 'Jangkrik Krispi', 'sold': 18, 'revenue': 'Rp 270.000'},
      {'name': 'Sate Jamur', 'sold': 15, 'revenue': 'Rp 225.000'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(product['name'] as String),
            subtitle: Text('Terjual: ${product['sold']} unit'),
            trailing: Text(
              product['revenue'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kGreen,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red;
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

// ========== MANAGE PRODUCT TAB ==========
class ManageProductTab extends StatefulWidget {
  const ManageProductTab({Key? key}) : super(key: key);

  @override
  State<ManageProductTab> createState() => _ManageProductTabState();
}

class _ManageProductTabState extends State<ManageProductTab> {
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'Nugget Lele',
      'price': 25000,
      'stock': 50,
      'category': 'Makanan',
      'active': true,
      'image': '🍛',
      'description': 'Nugget lele olahan alami tanpa pengawet'
    },
    {
      'id': '2',
      'name': 'Sempol Jamur',
      'price': 15000,
      'stock': 30,
      'category': 'Snack',
      'active': true,
      'image': '🍄',
      'description': 'Sempol jamur tiram renyah dan gurih'
    },
    {
      'id': '3',
      'name': 'Tahu Walik',
      'price': 20000,
      'stock': 20,
      'category': 'Makanan',
      'active': true,
      'image': '🍲',
      'description': 'Tahu walik isi ayam homemade'
    },
    {
      'id': '4',
      'name': 'Jangkrik Krispi',
      'price': 18000,
      'stock': 15,
      'category': 'Snack',
      'active': true,
      'image': '🐜',
      'description': 'Jangkrik krispi gurih dan bergizi'
    },
    {
      'id': '5',
      'name': 'Sinom',
      'price': 12000,
      'stock': 40,
      'category': 'Minuman',
      'active': true,
      'image': '🥤',
      'description': 'Minuman sinom segar dari bahan alami'
    },
    {
      'id': '6',
      'name': 'Sate Jamur',
      'price': 22000,
      'stock': 25,
      'category': 'Makanan',
      'active': true,
      'image': '🍢',
      'description': 'Sate jamur tiram dengan bumbu spesial'
    },
  ];

  void _toggleProductStatus(int index) {
    setState(() {
      _products[index]['active'] = !_products[index]['active'];
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk dihapus')),
    );
  }

  void _editStock(int index) {
    final TextEditingController stockController =
        TextEditingController(text: _products[index]['stock'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stok'),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Stok Baru',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _products[index]['stock'] = int.parse(stockController.text);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stok berhasil diperbarui')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kGreen),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onAdd: (newProduct) {
          setState(() {
            _products.add(newProduct);
          });
        },
      ),
    );
  }

  void _editProduct(int index) {
    showDialog(
      context: context,
      builder: (context) => EditProductDialog(
        product: _products[index],
        onSave: (updatedProduct) {
          setState(() {
            _products[index] = updatedProduct;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      product['isFile'] == true
                          ? Image.file(File(product['image']), height: 40, width: 40, fit: BoxFit.cover)
                          : Text(
                              product['image'],
                              style: const TextStyle(fontSize: 40),
                            ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Rp ${product['price']} • Stok: ${product['stock']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: kGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: product['active'],
                        onChanged: (value) => _toggleProductStatus(index),
                        activeThumbColor: kGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _editStock(index),
                        icon: const Icon(Icons.edit, color: Colors.black),
                        label: const Text(
                          'Stok',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _editProduct(index),
                        icon: const Icon(Icons.edit, color: Colors.black),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _deleteProduct(index),
                        icon: const Icon(Icons.delete, color: Colors.black),
                        label: const Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// ========== MANAGE ORDER TAB ==========
class ManageOrderTab extends StatefulWidget {
  const ManageOrderTab({Key? key}) : super(key: key);

  @override
  State<ManageOrderTab> createState() => _ManageOrderTabState();
}

class _ManageOrderTabState extends State<ManageOrderTab> {
  String _selectedStatus = 'Semua';
  final List<String> _statusOptions = ['Semua', 'Pending', 'Dikemas', 'Dikirim', 'Selesai'];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD001',
      'customer': 'Budi Santoso',
      'phone': '08123456789',
      'address': 'Jl. Merdeka 123, Surabaya',
      'items': ['Nasi Gudeg x2'],
      'status': 'Pending',
      'total': 50000,
      'date': '2024-01-15',
      'notes': ''
    },
    {
      'id': 'ORD002',
      'customer': 'Siti Nurhaliza',
      'phone': '08987654321',
      'address': 'Jl. Ahmad Yani 456, Surabaya',
      'items': ['Keripik Tempe x3', 'Sambal Goreng x1'],
      'status': 'Dikemas',
      'total': 75000,
      'date': '2024-01-14',
      'notes': 'Paket khusus untuk acara'
    },
    {
      'id': 'ORD003',
      'customer': 'Ahmad Wijaya',
      'phone': '08765432109',
      'address': 'Jl. Basuki Rahmat 789, Surabaya',
      'items': ['Nasi Gudeg x1'],
      'status': 'Dikirim',
      'total': 25000,
      'date': '2024-01-13',
      'notes': ''
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedStatus == 'Semua') return _orders;
    return _orders.where((order) => order['status'] == _selectedStatus).toList();
  }

  void _updateOrderStatus(int index, String newStatus) {
    setState(() {
      _orders[index]['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status order diperbarui ke $newStatus')),
    );
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
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
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
                final actualIndex = _orders.indexWhere((o) => o['id'] == order['id']);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text('${order['id']} - ${order['customer']}'),
                    subtitle: Text('Rp ${order['total']} • ${order['date']}'),
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
                            Text('Alamat: ${order['address']}'),
                            Text('Telepon: ${order['phone']}'),
                            const SizedBox(height: 8),
                            Text('Items: ${order['items'].join(", ")}'),
                            const SizedBox(height: 8),
                            const Text('Update Status:'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: ['Pending', 'Dikemas', 'Dikirim', 'Selesai']
                                  .map((status) {
                                return ElevatedButton(
                                  onPressed: order['status'] == status
                                      ? null
                                      : () => _updateOrderStatus(actualIndex, status),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: order['status'] == status ? kGray : kGreen,
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
      case 'Pending':
        return Colors.red;
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

// ========== SALES REPORT TAB ==========
class SalesReportTab extends StatelessWidget {
  const SalesReportTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Penjualan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kDark,
            ),
          ),
          const SizedBox(height: 20),

          // Revenue Chart
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
                    'Omzet Penjualan Mingguan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const titles = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                                  return Text(titles[value.toInt()]);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                              reservedSize: 0,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [BarChartRodData(toY: 300000, color: kGreen)],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [BarChartRodData(toY: 420000, color: kGreen)],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [BarChartRodData(toY: 280000, color: kGreen)],
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [BarChartRodData(toY: 500000, color: kGreen)],
                          ),
                          BarChartGroupData(
                            x: 4,
                            barRods: [BarChartRodData(toY: 450000, color: kGreen)],
                          ),
                          BarChartGroupData(
                            x: 5,
                            barRods: [BarChartRodData(toY: 600000, color: kGreen)],
                          ),
                          BarChartGroupData(
                            x: 6,
                            barRods: [BarChartRodData(toY: 550000, color: kGreen)],
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

          // Top Products
          const Text(
            'Produk Terlaris',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopProductsChart(),

          const SizedBox(height: 20),

          // Summary Stats
          const Text(
            'Ringkasan Bulan Ini',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Omzet', 'Rp 2.500.000', kGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Total Order', '45', kGreenLight),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Rata-rata Order', 'Rp 55.555', Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Produk Terjual', '98', Colors.orange),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Export Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Laporan siap diunduh')),
                );
              },
              icon: const Icon(Icons.download, color: Colors.black),
              label: const Text(
                'Download Laporan',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
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

  Widget _buildTopProductsChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProductRow('Nugget Lele', '35 terjual', 'Rp 525.000'),
            const SizedBox(height: 12),
            _buildProductRow('Sempol Jamur', '28 terjual', 'Rp 420.000'),
            const SizedBox(height: 12),
            _buildProductRow('Tahu Walik', '22 terjual', 'Rp 330.000'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(String name, String sold, String revenue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                sold,
                style: TextStyle(fontSize: 12, color: kGray),
              ),
            ],
          ),
        ),
        Text(
          revenue,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: kGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: kGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== PROFILE TAB ==========
class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _storeNameController = TextEditingController(text: 'Toko Elok Mekar Sari');
  final _descriptionController = TextEditingController(
    text: 'Menjual produk lokal berkualitas dari Jawa Timur',
  );
  final _phoneController = TextEditingController(text: '08123456789');
  final _emailController = TextEditingController(text: 'toko@elokmekarsari.com');
  final _addressController = TextEditingController(text: 'Jl. Merdeka 123, Surabaya');

  bool _isEditing = false;

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Store Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGreen, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: kGreenPale,
                  child: Text(
                    '🏪',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
              if (_isEditing)
                FloatingActionButton(
                  mini: true,
                  backgroundColor: kGreen,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur ubah foto sedang dikembangkan')),
                    );
                  },
                  child: const Icon(Icons.camera_alt),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Store Name
          _buildProfileField(
            label: 'Nama Toko',
            controller: _storeNameController,
            enabled: _isEditing,
          ),

          const SizedBox(height: 16),

          // Description
          _buildProfileField(
            label: 'Deskripsi',
            controller: _descriptionController,
            enabled: _isEditing,
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Phone
          _buildProfileField(
            label: 'Nomor Telepon',
            controller: _phoneController,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 16),

          // Email
          _buildProfileField(
            label: 'Email',
            controller: _emailController,
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // Address
          _buildProfileField(
            label: 'Alamat',
            controller: _addressController,
            enabled: _isEditing,
            maxLines: 2,
          ),

          const SizedBox(height: 32),

          // Edit/Save Button
          SizedBox(
            width: double.infinity,
            child: _isEditing
                ? ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _toggleEdit,
                    icon: const Icon(Icons.edit, color: Colors.black),
                    label: const Text(
                      'Edit Profil',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.black),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.black,
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

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kGreen, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorder),
            ),
            filled: !enabled,
            fillColor: !enabled ? kBg : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

// ========== ADD PRODUCT DIALOG ==========
class AddProductDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddProductDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedImage = '🍛';
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Produk Baru'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : const Icon(Icons.add_photo_alternate, size: 40, color: kGray),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Tap untuk pilih gambar produk', style: TextStyle(color: kGray, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Isi semua data wajib')),
              );
              return;
            }

            widget.onAdd({
              'id': DateTime.now().toString(),
              'name': _nameController.text,
              'price': int.parse(_priceController.text),
              'stock': int.parse(_stockController.text),
              'category': _categoryController.text,
              'description': _descriptionController.text,
              'active': true,
              'image': _imageFile?.path ?? _selectedImage,
              'isFile': _imageFile != null,
            });

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil ditambahkan')),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: kGreen),
          child: const Text('Tambah'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// ========== EDIT PRODUCT DIALOG ==========
class EditProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onSave;

  const EditProductDialog({
    Key? key,
    required this.product,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _priceController = TextEditingController(text: widget.product['price'].toString());
    _categoryController = TextEditingController(text: widget.product['category']);
    _descriptionController = TextEditingController(text: widget.product['description']);
    if (widget.product['isFile'] == true) {
      _imageFile = File(widget.product['image']);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Produk'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : (widget.product['isFile'] == true
                        ? Image.file(File(widget.product['image']), fit: BoxFit.cover)
                        : Text(widget.product['image'], style: const TextStyle(fontSize: 40))),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Tap untuk pilih gambar produk', style: TextStyle(color: kGray, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.product['name'] = _nameController.text;
            widget.product['price'] = int.parse(_priceController.text);
            widget.product['category'] = _categoryController.text;
            widget.product['description'] = _descriptionController.text;
            if (_imageFile != null) {
              widget.product['image'] = _imageFile!.path;
              widget.product['isFile'] = true;
            }

            widget.onSave(widget.product);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil diperbarui')),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: kGreen),
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}