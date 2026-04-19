import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ==================== WARNA CONSTANTS ====================
const kGreen = Color(0xFF2D5A27);
const kGreenLight = Color(0xFF4A8C3F);
const kGreenPale = Color(0xFFEAF2E6);
const kCream = Color(0xFFF5F0E8);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

// ==================== DATA MODELS ====================
class ChatMessage {
  final String id;
  final String message;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isBot,
    required this.timestamp,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final int stock;
  final double rating;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.rating,
    required this.description,
  });
}

class Order {
  final String id;
  final String productName;
  final String status;
  final DateTime orderDate;

  Order({
    required this.id,
    required this.productName,
    required this.status,
    required this.orderDate,
  });
}

// ==================== CHATBOT ENGINE ====================
class ChatbotEngine {
  final List<Product> products = [
    Product(
      id: 'PROD-001',
      name: 'Kerajinan Tangan Tradisional',
      price: 150000,
      category: 'Kerajinan',
      stock: 25,
      rating: 4.8,
      description: 'Kerajinan tangan berkualitas tinggi dari bahan pilihan',
    ),
    Product(
      id: 'PROD-002',
      name: 'Tekstil Batik Premium',
      price: 250000,
      category: 'Tekstil',
      stock: 15,
      rating: 4.9,
      description: 'Batik asli dengan motif tradisional yang elegan',
    ),
    Product(
      id: 'PROD-003',
      name: 'Sepatu Kulit Handmade',
      price: 350000,
      category: 'Sepatu',
      stock: 8,
      rating: 4.7,
      description: 'Sepatu kulit buatan tangan dengan kualitas premium',
    ),
    Product(
      id: 'PROD-004',
      name: 'Tas Tangan Eksklusif',
      price: 280000,
      category: 'Tas',
      stock: 12,
      rating: 4.6,
      description: 'Tas tangan dengan desain eksklusif dan bahan berkualitas',
    ),
  ];

