import 'package:flutter/material.dart';
import 'Register_Page.dart';

const kGreen = Color(0xFF2D5A27);
const kGreenLight = Color(0xFF4A8C3F);
const kGreenPale = Color(0xFFEAF2E6);
const kCream = Color(0xFFF5F0E8);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

// ========== LOGIN PAGE ==========
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String _selectedRole = 'User';

  void _login() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Email dan password harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate login process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);

      // Check if login as Admin with hardcoded credentials (regardless of selected role)
      if (_emailController.text == 'admin123' &&
          _passwordController.text == 'AdminTes123') {
        // Admin login successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Admin berhasil!'),
            backgroundColor: kGreen,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
        return;
      }

      // For User and UMKM roles, navigate to respective pages
      String routeName = '/home'; // Default for User
      String roleLabel = 'User';

      if (_selectedRole == 'UMKM') {
        routeName = '/umkm';
        roleLabel = 'UMKM';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login $roleLabel berhasil!'),
          backgroundColor: kGreen,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // ===== GREETING =====
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan masuk ke akun Anda untuk melanjutkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: kGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // ===== SOCIAL LOGIN BUTTONS =====
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(
                        icon: '🔵',
                        label: 'Google',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login dengan Google sedang dikembangkan'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSocialButton(
                        icon: '👍',
                        label: 'Facebook',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login dengan Facebook sedang dikembangkan'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ===== DIVIDER =====
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: kBorder,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'ATAU EMAIL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kGray,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: kBorder,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ===== ROLE SELECTION =====
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis Pengguna',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kDark,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      items: ['User', 'UMKM'].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                      decoration: InputDecoration(
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ===== EMAIL INPUT =====
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat Email',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kDark,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'nama@email.com',
                        hintStyle: TextStyle(color: kGray.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.email_outlined, color: kGray),
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ===== PASSWORD INPUT =====
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kata Sandi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kDark,
                            letterSpacing: 0.3,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur lupa password sedang dikembangkan'),
                              ),
                            );
                          },
                          child: Text(
                            'Lupa Kata Sandi?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: kGray.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.lock_outline, color: kGray),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: kGray,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ===== REMEMBER ME =====
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() => _rememberMe = value ?? false);
                        },
                        activeColor: kGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ingat saya di perangkat ini',
                      style: TextStyle(
                        fontSize: 12,
                        color: kGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ===== LOGIN BUTTON =====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      disabledBackgroundColor: kGreen.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Masuk Sekarang',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // ===== SIGN UP LINK =====
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: kGray,
                        ),
                      ),
                      Text(
                        'Daftar Sekarang',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: kGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ===== FOOTER =====
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'SYARAT & KETENTUAN',
                            style: TextStyle(
                              fontSize: 10,
                              color: kGray,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 1,
                          height: 12,
                          color: kBorder,
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'KEBIJAKAN PRIVASI',
                            style: TextStyle(
                              fontSize: 10,
                              color: kGray,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 1,
                          height: 12,
                          color: kBorder,
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'BANTUAN',
                            style: TextStyle(
                              fontSize: 10,
                              color: kGray,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '© 2026 Elok Mekar Sari. Surabaya Produk Lokal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: kGray.withOpacity(0.6),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Test Credentials Hint
                    Text(
                      '👉 Admin: admin123 / AdminTes123 (bisa login dari User/UMKM)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: kGray.withValues(alpha: 0.4),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
