import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'Marketplace_Dan_Order Tracking.dart';
import 'Sistem Keluhan_Feedback.dart' as feedback;
import 'profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(UMKMApp());
}

class UMKMApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMKM Elok Mekar Sari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2D5A27),
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFFFAFAF7),
      ),
      home: SafeArea(child: MainPage()),
    );
  }
}

// =================== WARNA ===================
const kGreen = Color(0xFF2D5A27);
const kGreenLight = Color(0xFF4A8C3F);
const kGreenPale = Color(0xFFEAF2E6);
const kCream = Color(0xFFF5F0E8);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

// =================== MAIN PAGE ===================
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  
  late List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      MarketplacePage(),
      OrderTrackingPage(),
      const feedback.ComplaintPage(
        currentUserId: 'USR-001',
        currentUserName: 'Pelanggan',
        currentUserEmail: 'pelanggan@umkm.com',
      ),
      ProfilePage(onProfileUpdate: _refreshProfile),
    ];
  }
  
  void _refreshProfile() {
    setState(() {
      _pages[4] = ProfilePage(onProfileUpdate: _refreshProfile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: kGreen,
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "HOME"),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: "MARKET"),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: "ORDERS"),
            BottomNavigationBarItem(icon: Icon(Icons.report_problem_outlined), activeIcon: Icon(Icons.report_problem), label: "KELUHAN"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: "PROFIL"),
          ],
        ),
      ),
    );
  }
}

// =================== HOME PAGE ===================
class HomePage extends StatelessWidget {
  final List<Map<String, String>> beritaLinks = [
    {
      "title": "Profil UMKM Elok Mekar Sari",
      "url": "https://elokmekarsariukm.wordpress.com/profile/"
    },
    {
      "title": "Blog UMKM Elok Mekar Sari",
      "url": "https://ukmelokmekarsari.home.blog/"
    },
    {
      "title": "Artikel Innovillage - Smart Farming Jamur Tiram",
      "url": "https://innovillage.id/artikel/pemanfaatan-teknologi-smart-farming-untuk-meningkatkan-efisiensi-budidaya-jamur-di-kelompok-tani-elok-mekar-sari-surabaya"
    },
    {
      "title": "Artikel Jurnal Abdidas",
      "url": "https://www.abdidas.org/index.php/abdidas/article/view/1119"
    },
  ];

  final List<Map<String, dynamic>> stats = [
    {"value": "50+", "label": "PENGRAJIN LOKAL"},
    {"value": "1.2k", "label": "PRODUK TERJUAL"},
    {"value": "10+ Thn", "label": "BERKARYA"},
    {"value": "100%", "label": "BAHAN ALAMI"},
  ];

  final List<Map<String, String>> products = [
    {"name": "Nugget Lele", "price": "Rp29.000", "cat": "Produk Unggulan", "emoji": "🍗"},
    {"name": "Sempol Jamur", "price": "Rp7.000", "cat": "Camilan Sehat", "emoji": "🍢"},
    {"name": "Bakso Jamur", "price": "Rp12.000", "cat": "Makanan Sehat", "emoji": "🍲"},
    {"name": "Abon Jamur", "price": "Rp25.000", "cat": "Produk Unggulan", "emoji": "✨"},
  ];