  final List<Order> sampleOrders = [
    Order(
      id: 'ORD-001',
      productName: 'Kerajinan Tangan Tradisional',
      status: 'Diproses',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Order(
      id: 'ORD-002',
      productName: 'Batik Premium',
      status: 'Dikirim',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // Intent Recognition Keywords
  final Map<String, List<String>> intentKeywords = {
    'greeting': ['halo', 'hi', 'pagi', 'sore', 'malam', 'assalam', 'hai'],
    'product_info': [
      'produk apa',
      'ada apa',
      'katalog',
      'barang',
      'apa saja',
      'koleksi',
      'stok'
    ],
    'price': ['harga', 'berapa', 'biaya', 'mahal', 'murah'],
    'order_status': [
      'pesanan',
      'order',
      'sudah sampai',
      'dimana pesanan',
      'status',
      'tracking'
    ],
    'payment': ['bayar', 'pembayaran', 'metode', 'cicilan'],
    'shipping': ['pengiriman', 'gratis ongkir', 'ongkos kirim', 'dikirim'],
    'complaint': ['komplain', 'keluhan', 'masalah', 'rusak', 'hilang'],
    'return': ['kembalikan', 'retur', 'ganti', 'refund'],
    'help': ['bantuan', 'help', 'bisa apa', 'fitur', 'cara'],
  };

  String getResponse(String userMessage) {
    final message = userMessage.toLowerCase().trim();

    // Greeting Intent
    if (_matchIntent(message, 'greeting')) {
      return _getGreetingResponse();
    }

    // Product Info Intent
    if (_matchIntent(message, 'product_info')) {
      return _getProductListResponse();
    }

    // Price Query Intent
    if (_matchIntent(message, 'price')) {
      return _getPriceResponse(message);
    }

    // Order Status Intent
    if (_matchIntent(message, 'order_status')) {
      return _getOrderStatusResponse();
    }

    // Payment Intent
    if (_matchIntent(message, 'payment')) {
      return _getPaymentResponse();
    }

    // Shipping Intent
    if (_matchIntent(message, 'shipping')) {
      return _getShippingResponse();
    }

    // Complaint Intent
    if (_matchIntent(message, 'complaint')) {
      return _getComplaintResponse();
    }

    // Return Intent
    if (_matchIntent(message, 'return')) {
      return _getReturnResponse();
    }

    // Help Intent
    if (_matchIntent(message, 'help')) {
      return _getHelpResponse();
    }

    // Search Product by Name
    if (message.contains('cari') || message.contains('produk')) {
      return _searchProduct(message);
    }

    // Default Response
    return _getDefaultResponse();
  }

  bool _matchIntent(String message, String intent) {
    final keywords = intentKeywords[intent] ?? [];
    return keywords.any((keyword) => message.contains(keyword));
  }

  String _getGreetingResponse() {
    final hour = DateTime.now().hour;
    String greeting = '';

    if (hour < 12) {
      greeting = 'Selamat Pagi! 🌅';
    } else if (hour < 17) {
      greeting = 'Selamat Siang! ☀️';
    } else if (hour < 19) {
      greeting = 'Selamat Sore! 🌆';
    } else {
      greeting = 'Selamat Malam! 🌙';
    }

    return '$greeting\n\nSaya adalah Asisten Bot Elok Mekar Sari. Bagaimana saya bisa membantu Anda hari ini? 😊\n\nAnda bisa:\n✓ Tanya tentang produk\n✓ Cek status pesanan\n✓ Tanya tentang pengiriman\n✓ Lapor keluhan';
  }

  String _getProductListResponse() {
    String response = '📦 Kami memiliki ${products.length} kategori produk unggulan:\n\n';

    final categories = products.map((p) => p.category).toSet().toList();
    for (var i = 0; i < categories.length; i++) {
      response +=
          '${i + 1}. ${categories[i]} - ${products.where((p) => p.category == categories[i]).length} produk\n';
    }

    response +=
        '\n💡 Tip: Ketik "cari [nama produk]" untuk mencari produk tertentu atau tanya harganya!';
    return response;
  }

  String _getProductListDetailed() {
    String response = '📋 Daftar Produk Kami:\n\n';

    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      response +=
          '${i + 1}. ${product.name}\n   💰 Rp ${product.price.toStringAsFixed(0)}\n   ⭐ ${product.rating}/5.0 | Stok: ${product.stock}\n\n';
    }

    return response;
  }

  String _getPriceResponse(String message) {
    String response =
        '💰 Berikut daftar harga produk kami:\n\n';

    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      response +=
          '${i + 1}. ${product.name}\n   Rp ${product.price.toStringAsFixed(0)}\n';
    }

    response +=
        '\n\n💡 Harga sudah termasuk kemasan berkualitas. Gratis ongkos kirim untuk pembelian di atas Rp 500.000!';
    return response;
  }

  String _searchProduct(String message) {
    // Extract product name from message
    String searchTerm = message.replaceAll(RegExp(r'cari|produk'), '').trim();

    if (searchTerm.isEmpty) {
      return _getProductListDetailed();
    }

    final results = products
        .where((p) => p.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
            p.category.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return 'Maaf, produk "$searchTerm" tidak ditemukan. 😔\n\nKami memiliki produk di kategori:\n' +
          products.map((p) => '• ${p.category}').toSet().join('\n') +
          '\n\nCoba cari lagi dengan kata kunci yang berbeda!';
    }

    String response = '🔍 Hasil pencarian untuk "$searchTerm":\n\n';
    for (int i = 0; i < results.length; i++) {
      final product = results[i];
      response +=
          '${i + 1}. ${product.name}\n   💰 Rp ${product.price.toStringAsFixed(0)}\n   📝 ${product.description}\n   ⭐ Rating: ${product.rating}/5.0\n   📦 Stok: ${product.stock} tersedia\n\n';
    }

    return response;
  }

  String _getOrderStatusResponse() {
    if (sampleOrders.isEmpty) {
      return '📭 Anda belum memiliki pesanan apapun.\n\nMulai belanja sekarang dan nikmati produk berkualitas dari UMKM kami! 🛍️';
    }

    String response = '📦 Status Pesanan Anda:\n\n';

    for (int i = 0; i < sampleOrders.length; i++) {
      final order = sampleOrders[i];
      final statusEmoji = order.status == 'Dikirim'
          ? '🚚'
          : order.status == 'Tiba'
              ? '✅'
              : order.status == 'Diproses'
                  ? '⏳'
                  : '📌';

      response +=
          '${i + 1}. ${order.productName}\n   $statusEmoji Status: ${order.status}\n   📅 Dipesan: ${DateFormat('dd MMM yyyy', 'id_ID').format(order.orderDate)}\n   ID: ${order.id}\n\n';
    }

    response += '💡 Untuk detail lebih lanjut, buka halaman "Pesanan Saya"';
    return response;
  }

  String _getPaymentResponse() {
    return '💳 Metode Pembayaran yang Kami Terima:\n\n'
        '✓ Transfer Bank (BCA, Mandiri, BNI)\n'
        '✓ E-Wallet (GoPay, OVO, Dana)\n'
        '✓ Cicilan 0% (tersedia untuk pembelian ≥ Rp 1.000.000)\n'
        '✓ COD (Cod hanya untuk area Surabaya)\n\n'
        '🔒 Semua transaksi aman dan terenkripsi.\n\n'
        '❓ Untuk cicilan, hubungi admin melalui fitur chat atau WhatsApp.';
  }

  String _getShippingResponse() {
    return '🚚 Informasi Pengiriman:\n\n'
        '📍 Jangkauan: Seluruh Indonesia\n'
        '⏱️ Estimasi: 2-5 hari kerja\n'
        '💯 Gratis Ongkos Kirim untuk pembelian ≥ Rp 500.000\n\n'
        'Biaya Pengiriman:\n'
        '• Jawa: Rp 25.000 - Rp 50.000\n'
        '• Luar Jawa: Rp 50.000 - Rp 150.000\n\n'
        '📦 Produk dikemas dengan aman dan profesional\n'
        '🛡️ Asuransi pengiriman gratis untuk semua paket';
  }

  String _getComplaintResponse() {
    return '😕 Kami minta maaf jika ada yang tidak memuaskan!\n\n'
        'Silakan:\n'
        '1️⃣ Klik menu "Keluhan & Feedback"\n'
        '2️⃣ Pilih kategori keluhan Anda\n'
        '3️⃣ Jelaskan masalah dengan detail\n'
        '4️⃣ Unggah bukti foto jika perlu\n\n'
        '✅ Tim admin kami akan merespons dalam 24 jam!\n\n'
        'Atau hubungi langsung:\n'
        '📱 WhatsApp: 081234567890\n'
        '📧 Email: support@elokmekar.com';
  }

  String _getReturnResponse() {
    return '🔄 Kebijakan Pengembalian & Penukaran:\n\n'
        '✓ Batas waktu retur: 7 hari setelah barang diterima\n'
        '✓ Syarat: Barang dalam kondisi asli dan packaging utuh\n\n'
        'Alasan Retur yang Diterima:\n'
        '• Barang cacat/rusak saat sampai\n'
        '• Barang tidak sesuai pesanan\n'
        '• Barang hilang/salah kirim\n\n'
        '💰 Pengembalian Dana:\n'
        '• Retur diterima: Uang kembali 100% + gratis ongkos kirim balik\n'
        '• Proses: 3-5 hari kerja setelah verifikasi\n\n'
        '⚠️ Hubungi admin untuk proses lebih detail!';
  }

  String _getHelpResponse() {
    return '🤖 Berikut perintah yang bisa saya lakukan:\n\n'
        '📦 Produk:\n'
        '  • "apa saja produk" - Lihat daftar produk\n'
        '  • "cari [nama]" - Cari produk\n'
        '  • "harga" - Lihat harga\n\n'
        '🛒 Pesanan:\n'
        '  • "status pesanan" - Cek status pesanan\n'
        '  • "pesanan saya" - Lihat riwayat pesanan\n\n'
        '💳 Pembayaran & Pengiriman:\n'
        '  • "metode pembayaran" - Lihat cara bayar\n'
        '  • "pengiriman" - Info ongkos kirim\n\n'
        '⚠️ Dukungan:\n'
        '  • "komplain" - Laporkan keluhan\n'
        '  • "retur" - Info pengembalian barang\n\n'
        '💡 Atau ketik pertanyaan Anda secara langsung!';
  }

  String _getDefaultResponse() {
    return 'Maaf, saya kurang memahami pertanyaan Anda. 🤔\n\n'
        'Bisa diulang dengan cara lain? Atau ketik "bantuan" untuk melihat perintah yang tersedia!\n\n'
        'Contoh:\n'
        '• "Produk apa saja?"\n'
        '• "Berapa harga batik?"\n'
        '• "Status pesanan saya"\n'
        '• "Bagaimana cara retur?"';
  }
}

// ==================== CHATBOT PAGE ====================
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatbotEngine _chatbotEngine = ChatbotEngine();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(_chatbotEngine.getResponse('halo'));
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    // Add user message
    _addUserMessage(message);
    _messageController.clear();

