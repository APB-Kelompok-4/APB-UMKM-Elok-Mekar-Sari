import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Chatbot.dart' as chatbot;
import 'services/product_service.dart';
import 'Sistem Keluhan_Feedback.dart';
import 'package:image_picker/image_picker.dart';

// bagian warna
const kGreen = Color(0xFF2D5A27);
const kGreenLight = Color(0xFF4A8C3F);
const kGreenPale = Color(0xFFEAF2E6);
const kCream = Color(0xFFF5F0E8);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

// ========== CART ITEM MODEL ==========
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;
}

// ========== CART MANAGER (Singleton) ==========
class CartManager {
  static final CartManager _instance = CartManager._internal();

  factory CartManager() {
    return _instance;
  }

  CartManager._internal();

  final ValueNotifier<List<CartItem>> cartItems = ValueNotifier([]);

  void addToCart(Product product, {int qty = 1}) {
    final items = List<CartItem>.from(cartItems.value);
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      items[existingIndex].quantity += qty;
    } else {
      items.add(CartItem(product: product, quantity: qty));
    }
    cartItems.value = items;
  }

  void removeFromCart(String productId) {
    final items = List<CartItem>.from(cartItems.value);
    items.removeWhere((item) => item.product.id == productId);
    cartItems.value = items;
  }

  void updateQuantity(String productId, int newQuantity) {
    final items = List<CartItem>.from(cartItems.value);
    final itemIndex = items.indexWhere((item) => item.product.id == productId);
    
    if (itemIndex >= 0) {
      if (newQuantity <= 0) {
        removeFromCart(productId);
      } else {
        items[itemIndex].quantity = newQuantity;
        cartItems.value = items;
      }
    }
  }

  double get totalPrice => cartItems.value.fold(0.0, (sum, item) => sum + item.subtotal);

  int get itemCount => cartItems.value.length;

  int get totalItems => cartItems.value.fold(0, (sum, item) => sum + item.quantity);

  void clearCart() {
    cartItems.value = [];
  }
}

// MODELS
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final dynamic imageUrl;
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

Widget buildProductImage(dynamic img, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (img is Uint8List && img.isNotEmpty) {
    return Image.memory(
      img,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40, color: kGray),
    );
  }

  if (img is String && img.startsWith('assets/')) {
    return Image.asset(
      img,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40, color: kGray),
    );
  }

  if (img is String && (img.contains('/') || img.contains('\\'))) {
    final file = File(img);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40, color: kGray),
      );
    }
  }

  if (img is String && (img.startsWith('http://') || img.startsWith('https://'))) {
    return Image.network(
      img,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40, color: kGray),
    );
  }

  return Icon(Icons.image, size: 40, color: kGray);
}

// MARKETPLACE PAGE
class MarketplacePage extends StatefulWidget {
  const MarketplacePage({Key? key}) : super(key: key);

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  String selectedCategory = 'Semua';
  final List<String> categories = ['Semua', 'Makanan', 'Minuman', 'Snack'];

  // Convert ProductService data to Product model
  List<Product> _getProductsFromService() {
    return ProductService.getActiveProducts().map((p) {
      return Product(
        id: p['id'] ?? 'PROD-${p['name']}',
        name: p['name'] ?? 'Produk',
        description: p['description'] ?? '',
        price: (p['price'] ?? 0).toDouble(),
        imageUrl: p['image'] ?? '📦',
        category: p['category'] ?? 'Lainnya',
        stock: p['stock'] ?? 0,
        rating: 4.5,
        reviews: 0,
      );
    }).toList();
  }

