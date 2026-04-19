import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'Chatbot.dart' as chatbot;

// bagian warna
const kGreen = Color(0xFF2D5A27);
const kGreenLight = Color(0xFF4A8C3F);
const kGreenPale = Color(0xFFEAF2E6);
const kCream = Color(0xFFF5F0E8);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

// MODELS 
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final double rating;
  final int reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.rating,
    required this.reviews,
  });
}

class Order {
  final String orderId;
  final String productName;
  final int quantity;
  final double totalPrice;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final String paymentMethod;

  Order({
    required this.orderId,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    this.estimatedDelivery,
    required this.paymentMethod,
  });
}

enum OrderStatus {
  pending,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled
}

// MARKETPLACE PAGE 
class MarketplacePage extends StatefulWidget {
  const MarketplacePage({Key? key}) : super(key: key);

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  String selectedCategory = 'Semua';
  final List<String> categories = ['Semua', 'Makanan', 'Minuman', 'Camilan'];

  // Sample data produk UMKM
  final List<Product> allProducts = [
    Product(
      id: 'UMKM-001',
      name: 'Nugget Lele',
      description: 'Nugget ikan lele gurih dengan rempah khas UMKM lokal.',
      price: 25000,
      imageUrl: 'assets/nugget_lele.jpg',
      category: 'Makanan',
      stock: 120,
      rating: 4.7,
      reviews: 210,
    ),
    Product(
      id: 'UMKM-002',
      name: 'Sempol Jamur',
      description: 'Sempol batagor jamur crispy dengan saus pedas manis.',
      price: 18000,
      imageUrl: 'assets/sempol_jamur.jpg',
      category: 'Makanan',
      stock: 95,
      rating: 4.6,
      reviews: 180,
    ),
    Product(
      id: 'UMKM-003',
      name: 'Tahu Walik',
      description: 'Tahu walik renyah isi daging ayam jamur yang legit.',
      price: 11000,
      imageUrl: 'assets/tahu_walik.jpg',
      category: 'Makanan',
      stock: 75,
      rating: 4.5,
      reviews: 165,
    ),
    Product(
      id: 'UMKM-004',
      name: 'Jangkrik Krispi',
      description: 'Camilan protein tinggi dari jangkrik goreng renyah.',
      price: 22000,
      imageUrl: 'assets/jangkrik_krispi.jpg',
      category: 'Camilan',
      stock: 55,
      rating: 4.4,
      reviews: 89,
    ),
    Product(
      id: 'UMKM-005',
      name: 'Jamu Sinom Jamur Tiram',
      description: 'Jamu Sinom sehat dengan ekstrak jamur tiram dan jahe.',
      price: 15000,
      imageUrl: 'assets/jamu_sinom.jpg',
      category: 'Minuman',
      stock: 80,
      rating: 4.8,
      reviews: 205,
    ),
    Product(
      id: 'UMKM-006',
      name: 'Sate Jamur & Abon Lele',
      description: 'Sate jamur lezat dipadu abon lele gurih untuk cemilan sehat.',
      price: 29000,
      imageUrl: 'assets/sate_jamur_abon_lele.jpg',
      category: 'Makanan',
      stock: 60,
      rating: 4.7,
      reviews: 135,
    ),
  ];