  final List<Map<String, String>> berita = [
    {
      "tag": "KOMUNITAS · 18 JULI 2023",
      "title": "Pemkot Surabaya Dukung Urban Farming Kelompok Tani Elok Mekar Sari.",
      "desc": "Pemkot Surabaya mendukung urban farming Elok Mekar Sari yang kini membina 15 UMKM.",
      "emoji": "👥",
    },
    {
      "tag": "EDUKASI · 17 JANUARI 2023",
      "title": "Budidaya Jamur Tiram Kelompok Tani Elok Mekar Sari Semolowaru Surabaya",
      "desc": "Kelompok Elok Mekar Sari membudidayakan jamur tiram untuk ekonomi warga.",
      "emoji": "🌾",
    },
    {
      "tag": "ACARA · 29 SEP 2025",
      "title": "PKM BIMA Bersama Elok Mekar Sari dalam Urban Farming",
      "desc": "Kegiatan pengabdian PKM BIMA bersama Kelompok Tani Elok Mekar Sari dalam pengembangan urban farming.",
      "emoji": "🤝",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ---- APP BAR ----
        SliverAppBar(
          backgroundColor: kBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          floating: true,
          pinned: false,
          title: Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.eco, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'Elok Mekar Sari',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDark, letterSpacing: -0.3),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kBorder, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 18, color: kDark),
            ),
          ],
        ),

        SliverList(
          delegate: SliverChildListDelegate([

            // ---- HERO ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('EDISI WARISAN 2026', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGray, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero Title
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: kDark, height: 1.1, letterSpacing: -1),
                      children: [
                        TextSpan(text: 'Warisan Budaya untuk\n'),
                        TextSpan(text: 'Gaya Hidup ', style: TextStyle(color: kGreen, fontStyle: FontStyle.italic)),
                        TextSpan(text: 'Modern'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Menyusun cita rasa tradisional dan kerajinan tangan autentik dari jantung Surabaya sejak 1998 ke dalam kehidupan modern Anda.',
                    style: TextStyle(fontSize: 14, color: kGray, height: 1.6),
                  ),
                  const SizedBox(height: 22),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MarketplacePage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Jelajahi Katalog', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const KisahKamiPage()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kDark,
                            side: const BorderSide(color: kBorder, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Kisah Kami', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hero Image
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B8F5E), Color(0xFF3D6B35)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('🌿', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 8),
                          Text('KELOMPOK TANI\nELOK MEKAR SARI',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1, height: 1.4)),
                          SizedBox(height: 4),
                          Text('Semolowaru, Surabaya',
                            style: TextStyle(fontSize: 11, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---- STATS ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: stats.map((s) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s['value']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kGreen, height: 1)),
                      const SizedBox(height: 4),
                      Text(s['label']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kGray, letterSpacing: 0.8)),
                    ],
                  ),
                )).toList(),
              ),
            ),

            // ---- ABOUT ----
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Text(
                'Didirikan di Surabaya pada tahun 1998, Elok Mekar Sari bermula dari keinginan sederhana: melestarikan resep kuno dan teknik kerajinan tangan yang mulai terlupakan. Kami percaya bahwa makanan sehat dan kriya yang indah adalah fondasi gaya hidup modern yang bermakna.',
                style: TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.7),
              ),
            ),

            // ---- FEATURES ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                children: [
                  _FeatureItem(icon: Icons.grass_outlined, title: 'Bahan Alami', desc: 'Hanya menggunakan bahan dari petani lokal tanpa pengawet buatan.'),
                  const SizedBox(height: 12),
                  _FeatureItem(icon: Icons.draw_outlined, title: 'Karya Tangan', desc: 'Setiap produk membawa sidik jari dan jiwa para pengrajin kami.'),
                ],
              ),
            ),

            // ---- SECTION HEADER PRODUK ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KATALOG TERPILIH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen, letterSpacing: 1)),
                        SizedBox(height: 4),
                        Text('Koleksi\nProduk Lokal', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: kDark, height: 1.1)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Text('Lihat Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kGreen)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14, color: kGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---- FEATURED PRODUCT CARD ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A7C40), Color(0xFF2D5A27)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(child: Text('🍄', style: TextStyle(fontSize: 80))),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🔥 TERLARIS · MAKANAN SEHAT',
                              style: TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 1, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            const Text('Sate Jamur Tiram',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, height: 1.1)),
                            const SizedBox(height: 6),
                            const Text('Olahan jamur pilihan dengan bumbu rempah rahasia yang autentik dan rendah kalori.',
                              style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4)),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: kDark,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Pesan Sekarang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- PRODUCT GRID ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: products.map((p) => _ProductCard(
                  name: p['name']!,
                  price: p['price']!,
                  cat: p['cat']!,
                  emoji: p['emoji']!,
                )).toList(),
              ),
            ),

            // ---- BERITA ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Berita & Galeri Komunitas',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kDark)),
                  const SizedBox(height: 16),
                  ...berita.asMap().entries.map((e) => _NewsCard(
                    tag: e.value['tag']!,
                    title: e.value['title']!,
                    desc: e.value['desc']!,
                    emoji: e.value['emoji']!,
                    showDivider: e.key < berita.length - 1,
                  )),
                ],
              ),
            ),

            // ---- FOOTER ----
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDE6),
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Elok Mekar Sari',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kGreen)),
                  const SizedBox(height: 6),
                  const Text('Menghubungkan pengrajin lokal Indonesia dengan gaya hidup modern melalui produk berkualitas tinggi.',
                    style: TextStyle(fontSize: 12, color: kGray, height: 1.5)),
                  const SizedBox(height: 16),
                  const Text('NAVIGASI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kDark, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  ...['Beranda', 'Toko Produk', 'Kisah Kami', 'Kontak'].map((t) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(t, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
                    )),
                  const SizedBox(height: 12),
                  const Text('HUBUNGI KAMI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kDark, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  _ContactRow(icon: Icons.email_outlined, text: 'info@elokmekarsari.com'),
                  const SizedBox(height: 6),
                  _ContactRow(icon: Icons.phone_outlined, text: '+62 31 123 4567'),
                  const SizedBox(height: 6),
                  _ContactRow(icon: Icons.location_on_outlined, text: 'Surabaya, Jawa Timur'),
                  const SizedBox(height: 16),
                  const Text('IKUTI KAMI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kDark, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(
                    children: [Icons.language, Icons.facebook, Icons.edit_note].map((ic) =>
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: kBorder),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(ic, size: 18, color: kDark),
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      '© 2024 Elok Mekar Sari. Dibuat dengan cinta untuk tradisi.\nPrivacy Policy   ·   Terms of Service',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: kGray, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

// =================== WIDGETS ===================
class KisahKamiPage extends StatelessWidget {
  const KisahKamiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Kisah Kami'),
        backgroundColor: kGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kGreenPale,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'UMKM Elok Mekar Sari',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kDark),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Kelompok tani yang berada di Kelurahan Semolowaru, Surabaya, bergerak pada olahan makanan alami tanpa bahan pengawet. Kami mengolah hasil budidaya ikan lele dan jamur tiram menjadi produk kreatif yang lezat.',
                    style: TextStyle(fontSize: 14, color: kGray, height: 1.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sejarah dan Produk Unggulan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDark),
            ),
            const SizedBox(height: 12),
            const Text(
              'Didirikan di Surabaya pada tahun 1998, Elok Mekar Sari bermula dari keinginan sederhana: melestarikan resep kuno dan teknik kerajinan tangan yang mulai terlupakan. Kami percaya bahwa makanan sehat dan kriya yang indah adalah fondasi gaya hidup modern yang bermakna.\n\nUMKM Elok Mekar Sari memproduksi aneka olahan makanan dari bahan alami tanpa pengawet. Produk unggulan kami adalah nugget lele, sempol jamur, tahu walik, jangkrik krispi, sinom, dan sate jamur—semuanya dirancang agar nikmat dan mudah dinikmati.',
              style: TextStyle(fontSize: 14, color: kGray, height: 1.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pelatihan dan Komunitas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDark),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kami rutin mengadakan pelatihan untuk masyarakat Surabaya dan pelajar. Tujuannya adalah berbagi wawasan bahwa bahan sehari-hari seperti ikan lele, jamur tiram, dan tahu bisa dijadikan menu yang lebih menarik dan bergizi. UMKM ini juga melibatkan ibu rumah tangga sekitar Semolowaru untuk menambah penghasilan keluarga.',
              style: TextStyle(fontSize: 14, color: kGray, height: 1.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dukungan dan Kegiatan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDark),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kegiatan UMKM Elok Mekar Sari mendapat dukungan positif dari pemerintah Kota Surabaya karena membantu warga sekitar, terutama ibu-ibu rumah tangga. Produk kami sering laris di berbagai event, bahkan terkadang habis terjual saat acara selesai.',
              style: TextStyle(fontSize: 14, color: kGray, height: 1.7),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 18, offset: const Offset(0, 8)),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kontak dan Lokasi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDark),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Icon(Icons.phone, size: 18, color: kGreen),
                      SizedBox(width: 10),
                      Expanded(child: Text('0895-3013-2581', style: TextStyle(fontSize: 14, color: kDark))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.location_on_outlined, size: 18, color: kGreen),
                      SizedBox(width: 10),
                      Expanded(child: Text('Semolowaru Elok, Semolowaru, Sukolilo, Kota Surabaya, Jawa Timur 60119', style: TextStyle(fontSize: 14, color: kDark, height: 1.6))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Jam operasional: Senin - Minggu, 08.00 - 18.00',
                    style: TextStyle(fontSize: 14, color: kGray, height: 1.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: kGreenPale, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 18, color: kGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDark)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12, color: kGray, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name, price, cat, emoji;
  const _ProductCard({required this.name, required this.price, required this.cat, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2E6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDark)),
                const SizedBox(height: 2),
                Text(cat, style: const TextStyle(fontSize: 10, color: kGray, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kGreen)),
                    const Spacer(),
                    const Icon(Icons.arrow_outward, size: 14, color: kGreen),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String tag, title, desc, emoji;
  final bool showDivider;
  const _NewsCard({required this.tag, required this.title, required this.desc, required this.emoji, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFDDE8D8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 48))),
        ),
        const SizedBox(height: 10),
        Text(tag, style: const TextStyle(fontSize: 11, color: kGreen, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDark, height: 1.4)),
        const SizedBox(height: 6),
        Text(desc, style: const TextStyle(fontSize: 12, color: kGray, height: 1.5)),
        if (showDivider) ...[
          const SizedBox(height: 16),
          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kGray),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
      ],
    );
  }
}

// =================== HALAMAN LAIN ===================
// Marketplace diimpor dari Marketplace_Dan_Order Tracking.dart

// Order Tracking diimpor dari Marketplace_Dan_Order Tracking.dart
// Menggunakan OrderTrackingPage sebagai pengganti OrdersPage