  List<Product> get allProducts => _getProductsFromService();

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
        title: const Text(
          'Marketplace',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: kGreen,
        actions: [
          // Keranjang Icon
          ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartManager().cartItems,
            builder: (context, items, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 26,
                    ),
                    tooltip: 'Keranjang',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartPage()),
                      );
                    },
                  ),
                  if (items.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          items.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: ProductService.productsNotifier,
              builder: (context, productList, child) {
                final allProducts = productList.map((p) {
                  return Product(
                    id: p['id'] ?? 'PROD-${p['name']}',
                    name: p['name'] ?? 'Produk',
                    description: p['description'] ?? '',
                    price: (p['price'] ?? 0).toDouble(),
                    imageUrl: p['image'] ?? '📦',
                    category: p['category'] ?? 'Lainnya',
                    stock: p['stock'] ?? 0,
                    rating: 4.5,
                    reviews: 0,
                  );
                }).toList();

                final shownProducts = selectedCategory == 'Semua'
                    ? allProducts
                    : allProducts.where((p) => p.category == selectedCategory).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: shownProducts.length,
                  itemBuilder: (context, index) {
                    final product = shownProducts[index];
                    return ProductCard(product: product);
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

// ==PRODUCT CARD==
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  void _shareProduct(BuildContext context) {
    final harga = NumberFormat('#,###', 'id_ID').format(product.price);
    final message = '🛍️ *${product.name}*\n'
        '${product.description}\n\n'
        '💰 Harga: Rp $harga\n'
        '📱 Pesan sekarang di aplikasi *Elok Mekar Sari*!';
    Share.share(message, subject: '${product.name} - Elok Mekar Sari');
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
                  child: Center(
                    child: () {
                      final img = product.imageUrl;
                      if (img is Uint8List && img.isNotEmpty) {
                        return Image.memory(
                          img,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: kGray),
                        );
                      } else if (img is String && img.startsWith('assets/')) {
                        return Image.asset(
                          img,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: kGray),
                        );
                      } else if (img is String && (img.contains('/') || img.contains('\\'))) {
                        final file = File(img);
                        if (file.existsSync()) {
                          return Image.file(
                            file,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: kGray),
                          );
                        }
                      } else if (img is String && (img.startsWith('http://') || img.startsWith('https://'))) {
                        return Image.network(
                          img,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: kGray),
                        );
                      }
                      // Fallback: jika bukan Uint8List dan bukan String, atau String tapi bukan path/gambar
                      return Text(
                        img?.toString() ?? '📦',
                        style: const TextStyle(fontSize: 40),
                      );
                    }(),
                  ),
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
                      child: const Icon(Icons.share,
                          color: Colors.white, size: 18),
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
            // Navigate to product detail
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(product: product),
                      ),
                    );
                  },
                  child: const Text(
                    'Beli',
                    style: TextStyle(fontSize: 12, color: Colors.white),
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
              decoration: BoxDecoration(
                color: kGreenPale,
              ),
              child: Center(
                child: () {
                  final img = widget.product.imageUrl;
                  if (img is Uint8List && img.isNotEmpty) {
                    return Image.memory(
                      img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: kGray),
                    );
                  } else if (img is String && img.startsWith('assets/')) {
                    return Image.asset(
                      img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: kGray),
                    );
                  } else if (img is String && (img.contains('/') || img.contains('\\'))) {
                    final file = File(img);
                    if (file.existsSync()) {
                      return Image.file(
                        file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: kGray),
                      );
                    }
                  } else if (img is String && (img.startsWith('http://') || img.startsWith('https://'))) {
                    return Image.network(
                      img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: kGray),
                    );
                  }
                  return Icon(Icons.image, size: 100, color: kGray);
                }(),
              ),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
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
                        CartManager().addToCart(widget.product, qty: quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${quantity}x ${widget.product.name} ditambahkan ke keranjang',
                            ),
                          ),
                        );
                        Navigator.pop(context);
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

  // ===== TEKS PESAN PRODUK =====
  String get _productMessage {
    final harga = NumberFormat('#,###', 'id_ID').format(widget.product.price);
    return '🛍️ *${widget.product.name}*\n'
        '${widget.product.description}\n\n'
        '💰 Harga: Rp $harga\n'
        '📦 Stok: ${widget.product.stock} unit\n\n'
        '📱 Pesan sekarang di aplikasi *Elok Mekar Sari*!';
  }

  // SHARE umum (native share sheet)
  void _shareProduct() {
    Share.share(_productMessage, subject: '${widget.product.name} - Elok Mekar Sari');
  }

  // SHARE ke WhatsApp — buka app WA langsung
  Future<void> _shareToWhatsApp() async {
    final text = Uri.encodeComponent(_productMessage);
    // Coba buka app WhatsApp dulu, fallback ke web
    final appUrl = Uri.parse('whatsapp://send?text=$text');
    final webUrl = Uri.parse('https://api.whatsapp.com/send?text=$text');
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  // SHARE ke Facebook Messenger — langsung ke chat FB Messenger
  Future<void> _shareToFacebook() async {
    // Copy pesan ke clipboard
    await Clipboard.setData(ClipboardData(text: _productMessage));

    // Deep link ke Facebook Messenger chat baru
    final messengerUrl = Uri.parse('fb-messenger://compose');
    // Fallback: buka Messenger via intent
    final messengerWeb = Uri.parse('https://m.me/');

    if (await canLaunchUrl(messengerUrl)) {
      await launchUrl(messengerUrl, mode: LaunchMode.externalApplication);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesan produk sudah disalin! Paste di chat Facebook Messenger 📋'),
            backgroundColor: kGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Fallback: coba buka app Facebook biasa
      final fbApp = Uri.parse('fb://');
      if (await canLaunchUrl(fbApp)) {
        await launchUrl(fbApp, mode: LaunchMode.externalApplication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesan produk sudah disalin! Paste di chat Facebook kamu 📋'),
              backgroundColor: kGreen,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        await launchUrl(messengerWeb, mode: LaunchMode.externalApplication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesan produk sudah disalin! Paste di chat kamu 📋'),
              backgroundColor: kGreen,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  // SHARE ke Instagram Direct Message — langsung ke halaman chat IG
  Future<void> _shareToInstagram() async {
    // Copy pesan ke clipboard dulu
    await Clipboard.setData(ClipboardData(text: _productMessage));

    // Deep link langsung ke Instagram Direct Message (inbox chat)
    final igDirect = Uri.parse('instagram://direct-inbox');
    final igApp    = Uri.parse('instagram://app');
    final igWeb    = Uri.parse('https://www.instagram.com/direct/inbox/');

    if (await canLaunchUrl(igDirect)) {
      await launchUrl(igDirect, mode: LaunchMode.externalApplication);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesan produk sudah disalin! Paste di chat Instagram kamu 📋'),
            backgroundColor: kGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else if (await canLaunchUrl(igApp)) {
      await launchUrl(igApp, mode: LaunchMode.externalApplication);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesan produk sudah disalin! Buka DM Instagram dan paste pesannya 📋'),
            backgroundColor: kGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      await launchUrl(igWeb, mode: LaunchMode.externalApplication);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesan produk sudah disalin! Paste di chat Instagram kamu 📋'),
            backgroundColor: kGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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

// ========== CART PAGE ==========
class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kGreen,
        elevation: 0,
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartManager().cartItems,
        builder: (context, items, child) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: kBorder),
                  const SizedBox(height: 16),
                  const Text(
                    'Keranjang Anda Kosong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai belanja produk favorit Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: kGray,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Lanjut Belanja',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CartItemWidget(item: item);
                  },
                ),
              ),
              // Summary and checkout
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: kBorder, width: 1)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal:',
                          style: TextStyle(fontSize: 14, color: kGray),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(CartManager().totalPrice)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ongkir:',
                          style: TextStyle(fontSize: 14, color: kGray),
                        ),
                        const Text(
                          'Rp 0',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      color: kBorder,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kDark,
                          ),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(CartManager().totalPrice)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CheckoutPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Lanjut ke Pembayaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ========== CART ITEM WIDGET ==========
class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buildProductImage(
                  item.product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(item.product.price)}',
                    style: TextStyle(
                      color: kGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity controls
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (item.quantity > 1) {
                            CartManager().updateQuantity(
                              item.product.id,
                              item.quantity - 1,
                            );
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(color: kBorder),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.remove, size: 14, color: kGreen),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (item.quantity < item.product.stock) {
                            CartManager().updateQuantity(
                              item.product.id,
                              item.quantity + 1,
                            );
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(color: kBorder),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.add, size: 14, color: kGreen),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Subtotal and delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(item.subtotal)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: kGreen,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    CartManager().removeFromCart(item.product.id);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ========== CHECKOUT PAGE ==========
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  
  String _selectedPaymentMethod = 'transfer_bank';
  
  final List<Map<String, String>> paymentMethods = [
    {'id': 'transfer_bank', 'name': 'Transfer Bank', 'icon': '🏦'},
    {'id': 'ewallet', 'name': 'E-wallet(Gopay, Ovo, Dana)', 'icon': '📱'},
    {'id': 'cod', 'name': 'Bayar di Tempat (COD)', 'icon': '💵'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartManager = CartManager();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== ORDER SUMMARY =====
                _buildSectionHeader('📦 Ringkasan Pesanan'),
                const SizedBox(height: 12),
                ValueListenableBuilder<List<CartItem>>(
                  valueListenable: cartManager.cartItems,
                  builder: (context, items, child) {
                    return Column(
                      children: items.map((item) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: kBg,
                            border: Border.all(color: kBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: kBorder.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: buildProductImage(
                                    item.product.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${NumberFormat('#,###', 'id_ID').format(item.product.price)} x ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: kGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(item.subtotal)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: kGreen,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ===== DELIVERY ADDRESS =====
                _buildSectionHeader('📍 Alamat Pengiriman'),
                const SizedBox(height: 12),
                
                // Nama
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan nama Anda',
                    prefixIcon: const Icon(Icons.person_outline, color: kGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kGreen, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Nomor HP
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    hintText: 'Contoh: 08123456789',
                    prefixIcon: const Icon(Icons.phone_outlined, color: kGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kGreen, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon tidak boleh kosong';
                    }
                    if (value.length < 10) {
                      return 'Nomor telepon minimal 10 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Alamat
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Alamat Lengkap',
                    hintText: 'Jl. Contoh No. 123, RT/RW 01/01',
                    prefixIcon: const Icon(Icons.location_on_outlined, color: kGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kGreen, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Kota
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Kota',
                    hintText: 'Contoh: Surabaya',
                    prefixIcon: const Icon(Icons.business_outlined, color: kGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kGreen, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kota tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Kode Pos
                TextFormField(
                  controller: _postalCodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Kode Pos',
                    hintText: 'Contoh: 60123',
                    prefixIcon: const Icon(Icons.markunread_mailbox_outlined, color: kGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kGreen, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode pos tidak boleh kosong';
                    }
                    if (value.length != 5) {
                      return 'Kode pos harus 5 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                //  ===== PAYMENT METHOD =====
                _buildSectionHeader('💳 Metode Pembayaran'),
                const SizedBox(height: 12),
                Column(
                  children: paymentMethods.map((method) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedPaymentMethod == method['id']
                              ? kGreen
                              : kBorder,
                          width: _selectedPaymentMethod == method['id'] ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: _selectedPaymentMethod == method['id'] 
                            ? kGreenPale
                            : Colors.white,
                      ),
                      child: RadioListTile<String>(
                        value: method['id']!,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        activeColor: kGreen,
                        title: Row(
                          children: [
                            Text(
                              method['icon']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                method['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ===== PRICE SUMMARY =====
                _buildSectionHeader('💰 Ringkasan Total'),
                const SizedBox(height: 12),
                ValueListenableBuilder<List<CartItem>>(
                  valueListenable: cartManager.cartItems,
                  builder: (context, items, child) {
                    final subtotal = cartManager.totalPrice;
                    const shippingCost = 0.0;
                    final total = subtotal + shippingCost;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorder),
                        borderRadius: BorderRadius.circular(10),
                        color: kBg,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal:',
                                style: TextStyle(color: kGray),
                              ),
                              Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(subtotal)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ongkir:',
                                style: TextStyle(color: kGray),
                              ),
                              Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(shippingCost)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            color: kBorder,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kDark,
                                ),
                              ),
                              Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ===== TERMS & CONDITIONS =====
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kGreenPale,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: kGreen, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pastikan semua data sudah benar sebelum melanjutkan pembayaran',
                          style: TextStyle(
                            fontSize: 12,
                            color: kGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ===== BUTTONS =====
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kGreen, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            color: kGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handlePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Lanjutkan Pembayaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kDark,
      ),
    );
  }

  void _handlePayment() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama: ${_nameController.text}'),
              const SizedBox(height: 8),
              Text('No. HP: ${_phoneController.text}'),
              const SizedBox(height: 8),
              Text('Alamat: ${_addressController.text}'),
              const SizedBox(height: 8),
              Text(
                'Total: Rp ${NumberFormat('#,###', 'id_ID').format(CartManager().totalPrice)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Metode: ${paymentMethods.firstWhere((m) => m['id'] == _selectedPaymentMethod)['name']}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batalkan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kDark,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmPayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
              ),
              child: const Text(
                'Konfirmasi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kDark,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ===== SIMPAN ORDER KE FIRESTORE =====
  Future<void> _confirmPayment() async {
    final cartManager = CartManager();
    final items = cartManager.cartItems.value;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: kGreen),
      ),
    );

    try {
      final docRef = FirebaseFirestore.instance.collection('orders').doc();
      final orderId = docRef.id;
      final now = Timestamp.now();

      final orderItems = items.map((item) => {
        'productId': item.product.id,
        'productName': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
        'subtotal': item.subtotal,
      }).toList();

      final paymentName = paymentMethods
          .firstWhere((m) => m['id'] == _selectedPaymentMethod)['name'];

      await docRef.set({
        'orderId': orderId,
        'userId': user.uid,
        'recipientName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': '${_addressController.text.trim()}, ${_cityController.text.trim()}, ${_postalCodeController.text.trim()}',
        'items': orderItems,
        'totalPrice': cartManager.totalPrice,
        'paymentMethod': paymentName,
        'status': 'pending',
        'statusLabel': 'Menunggu Pembayaran',
        'statusHistory': [
          {
            'status': 'pending',
            'label': 'Pesanan Dibuat',
            'timestamp': now,
          }
        ],
        'createdAt': now,
        'updatedAt': now,
      });

      if (mounted) Navigator.pop(context); // tutup loading

      cartManager.clearCart();

      // Navigate ke halaman konfirmasi pembayaran sesuai metode
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentConfirmationPage(
              orderId: orderId,
              paymentMethod: _selectedPaymentMethod,
              totalPrice: cartManager.totalPrice == 0
                  ? orderItems.fold(0.0, (sum, i) => sum + (i['subtotal'] as double))
                  : cartManager.totalPrice,
              recipientName: _nameController.text.trim(),
              address: '${_addressController.text.trim()}, ${_cityController.text.trim()}, ${_postalCodeController.text.trim()}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ========== PAYMENT CONFIRMATION PAGE ==========
class PaymentConfirmationPage extends StatefulWidget {
  final String orderId;
  final String paymentMethod; // 'transfer_bank', 'ewallet', 'cod'
  final double totalPrice;
  final String recipientName;
  final String address;

  const PaymentConfirmationPage({
    Key? key,
    required this.orderId,
    required this.paymentMethod,
    required this.totalPrice,
    required this.recipientName,
    required this.address,
  }) : super(key: key);

  @override
  State<PaymentConfirmationPage> createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  bool _isConfirming = false;
  Uint8List? _strukBytes;
  String?   _strukFileName;

  String get _displayOrderId {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    return 'EMS-$date-${widget.orderId.substring(0, 4).toUpperCase()}';
  }

  String get _formattedTotal =>
      "Rp ${NumberFormat('#,###', 'id_ID').format(widget.totalPrice)}";

  // ===== PILIH GAMBAR STRUK =====
  Future<void> _pickStruk() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _strukBytes    = bytes;
      _strukFileName = picked.name;
    });
  }

  // ===== UPLOAD STRUK (base64 ke Firestore) & konfirmasi =====
  Future<void> _konfirmasiSudahBayar() async {
    if (_strukBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap upload foto struk pembayaran terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _isConfirming = true);
    try {
      final base64Struk = base64Encode(_strukBytes!);
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'status': 'diproses',
        'statusLabel': 'Sedang Diproses',
        'strukBase64': base64Struk,
        'strukFileName': _strukFileName ?? 'struk.jpg',
        'strukUploadedAt': Timestamp.now(),
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': 'diproses',
            'label': 'Pembayaran Dikonfirmasi + Struk Diunggah',
            'timestamp': Timestamp.now(),
          }
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() => _isConfirming = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Pembayaran Terkonfirmasi'),
            content: const Text(
              'Struk pembayaran berhasil dikirim. '
              'Pesanan Anda sedang kami proses dan akan segera dikirim.',
              style: TextStyle(height: 1.6),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Tutup dialog lalu kembali ke root dan set tab ke ORDERS (index 2)
                  Navigator.pop(context);
                  // Kembali ke MainPage dan langsung set tab ke ORDERS (index 2)
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                    arguments: {'tab': 2},
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: kGreen),
                child: const Text('Lihat Pesanan Saya',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal konfirmasi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ===== COD: langsung proses tanpa upload =====
  Future<void> _konfirmasiCOD() async {
    setState(() => _isConfirming = true);
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'status': 'diproses',
        'statusLabel': 'Sedang Diproses',
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': 'diproses',
            'label': 'Pesanan Diproses (COD - Bayar di Tempat)',
            'timestamp': Timestamp.now(),
          }
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() => _isConfirming = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Pesanan Dikonfirmasi'),
            content: Text(
              'Pesanan Anda akan segera diantarkan ke:\n'
              '${widget.address}\n\n'
              'Siapkan uang tunai $_formattedTotal saat kurir tiba.',
              style: const TextStyle(height: 1.6),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Tutup dialog lalu kembali ke root dan set tab ke ORDERS (index 2)
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                    arguments: {'tab': 2},
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: kGreen),
                child: const Text('Lihat Pesanan Saya',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ===== WIDGET UPLOAD STRUK =====
  Widget _buildUploadStruk() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload Struk / Bukti Pembayaran',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kDark)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickStruk,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 140),
            decoration: BoxDecoration(
              color: _strukBytes != null ? Colors.transparent : kGreenPale,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _strukBytes != null ? kGreen : kBorder,
                width: _strukBytes != null ? 2 : 1,
              ),
            ),
            child: _strukBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      children: [
                        Image.memory(_strukBytes!, fit: BoxFit.cover,
                            width: double.infinity),
                        Positioned(
                          top: 8, right: 8,
                          child: GestureDetector(
                            onTap: _pickStruk,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: kGreen,
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Text('Ganti',
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 28),
                      Icon(Icons.cloud_upload_outlined, size: 44, color: kGreen),
                      SizedBox(height: 8),
                      Text('Ketuk untuk pilih foto struk',
                          style: TextStyle(color: kGreen, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Format: JPG, PNG',
                          style: TextStyle(color: kGray, fontSize: 12)),
                      SizedBox(height: 28),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Konfirmasi Pembayaran',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header order
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kGreenPale,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGreen.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.receipt_long, color: kGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(_displayOrderId,
                      style: const TextStyle(fontWeight: FontWeight.bold,
                          color: kGreen, fontSize: 15)),
                ]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total Pembayaran',
                      style: TextStyle(color: kGray, fontSize: 13)),
                  Text(_formattedTotal,
                      style: const TextStyle(fontWeight: FontWeight.bold,
                          color: kDark, fontSize: 18)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            // ===== TRANSFER BANK =====
            if (widget.paymentMethod == 'transfer_bank') ...[
              _buildSectionTitle('Transfer Bank'),
              const SizedBox(height: 12),
              _buildBankCard(bankName: 'BCA', accountNumber: '1234567890',
                  accountName: 'Elok Mekar Sari', logo: Icons.account_balance),
              const SizedBox(height: 10),
              _buildBankCard(bankName: 'BRI', accountNumber: '0987654321',
                  accountName: 'Elok Mekar Sari', logo: Icons.account_balance),
              const SizedBox(height: 10),
              _buildBankCard(bankName: 'Mandiri', accountNumber: '1122334455',
                  accountName: 'Elok Mekar Sari', logo: Icons.account_balance),
              const SizedBox(height: 16),
              _buildInfoBox(icon: Icons.info_outline, color: Colors.orange,
                  text: 'Transfer tepat sebesar $_formattedTotal. '
                      'Lalu upload foto struk/bukti transfer di bawah.'),
              const SizedBox(height: 20),
              _buildUploadStruk(),
              const SizedBox(height: 20),
              _buildConfirmButton(),
            ],

            // ===== E-WALLET =====
            if (widget.paymentMethod == 'ewallet') ...[
              _buildSectionTitle('Pembayaran E-Wallet'),
              const SizedBox(height: 12),
              _buildEwalletCard(name: 'GoPay', number: '0895-3013-2581',
                  owner: 'Elok Mekar Sari', color: const Color(0xFF00AED6)),
              const SizedBox(height: 10),
              _buildEwalletCard(name: 'OVO', number: '0895-3013-2581',
                  owner: 'Elok Mekar Sari', color: const Color(0xFF4C3494)),
              const SizedBox(height: 10),
              _buildEwalletCard(name: 'DANA', number: '0895-3013-2581',
                  owner: 'Elok Mekar Sari', color: const Color(0xFF118EEA)),
              const SizedBox(height: 16),
              _buildInfoBox(icon: Icons.info_outline, color: Colors.blue,
                  text: 'Transfer tepat sebesar $_formattedTotal ke salah satu e-wallet. '
                      'Lalu upload screenshot bukti transfer di bawah.'),
              const SizedBox(height: 20),
              _buildUploadStruk(),
              const SizedBox(height: 20),
              _buildConfirmButton(),
            ],

            // ===== COD =====
            if (widget.paymentMethod == 'cod') ...[
              _buildSectionTitle('Bayar di Tempat (COD)'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.local_shipping, color: kGreen, size: 22),
                    SizedBox(width: 8),
                    Text('Detail Pengiriman',
                        style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 14, color: kDark)),
                  ]),
                  const SizedBox(height: 12),
                  _buildDetailRow('Penerima', widget.recipientName),
                  const SizedBox(height: 8),
                  _buildDetailRow('Alamat Tujuan', widget.address),
                  const SizedBox(height: 8),
                  _buildDetailRow('Jumlah Tunai', _formattedTotal),
                ]),
              ),
              const SizedBox(height: 16),
              _buildInfoBox(icon: Icons.check_circle_outline, color: kGreen,
                  text: 'Siapkan uang tunai sebesar $_formattedTotal saat kurir tiba '
                      'di alamat tujuan Anda. Pesanan akan langsung diproses.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isConfirming ? null : _konfirmasiCOD,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isConfirming
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check, color: Colors.white),
                  label: const Text('OK, Pesanan Dikonfirmasi',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kGreen),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.receipt_long_outlined, color: kGreen),
                label: const Text('Lihat Riwayat Pesanan',
                    style: TextStyle(color: kGreen, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kDark));

  Widget _buildBankCard({required String bankName, required String accountNumber,
      required String accountName, required IconData logo}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: Row(children: [
        Container(width: 44, height: 44,
            decoration: BoxDecoration(color: kGreenPale,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(logo, color: kGreen, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(bankName, style: const TextStyle(fontWeight: FontWeight.bold,
              fontSize: 14, color: kDark)),
          Text(accountNumber, style: const TextStyle(fontSize: 16,
              fontWeight: FontWeight.w700, letterSpacing: 1, color: kGreen)),
          Text('a/n $accountName',
              style: const TextStyle(fontSize: 12, color: kGray)),
        ])),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Nomor rekening $bankName disalin'),
              backgroundColor: kGreen, duration: const Duration(seconds: 1))),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: kGreenPale,
                borderRadius: BorderRadius.circular(8)),
            child: const Text('Salin', style: TextStyle(color: kGreen,
                fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildEwalletCard({required String name, required String number,
      required String owner, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: Row(children: [
        Container(width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(name[0], style: TextStyle(color: color,
                fontWeight: FontWeight.bold, fontSize: 20)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold,
              fontSize: 14, color: kDark)),
          Text(number, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
              letterSpacing: 1, color: color)),
          Text('a/n $owner', style: const TextStyle(fontSize: 12, color: kGray)),
        ])),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Nomor $name disalin'),
              backgroundColor: kGreen, duration: const Duration(seconds: 1))),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text('Salin', style: TextStyle(color: color, fontSize: 12,
                fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildInfoBox({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text,
            style: TextStyle(fontSize: 13, color: color, height: 1.5))),
      ]),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110,
          child: Text(label, style: const TextStyle(fontSize: 13, color: kGray))),
      const Text(': ', style: TextStyle(fontSize: 13, color: kGray)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13,
          color: kDark, fontWeight: FontWeight.w600))),
    ]);
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isConfirming ? null : _konfirmasiSudahBayar,
        style: ElevatedButton.styleFrom(
          backgroundColor: kGreen,
          disabledBackgroundColor: kGreen.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: _isConfirming
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.check_circle, color: Colors.white),
        label: const Text('Konfirmasi Sudah Bayar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
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

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':       return 'Menunggu Pembayaran';
      case 'diproses':      return 'Sedang Diproses';
      case 'dikirim':       return 'Dalam Pengiriman';
      case 'selesai':       return 'Selesai';
      case 'dibatalkan':    return 'Dibatalkan';
      default:              return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':       return Colors.orange;
      case 'diproses':      return Colors.blue;
      case 'dikirim':       return Colors.purple;
      case 'selesai':       return kGreen;
      case 'dibatalkan':    return Colors.red;
      default:              return kGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lacak Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white, size: 26),
            tooltip: 'Chat dengan Asisten',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const chatbot.ChatbotPage()));
            },
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Silakan login terlebih dahulu'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kGreen));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = List.from(snapshot.data?.docs ?? [])
                  ..sort((a, b) {
                    final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
                    final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
                    if (aTs == null || bTs == null) return 0;
                    return bTs.compareTo(aTs);
                  });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: kBorder),
                        const SizedBox(height: 16),
                        const Text('Belum Ada Pesanan',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDark)),
                        const SizedBox(height: 8),
                        Text('Pesanan Anda akan muncul di sini',
                            style: TextStyle(fontSize: 14, color: kGray)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'pending';
                    final items = (data['items'] as List<dynamic>?) ?? [];
                    final productNames = items
                        .map((e) => "${e['productName']} x${e['quantity']}")
                        .join(', ');
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    final dateStr = createdAt != null
                        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(createdAt)
                        : '-';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => FirebaseOrderDetailPage(orderData: data),
                        ));
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "ID: ${(data['orderId'] as String).substring(0, 12).toUpperCase()}",
                                    style: const TextStyle(fontSize: 12, color: kGray, fontWeight: FontWeight.w500),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _statusLabel(status),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusColor(status)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                productNames.isEmpty ? 'Produk tidak tersedia' : productNames,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kDark),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(dateStr, style: const TextStyle(fontSize: 12, color: kGray)),
                                  Text(
                                    "Rp ${NumberFormat('#,###', 'id_ID').format(data['totalPrice'] ?? 0)}",
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGreen),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// ===== DETAIL PESANAN DARI FIREBASE (Realtime StreamBuilder) =====
class FirebaseOrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> orderData;
  const FirebaseOrderDetailPage({Key? key, required this.orderData}) : super(key: key);

  @override
  State<FirebaseOrderDetailPage> createState() => _FirebaseOrderDetailPageState();
}

class _FirebaseOrderDetailPageState extends State<FirebaseOrderDetailPage> {
  bool _isConfirming = false;

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':    return 'Menunggu Pembayaran';
      case 'diproses':   return 'Sedang Diproses';
      case 'dikirim':    return 'Dalam Pengiriman';
      case 'selesai':    return 'Selesai';
      case 'dibatalkan': return 'Dibatalkan';
      default:           return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':    return Colors.orange;
      case 'diproses':   return Colors.blue;
      case 'dikirim':    return Colors.purple;
      case 'selesai':    return kGreen;
      case 'dibatalkan': return Colors.red;
      default:           return kGray;
    }
  }

  String _formattedTotal(double total) =>
      "Rp ${NumberFormat('#,###', 'id_ID').format(total)}";

  Future<void> _konfirmasiSudahBayar(String orderId, double total) async {
    setState(() => _isConfirming = true);
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'diproses',
        'statusLabel': 'Sedang Diproses',
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': 'diproses',
            'label': 'Pembayaran Dikonfirmasi',
            'timestamp': Timestamp.now(),
          }
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran dikonfirmasi! Pesanan sedang diproses.'),
            backgroundColor: kGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil orderId dari data awal untuk stream
    final rawOrderId = widget.orderData['orderId'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kGreen,
        elevation: 0,
      ),
      // StreamBuilder agar status update realtime tanpa reload
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(rawOrderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kGreen));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Pesanan tidak ditemukan'));
          }

          // Gunakan data realtime dari Firestore
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final items = (data['items'] as List<dynamic>?) ?? [];
          final statusHistory = (data['statusHistory'] as List<dynamic>?) ?? [];
          final status = data['status'] ?? 'pending';
          final paymentMethod = data['paymentMethod'] ?? '';
          final totalPrice = (data['totalPrice'] ?? 0).toDouble();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final dateStr = createdAt != null
              ? DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(createdAt)
              : '-';
          final orderId = data['orderId'] as String? ?? rawOrderId;
          final displayId = orderId.length >= 12
              ? orderId.substring(0, 12).toUpperCase()
              : orderId.toUpperCase();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ===== STATUS BANNER =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor(status).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: $displayId',
                    style: const TextStyle(fontSize: 12, color: kGray),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _statusLabel(status),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _statusColor(status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(fontSize: 12, color: kGray)),
                  const SizedBox(height: 4),
                  Text(
                    'Metode: $paymentMethod',
                    style: const TextStyle(fontSize: 12, color: kGray),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== KONFIRMASI PEMBAYARAN (hanya muncul jika status masih pending) =====
            if (status == 'pending') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Menunggu Konfirmasi Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Pesan berbeda per metode pembayaran
                    if (paymentMethod.toLowerCase().contains('transfer') ||
                        paymentMethod.toLowerCase().contains('bank'))
                      Text(
                        'Silakan transfer ${_formattedTotal(totalPrice)} ke rekening Elok Mekar Sari. '
                        'Setelah transfer, klik tombol konfirmasi di bawah.',
                        style: const TextStyle(fontSize: 12, color: kGray, height: 1.5),
                      )
                    else if (paymentMethod.toLowerCase().contains('wallet') ||
                        paymentMethod.toLowerCase().contains('gopay') ||
                        paymentMethod.toLowerCase().contains('ovo') ||
                        paymentMethod.toLowerCase().contains('dana'))
                      Text(
                        'Silakan transfer ${_formattedTotal(totalPrice)} ke e-wallet Elok Mekar Sari. '
                        'Setelah transfer, klik tombol konfirmasi di bawah.',
                        style: const TextStyle(fontSize: 12, color: kGray, height: 1.5),
                      )
                    else
                      Text(
                        'Pesanan COD Anda akan segera diantarkan. '
                        'Siapkan uang tunai ${_formattedTotal(totalPrice)} saat kurir tiba.',
                        style: const TextStyle(fontSize: 12, color: kGray, height: 1.5),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isConfirming ? null : () => _konfirmasiSudahBayar(orderId, totalPrice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          disabledBackgroundColor: kGreen.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: _isConfirming
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.check_circle, color: Colors.white, size: 18),
                        label: Text(
                          paymentMethod.toLowerCase().contains('cod')
                              ? 'Konfirmasi Pesanan COD'
                              : 'Konfirmasi Sudah Bayar',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ===== PRODUK YANG DIPESAN =====
            const Text('Produk yang Dipesan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kDark)),
            const SizedBox(height: 8),
            ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['productName'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(item['price'] ?? 0)} x ${item['quantity']}',
                          style: const TextStyle(fontSize: 12, color: kGray),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(item['subtotal'] ?? 0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: kGreen, fontSize: 13),
                  ),
                ],
              ),
            )).toList(),
            const SizedBox(height: 8),

            // ===== TOTAL =====
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    _formattedTotal(totalPrice),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== ALAMAT PENGIRIMAN =====
            const Text('Alamat Pengiriman',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15, color: kDark)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['recipientName'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(data['phone'] ?? '-',
                      style: const TextStyle(color: kGray, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(data['address'] ?? '-',
                      style: const TextStyle(color: kGray, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== RIWAYAT STATUS =====
            if (statusHistory.isNotEmpty) ...[
              const Text('Riwayat Status',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15, color: kDark)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: statusHistory.reversed.map<Widget>((h) {
                    final ts = (h['timestamp'] as Timestamp?)?.toDate();
                    final tsStr = ts != null
                        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(ts)
                        : '-';
                    final hStatus = h['status'] ?? 'pending';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _statusColor(hStatus).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: _statusColor(hStatus),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h['label'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                Text(tsStr,
                                    style: const TextStyle(
                                        fontSize: 11, color: kGray)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
                const SizedBox(height: 24),
              ],
            ),
          );
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
                      color:
                          _getStatusColor(order.status).withValues(alpha: 0.1),
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
                        DateFormat('dd MMM yyyy', 'id_ID')
                            .format(order.orderDate),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                            color: _getStatusColor(order.status)
                                .withValues(alpha: 0.1),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                      DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                          .format(order.orderDate),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ComplaintPage(
                            currentUserId: 'user_id',
                            currentUserName: 'user_name',
                            currentUserEmail: 'user_email',
                          ),
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
      {
        'label': 'Diproses',
        'status': order.status.index >= OrderStatus.processing.index
      },
      {
        'label': 'Dikirim',
        'status': order.status.index >= OrderStatus.shipped.index
      },
      {
        'label': 'Dalam Pengiriman',
        'status': order.status.index >= OrderStatus.outForDelivery.index
      },
      {
        'label': 'Tiba',
        'status': order.status.index >= OrderStatus.delivered.index
      },
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
                      color:
                          isCompleted ? kGreen : kBorder.withValues(alpha: 0.3),
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
                      color:
                          isCompleted ? kGreen : kBorder.withValues(alpha: 0.3),
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