  List<Product> get filteredProducts {
    if (selectedCategory == 'Semua') {
      return allProducts;
    }
    return allProducts.where((p) => p.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        elevation: 0,
        backgroundColor: kGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined),
            tooltip: 'Chat dengan Asisten',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const chatbot.ChatbotPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chatbot prompt banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const chatbot.ChatbotPage()),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kGreenPale,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.chat_bubble_outline, color: kGreen),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Butuh bantuan? Chat dengan asisten kami',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tanyakan soal produk, pesanan, atau keluhan di sini.',
                            style: TextStyle(fontSize: 12, color: kGray),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: kGray),
                  ],
                ),
              ),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Category filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    backgroundColor: kBorder.withValues(alpha: 0.3),
                    selectedColor: kGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : kDark,
                    ),
                  ),
                );
              },
            ),
          ),

          // Product grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==PRODUCT CARD==
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  void _shareProduct(BuildContext context) {
    final url = 'https://marketplace.app/product/${product.id}';
    final message =
        'Cek produk ini: ${product.name}\n${product.description}\nHarga: Rp ${NumberFormat('#,###', 'id_ID').format(product.price)}\n\nLihat detail produk: $url';
    Share.share(message, subject: 'Bagikan produk UMKM');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kBorder.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Icon(Icons.image, size: 50, color: kGray),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _shareProduct(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: kGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),

            // Product info
              Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '(${product.reviews})',
                        style: TextStyle(fontSize: 9, color: kGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(product.price)}',
                    style: TextStyle(
                      color: kGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),
            // Add to cart button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                height: 34,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} ditambahkan ke keranjang'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text(
                    'Beli',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =PRODUCT DETAIL PAGE=
class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: kGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Container(
              width: double.infinity,
              height: 250,
              color: kGreenPale,
              child: Icon(Icons.image, size: 100, color: kGray),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.product.rating} (${widget.product.reviews} ulasan)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(widget.product.price)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kGreen,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Stock info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kGreenPale,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: kGreen),
                        const SizedBox(width: 12),
                        Text(
                          'Stok tersedia: ${widget.product.stock} unit',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity selector
                  Row(
                    children: [
                      const Text('Jumlah:', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: kBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() => quantity--);
                                }
                              },
                              icon: const Icon(Icons.remove, color: kGreen),
                              iconSize: 18,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (quantity < widget.product.stock) {
                                  setState(() => quantity++);
                                }
                              },
                              icon: const Icon(Icons.add, color: kGreen),
                              iconSize: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Share buttons
                  Text(
                    'Bagikan Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ShareButton(
                        icon: Icons.share,
                        label: 'Share',
                        backgroundColor: kGreen,
                        onPressed: () => _shareProduct(),
                      ),
                      ShareButton(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        backgroundColor: const Color(0xFF1877F2),
                        onPressed: () => _shareToFacebook(),
                      ),
                      ShareButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Instagram',
                        backgroundColor: Colors.pink.shade400,
                        onPressed: () => _shareToInstagram(),
                      ),
                      ShareButton(
                        icon: Icons.chat,
                        label: 'WhatsApp',
                        backgroundColor: Colors.green.shade500,
                        onPressed: () => _shareToWhatsApp(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Buy button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${quantity}x ${widget.product.name} ditambahkan ke keranjang',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Tambahkan ke Keranjang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareProduct() {
    final url = 'https://marketplace.app/product/${widget.product.id}';
    final message =
        'Cek produk ini: ${widget.product.name}\n${widget.product.description}\nHarga: Rp ${NumberFormat('#,###', 'id_ID').format(widget.product.price)}\n\nLihat detail produk: $url';
    Share.share(message, subject: 'Produk Menarik di Marketplace');
  }

  void _shareToFacebook() {
    final url =
        'https://www.facebook.com/sharer/sharer.php?u=https://marketplace.app/product/${widget.product.id}&quote=${Uri.encodeComponent(widget.product.name)}';
    _launchUrl(url);
  }

  void _shareToInstagram() {
    final url =
        'https://www.instagram.com/?url=https://marketplace.app/product/${widget.product.id}';
    final message =
        'Cek produk ini: ${widget.product.name}\n${widget.product.description}\nHarga: Rp ${NumberFormat('#,###', 'id_ID').format(widget.product.price)}\n\n$url';
    Share.share(message, subject: 'Bagikan ke Instagram');
  }

  void _shareToWhatsApp() {
    final url =
        'https://api.whatsapp.com/send?text=${Uri.encodeComponent('Halo! Saya ingin berbagi produk ini dengan Anda 😊\n\n${widget.product.name}\n${widget.product.description}\n\n💰 Harga: Rp ${NumberFormat('#,###', 'id_ID').format(widget.product.price)}\n\nLihat detail: https://marketplace.app/product/${widget.product.id}') }';
    _launchUrl(url);
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

// == SHARE BUTTON==
class ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const ShareButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor ?? kBorder.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: backgroundColor != null ? Colors.white : kGray,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// = ORDER TRACKING PAGE=
class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  // Sample order data
  final List<Order> orders = [
    Order(
      orderId: 'ORD-2024-001',
      productName: 'Nugget Lele',
      quantity: 2,
      totalPrice: 50000,
      status: OrderStatus.delivered,
      orderDate: DateTime(2024, 4, 1),
      estimatedDelivery: DateTime(2024, 4, 4),
      paymentMethod: 'Transfer Bank',
    ),
    Order(
      orderId: 'ORD-2024-002',
      productName: 'Sempol Jamur',
      quantity: 3,
      totalPrice: 54000,
      status: OrderStatus.outForDelivery,
      orderDate: DateTime(2024, 4, 5),
      estimatedDelivery: DateTime(2024, 4, 8),
      paymentMethod: 'E-Wallet',
    ),
    Order(
      orderId: 'ORD-2024-003',
      productName: 'Tahu Walik',
      quantity: 4,
      totalPrice: 44000,
      status: OrderStatus.shipped,
      orderDate: DateTime(2024, 4, 8),
      estimatedDelivery: DateTime(2024, 4, 12),
      paymentMethod: 'Transfer Bank',
    ),
    Order(
      orderId: 'ORD-2024-004',
      productName: 'Jamu Sinom Jamur Tiram',
      quantity: 1,
      totalPrice: 15000,
      status: OrderStatus.processing,
      orderDate: DateTime(2024, 4, 10),
      estimatedDelivery: DateTime(2024, 4, 14),
      paymentMethod: 'Ovo',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Pesanan'),
        backgroundColor: kGreen,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderCard(order: orders[index]);
        },
      ),
    );
  }
}