    // Simulate bot typing
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      final response = _chatbotEngine.getResponse(message);
      _addBotMessage(response);
      setState(() => _isLoading = false);
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        message: message,
        isBot: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        message: message,
        isBot: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Chatbot Asisten'),
        backgroundColor: kGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return _buildTypingIndicator();
                }

                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: kBorder),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pertanyaan Anda...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: kGreen, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () {},
                      ),
                    ),
                    onSubmitted: (message) => _sendMessage(message),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: kGreen,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () =>
                        _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isBot = message.isBot;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: kGreenPale,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: kGreen, size: 18),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isBot
                    ? Colors.white
                    : kGreen,
                borderRadius: BorderRadius.circular(16),
                border: isBot ? Border.all(color: kBorder) : null,
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: isBot ? kDark : Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          if (!isBot) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kGreenPale,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: kGreen, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: kGreen,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ==================== FLOATING CHAT BUTTON ====================
class FloatingChatButton extends StatelessWidget {
  const FloatingChatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatbotPage()),
        );
      },
      backgroundColor: kGreen,
      child: const Icon(Icons.chat_bubble),
    );
  }
}

// ==================== QUICK REPLY BUTTONS ====================
class QuickReplyButtons extends StatelessWidget {
  final Function(String) onReplyPressed;

  const QuickReplyButtons({
    Key? key,
    required this.onReplyPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final replies = [
      'Produk apa saja?',
      'Berapa harganya?',
      'Status pesanan',
      'Cara pembayaran',
      'Pengiriman',
      'Bantuan'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: replies.map((reply) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onReplyPressed(reply),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGreen),
                ),
                child: Text(
                  reply,
                  style: const TextStyle(
                    color: kGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
