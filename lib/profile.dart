import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Login_Page.dart';

const kGreen = Color(0xFF2D5A27);
const kGreenPale = Color(0xFFEAF2E6);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

class ProfilePage extends StatefulWidget {
  final VoidCallback? onProfileUpdate;
  const ProfilePage({Key? key, this.onProfileUpdate}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;

  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _city = '';
  String _joinDate = '';
  String _uid = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _loadProfile();
  }

  // ===== BACA PROFIL DARI FIRESTORE =====
  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _uid = user.uid;
      _email = user.email ?? '';

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        final ts = data['joinDate'] as Timestamp?;
        setState(() {
          _name = data['name'] ?? '';
          _phone = data['phone'] ?? '';
          _address = data['address'] ?? '';
          _city = data['city'] ?? '';
          _joinDate = ts != null
              ? _formatDate(ts.toDate())
              : 'Baru bergabung';
          _nameController.text = _name;
          _phoneController.text = _phone;
          _addressController.text = _address;
          _cityController.text = _city;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  // ===== SIMPAN PROFIL KE FIRESTORE =====
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _name = _nameController.text.trim();
        _phone = _phoneController.text.trim();
        _address = _addressController.text.trim();
        _city = _cityController.text.trim();
        _isEditing = false;
        _isSaving = false;
      });

      widget.onProfileUpdate?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan'),
            backgroundColor: kGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ===== LOGOUT =====
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(child: CircularProgressIndicator(color: kGreen)),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Profil Saya',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kGreen,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: () {
                if (_isEditing) {
                  _saveProfile();
                } else {
                  setState(() => _isEditing = true);
                }
              },
              style: TextButton.styleFrom(foregroundColor: kGreenPale),
              icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 20),
              label: Text(_isEditing ? 'Simpan' : 'Edit',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
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
                    decoration: const BoxDecoration(
                      color: kGreenPale,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.person, size: 40, color: kGreen),
                  ),
                  const SizedBox(height: 12),
                  Text(_name.isEmpty ? 'Pengguna' : _name,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kDark)),
                  const SizedBox(height: 4),
                  Text(_email,
                      style:
                          const TextStyle(fontSize: 13, color: kGray)),
                  const SizedBox(height: 12),
                  if (_joinDate.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: kGreenPale,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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

            // Logout
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
              child: InkWell(
                onTap: _logout,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: const [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Keluar Akun',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red)),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.red),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kDark)),
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
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
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
          BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 12)
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
                  color: kDark)),
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
                  fontSize: 13,
                  color: kGray,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  color: kDark,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}