// ORDER CARD 
class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(order: order),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesanan ${order.orderId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                      color: _getStatusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah: ${order.quantity}x',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy', 'id_ID').format(order.orderDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: kGray,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(order.totalPrice)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (order.estimatedDelivery != null)
                        Text(
                          'Est: ${DateFormat('dd MMM', 'id_ID').format(order.estimatedDelivery!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber.shade700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _getProgressValue(order.status),
                  minHeight: 6,
                  backgroundColor: kBorder.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return kGreen;
      case OrderStatus.shipped:
        return kGreenLight;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Menunggu Pembayaran';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.shipped:
        return 'Dikirim';
      case OrderStatus.outForDelivery:
        return 'Dalam Pengiriman';
      case OrderStatus.delivered:
        return 'Tiba';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  double _getProgressValue(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0.2;
      case OrderStatus.processing:
        return 0.4;
      case OrderStatus.shipped:
        return 0.6;
      case OrderStatus.outForDelivery:
        return 0.8;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }
}

// ORDER DETAIL PAGE
class OrderDetailPage extends StatelessWidget {
  final Order order;

  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: kGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order status card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Pesanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getStatusIcon(order.status),
                            color: _getStatusColor(order.status),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusText(order.status),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (order.estimatedDelivery != null)
                              Text(
                                'Est. tiba: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(order.estimatedDelivery!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kGray,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Timeline
            Text(
              'Tracking Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeline(),
            const SizedBox(height: 24),

            // Order details
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pesanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Nomor Pesanan', order.orderId),
                    const Divider(),
                    _buildDetailRow('Produk', order.productName),
                    const Divider(),
                    _buildDetailRow('Jumlah', '${order.quantity}x'),
                    const Divider(),
                    _buildDetailRow(
                      'Total Harga',
                      'Rp ${NumberFormat('#,###', 'id_ID').format(order.totalPrice)}',
                      isBold: true,
                    ),
                    const Divider(),
                    _buildDetailRow('Metode Pembayaran', order.paymentMethod),
                    const Divider(),
                    _buildDetailRow(
                      'Tanggal Pesanan',
                      DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(order.orderDate),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hubungi customer service'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Hubungi CS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Share.share(
                        'Pesanan saya ${order.orderId} untuk ${order.productName} sedang dalam status: ${_getStatusText(order.status)}',
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: kGray,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: kDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = [
      {'label': 'Pesanan Diterima', 'status': true},
      {'label': 'Pembayaran Dikonfirmasi', 'status': true},
      {'label': 'Diproses', 'status': order.status.index >= OrderStatus.processing.index},
      {'label': 'Dikirim', 'status': order.status.index >= OrderStatus.shipped.index},
      {'label': 'Dalam Pengiriman', 'status': order.status.index >= OrderStatus.outForDelivery.index},
      {'label': 'Tiba', 'status': order.status.index >= OrderStatus.delivered.index},
    ];

    return Column(
      children: List.generate(
        steps.length,
        (index) {
          final step = steps[index];
          final isCompleted = step['status'] as bool;
          final isLast = index == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted ? kGreen : kBorder.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.schedule,
                      color: isCompleted ? Colors.white : kGray,
                      size: 20,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: isCompleted ? kGreen : kBorder.withValues(alpha: 0.3),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isCompleted ? kDark : kGray,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return kGreen;
      case OrderStatus.shipped:
        return kGreenLight;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Menunggu Pembayaran';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.shipped:
        return 'Dikirim';
      case OrderStatus.outForDelivery:
        return 'Dalam Pengiriman';
      case OrderStatus.delivered:
        return 'Tiba';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.processing:
        return Icons.hourglass_bottom;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.outForDelivery:
        return Icons.directions_bike;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}
