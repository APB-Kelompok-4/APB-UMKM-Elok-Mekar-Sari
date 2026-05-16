import 'package:flutter/material.dart';

// =================== COLORS ===================
const kGreen = Color(0xFF2D5A27);
const kGreenPale = Color(0xFFEAF2E6);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

// =================== PROFILE PAGE ===================
class ProfilePage extends StatefulWidget {
  final VoidCallback? onProfileUpdate;
  const ProfilePage({Key? key, this.onProfileUpdate}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;

  // User data
  String _userId = 'USR-001';
  String _name = 'Budi Santoso';
  String _email = 'budi.santoso@email.com';
  String _phone = '0895-3013-2581';
  String _address = 'Jl. Semolowaru Elok No. 15';
  String _city = 'Surabaya, Jawa Timur';
  String _joinDate = '15 Januari 2024';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _name);
    _emailController = TextEditingController(text: _email);
    _phoneController = TextEditingController(text: _phone);
    _addressController = TextEditingController(text: _address);
    _cityController = TextEditingController(text: _city);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() {
      _name = _nameController.text;
      _email = _emailController.text;
      _phone = _phoneController.text;
      _address = _addressController.text;
      _city = _cityController.text;
      _isEditing = false;
    });
    widget.onProfileUpdate?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kGreen,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
              if (!_isEditing) _saveProfile();
            },
            // Tambahkan baris style ini
            style: TextButton.styleFrom(
              foregroundColor:
                  kGreenPale, // Menggunakan warna kGreenPale agar senada dengan tema
            ),
            icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 20),
            label: Text(
              _isEditing ? 'Simpan' : 'Edit',
              style: const TextStyle(
                  fontWeight: FontWeight
                      .w600), // Tambahkan ketebalan agar lebih terbaca
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8))
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: kGreenPale,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 40, color: kGreen),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userId,
                    style: const TextStyle(
                        fontSize: 13, color: kGray, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: kGreenPale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'Bergabung sejak $_joinDate',
                      style: const TextStyle(
                          fontSize: 12,
                          color: kGreen,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Edit Form or Display
            if (_isEditing)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 12)
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit Profil',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: kDark)),
                    const SizedBox(height: 16),
                    _buildTextField('Nama Lengkap', _nameController),
                    const SizedBox(height: 12),
                    _buildTextField('Email', _emailController),
                    const SizedBox(height: 12),
                    _buildTextField('Nomor Telepon', _phoneController),
                    const SizedBox(height: 12),
                    _buildTextField('Alamat', _addressController),
                    const SizedBox(height: 12),
                    _buildTextField('Kota', _cityController),
                  ],
                ),
              )
            else
              Column(
                children: [
                  _buildInfoCard('Informasi Pribadi', [
                    _buildInfoRow('Nama', _name),
                    _buildInfoRow('Email', _email),
                    _buildInfoRow('Nomor Telepon', _phone),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('Alamat', [
                    _buildInfoRow('Alamat Lengkap', _address),
                    _buildInfoRow('Kota', _city),
                  ]),
                ],
              ),
            const SizedBox(height: 20),

            // Account Actions
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 12)
                ],
              ),
              child: Column(
                children: [
                  _buildActionTile('Riwayat Pembelian', Icons.history, () {}),
                  Divider(color: kBorder, height: 1),
                  _buildActionTile(
                      'Daftar Alamat', Icons.location_on_outlined, () {}),
                  Divider(color: kBorder, height: 1),
                  _buildActionTile('Pengaturan Notifikasi',
                      Icons.notifications_outlined, () {}),
                  Divider(color: kBorder, height: 1),
                  _buildActionTile(
                      'Bantuan & Dukungan', Icons.help_outline, () {}),
                  Divider(color: kBorder, height: 1),
                  _buildActionTile('Keluar Akun', Icons.logout, () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                      isLogout: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: kDark)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBorder)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBorder)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kGreen, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            hintText: label,
            hintStyle: const TextStyle(color: kGray),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 12)
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kDark,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: kGray, fontWeight: FontWeight.w500)),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13, color: kDark, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap,
      {bool isLogout = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isLogout ? Colors.red : kGreen),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isLogout ? Colors.red : kDark),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: isLogout ? Colors.red : kGray),
          ],
        ),
      ),
    );
  }
}