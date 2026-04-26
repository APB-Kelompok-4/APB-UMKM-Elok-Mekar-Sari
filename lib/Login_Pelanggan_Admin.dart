import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const kGreen = Color(0xFF2D5A27);
const kGreenLight = Color(0xFF4A8C3F);
const kGreenPale = Color(0xFFEAF2E6);
const kCream = Color(0xFFF5F0E8);
const kDark = Color(0xFF1A1A1A);
const kGray = Color(0xFF666666);
const kBorder = Color(0xFFE0D8CC);
const kBg = Color(0xFFFAFAF7);

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String userType; // 'customer' or 'umkm_member'
  final DateTime registeredDate;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.userType,
    required this.registeredDate,
    required this.isActive,
  });
}

class UMKMMember {
  final String id;
  final String name;
  final String position;
  final String phone;
  final String email;
  final String address;
  final String specialization;
  final DateTime joinDate;
  final String status; // 'active', 'inactive', 'leave'
  final String photoUrl;

  UMKMMember({
    required this.id,
    required this.name,
    required this.position,
    required this.phone,
    required this.email,
    required this.address,
    required this.specialization,
    required this.joinDate,
    required this.status,
    required this.photoUrl,
  });
}

class LoginSelectionPage extends StatefulWidget {
  const LoginSelectionPage({Key? key}) : super(key: key);

  @override
  State<LoginSelectionPage> createState() => _LoginSelectionPageState();
}

class _LoginSelectionPageState extends State<LoginSelectionPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  // Sample users database
  final List<User> users = [
    User(
      id: 'CUST-001',
      name: 'Budi Santoso',
      email: 'budi@email.com',
      password: 'password123',
      phone: '081234567890',
      address: 'Jl. Maju Jaya No. 10, Surabaya',
      userType: 'customer',
      registeredDate: DateTime(2023, 1, 15),
      isActive: true,
    ),
    User(
      id: 'CUST-002',
      name: 'Siti Nurhaliza',
      email: 'siti@email.com',
      password: 'password456',
      phone: '082345678901',
      address: 'Jl. Harmoni No. 25, Surabaya',
      userType: 'customer',
      registeredDate: DateTime(2023, 3, 20),
      isActive: true,
    ),
  ];

  void _login() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Email dan password harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate login process
    Future.delayed(const Duration(seconds: 2), () {
      final user = users.firstWhere(
        (u) =>
            u.email == _emailController.text &&
            u.password == _passwordController.text,
        orElse: () => User(
          id: '',
          name: '',
          email: '',
          password: '',
          phone: '',
          address: '',
          userType: '',
          registeredDate: DateTime.now(),
          isActive: false,
        ),
      );

      setState(() => _isLoading = false);

      if (user.id.isNotEmpty && user.isActive) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDashboard(user: user),
          ),
        );
      } else {
        _showErrorSnackBar('Email atau password salah');
      }
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

                // ===== SIGNUP LINK =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        fontSize: 12,
                        color: kGray,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Daftar Sekarang',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

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


class CustomerLoginPage extends StatefulWidget {
  const CustomerLoginPage({Key? key}) : super(key: key);

  @override
  State<CustomerLoginPage> createState() => _CustomerLoginPageState();
}

class _CustomerLoginPageState extends State<CustomerLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Sample users database
  final List<User> users = [
    User(
      id: 'CUST-001',
      name: 'Budi Santoso',
      email: 'budi@email.com',
      password: 'password123',
      phone: '081234567890',
      address: 'Jl. Maju Jaya No. 10, Surabaya',
      userType: 'customer',
      registeredDate: DateTime(2023, 1, 15),
      isActive: true,
    ),
    User(
      id: 'CUST-002',
      name: 'Siti Nurhaliza',
      email: 'siti@email.com',
      password: 'password456',
      phone: '082345678901',
      address: 'Jl. Harmoni No. 25, Surabaya',
      userType: 'customer',
      registeredDate: DateTime(2023, 3, 20),
      isActive: true,
    ),
  ];

  void _login() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Email dan password harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate login process
    Future.delayed(const Duration(seconds: 2), () {
      final user = users.firstWhere(
        (u) =>
            u.email == _emailController.text &&
            u.password == _passwordController.text,
        orElse: () => User(
          id: '',
          name: '',
          email: '',
          password: '',
          phone: '',
          address: '',
          userType: '',
          registeredDate: DateTime.now(),
          isActive: false,
        ),
      );

      setState(() => _isLoading = false);

      if (user.id.isNotEmpty && user.isActive) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDashboard(user: user),
          ),
        );
      } else {
        _showErrorSnackBar('Email atau password salah');
      }
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
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Login Pelanggan'),
        backgroundColor: kGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Selamat Datang Kembali',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan email dan password Anda',
              style: TextStyle(fontSize: 14, color: kGray),
            ),
            const SizedBox(height: 32),

            // Email Field
            Text(
              'Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Masukkan email Anda',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            Text(
              'Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Masukkan password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                        'Masuk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Back Button
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Kembali',
                  style: TextStyle(color: kGreen),
                ),
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

// ==================== ADMIN LOGIN PAGE ====================
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Email dan password harus diisi');
      return;
    }

    // Simple admin check
    if (_emailController.text == 'admin@elokmekar.com' &&
        _passwordController.text == 'admin123') {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboard(),
          ),
        );
      });
    } else {
      _showErrorSnackBar('Email atau password admin salah');
    }
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
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Login Admin'),
        backgroundColor: kGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Administrasi Sistem',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan kredensial admin Anda',
              style: TextStyle(fontSize: 14, color: kGray),
            ),
            const SizedBox(height: 32),

            // Warning Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Akses terbatas untuk admin terotorisasi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Email Field
            Text(
              'Email Admin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Masukkan email admin',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            Text(
              'Password Admin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Masukkan password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                        'Masuk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Back Button
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Kembali',
                  style: TextStyle(color: kGreen),
                ),
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

// ==================== REGISTER PAGE ====================
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorSnackBar('Semua field harus diisi');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Password tidak sesuai');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registrasi berhasil! Silakan login'),
        backgroundColor: kGreen,
      ),
    );

    Navigator.pop(context);
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
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Daftar Pelanggan Baru'),
        backgroundColor: kGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Buat Akun Baru',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 24),

            // Name
            _buildTextField(
              'Nama Lengkap',
              'Masukkan nama Anda',
              Icons.person,
              _nameController,
            ),
            const SizedBox(height: 16),

            // Email
            _buildTextField(
              'Email',
              'Masukkan email Anda',
              Icons.email,
              _emailController,
            ),
            const SizedBox(height: 16),

            // Phone
            _buildTextField(
              'Nomor Telepon',
              'Masukkan nomor telepon',
              Icons.phone,
              _phoneController,
            ),
            const SizedBox(height: 16),

            // Address
            _buildTextField(
              'Alamat',
              'Masukkan alamat lengkap',
              Icons.location_on,
              _addressController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Password
            Text(
              'Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Masukkan password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            Text(
              'Konfirmasi Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Konfirmasi password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Daftar',
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
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: kDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// ==================== CUSTOMER DASHBOARD ====================
class CustomerDashboard extends StatelessWidget {
  final User user;

  const CustomerDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Dashboard Pelanggan'),
        backgroundColor: kGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kGreen, kGreenLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, ${user.name}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Anggota sejak ${DateFormat('d MMMM yyyy', 'id_ID').format(user.registeredDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // User Info
            const Text(
              'Informasi Akun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard('Email', user.email, Icons.email),
            const SizedBox(height: 8),
            _buildInfoCard('Telepon', user.phone, Icons.phone),
            const SizedBox(height: 8),
            _buildInfoCard('Alamat', user.address, Icons.location_on),
            const SizedBox(height: 20),

            // Quick Actions
            const Text(
              'Menu Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildActionCard(
                  'Pesanan Saya',
                  Icons.shopping_cart,
                  Colors.blue,
                  () {},
                ),
                _buildActionCard(
                  'Keluhan',
                  Icons.report_problem,
                  Colors.orange,
                  () {},
                ),
                _buildActionCard(
                  'Riwayat Transaksi',
                  Icons.history,
                  Colors.green,
                  () {},
                ),
                _buildActionCard(
                  'Pengaturan',
                  Icons.settings,
                  Colors.purple,
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: kGreen, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: kGray),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
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
}

// ==================== ADMIN DASHBOARD ====================
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _filterStatus = 'Semua';

  final List<User> customers = [
    User(
      id: 'CUST-001',
      name: 'Budi Santoso',
      email: 'budi@email.com',
      password: 'password123',
      phone: '081234567890',
      address: 'Jl. Maju Jaya No. 10, Surabaya',
      userType: 'customer',
      registeredDate: DateTime(2023, 1, 15),
      isActive: true,
    ),
    User(
      id: 'CUST-002',
      name: 'Siti Nurhaliza',
      email: 'siti@email.com',
      password: 'password456',
      phone: '082345678901',
      address: 'Jl. Harmoni No. 25, Surabaya',
      userType: 'customer',
      registeredDate: DateTime(2023, 3, 20),
      isActive: true,
    ),
    User(
      id: 'CUST-003',
      name: 'Ahmad Wijaya',
      email: 'ahmad@email.com',
      password: 'password789',
      phone: '083456789012',
      address: 'Jl. Sejahtera No. 5, Surabaya',
      userType: 'customer',
      registeredDate: DateTime(2023, 6, 10),
      isActive: false,
    ),
  ];

  final List<UMKMMember> umkmMembers = [
    UMKMMember(
      id: 'UMKM-001',
      name: 'Hendra Kurniawan',
      position: 'Ketua',
      phone: '081111111111',
      email: 'hendra@elok.com',
      address: 'Jl. Veteran No. 1, Surabaya',
      specialization: 'Manajemen',
      joinDate: DateTime(2020, 1, 10),
      status: 'active',
      photoUrl: 'assets/photo1.jpg',
    ),
    UMKMMember(
      id: 'UMKM-002',
      name: 'Dwi Lestari',
      position: 'Wakil Ketua',
      phone: '082222222222',
      email: 'dwi@elok.com',
      address: 'Jl. Raya Timur No. 12, Surabaya',
      specialization: 'Produksi',
      joinDate: DateTime(2020, 3, 15),
      status: 'active',
      photoUrl: 'assets/photo2.jpg',
    ),
    UMKMMember(
      id: 'UMKM-003',
      name: 'Bambang Surya',
      position: 'Sekretaris',
      phone: '083333333333',
      email: 'bambang@elok.com',
      address: 'Jl. Mawar No. 7, Surabaya',
      specialization: 'Administrasi',
      joinDate: DateTime(2021, 6, 20),
      status: 'active',
      photoUrl: 'assets/photo3.jpg',
    ),
    UMKMMember(
      id: 'UMKM-004',
      name: 'Sinta Maulida',
      position: 'Bendahara',
      phone: '084444444444',
      email: 'sinta@elok.com',
      address: 'Jl. Anggrek No. 3, Surabaya',
      specialization: 'Keuangan',
      joinDate: DateTime(2021, 8, 5),
      status: 'inactive',
      photoUrl: 'assets/photo4.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<User> get filteredCustomers {
    return customers.where((customer) {
      final matchesSearch = customer.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          customer.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _filterStatus == 'Semua' ||
          (_filterStatus == 'Aktif' && customer.isActive) ||
          (_filterStatus == 'Nonaktif' && !customer.isActive);
      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<UMKMMember> get filteredMembers {
    return umkmMembers.where((member) {
      final matchesSearch = member.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          member.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _filterStatus == 'Semua' || member.status == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: kGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pelanggan'),
            Tab(text: 'Anggota UMKM'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() => _filterStatus = value);
                  },
                  itemBuilder: (BuildContext context) {
                    final options = _tabController.index == 0
                        ? ['Semua', 'Aktif', 'Nonaktif']
                        : ['Semua', 'active', 'inactive', 'leave'];
                    return options
                        .map((option) => PopupMenuItem(
                              value: option,
                              child: Text(option),
                            ))
                        .toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list, size: 20),
                        SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Customers Tab
                filteredCustomers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 80, color: kBorder),
                            const SizedBox(height: 16),
                            const Text(
                              'Tidak ada data pelanggan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return _buildUserCard(customer, () {
                            _showUserDetail(context, customer);
                          });
                        },
                      ),

                // UMKM Members Tab
                filteredMembers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group, size: 80, color: kBorder),
                            const SizedBox(height: 16),
                            const Text(
                              'Tidak ada data anggota',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = filteredMembers[index];
                          return _buildMemberCard(member, () {
                            _showMemberDetail(context, member);
                          });
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kGreenPale,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, color: kGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: kGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.isActive ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(UMKMMember member, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kGreenPale,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.group, color: kGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.position,
                      style: const TextStyle(
                        fontSize: 11,
                        color: kGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: member.status == 'active'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  member.status == 'active' ? 'Aktif' : 'Tidak Aktif',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: member.status == 'active' ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDetail(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Detail Pelanggan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('ID', user.id),
              _buildDetailRow('Nama', user.name),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Telepon', user.phone),
              _buildDetailRow('Alamat', user.address),
              _buildDetailRow(
                'Terdaftar',
                DateFormat('dd MMM yyyy', 'id_ID').format(user.registeredDate),
              ),
              _buildDetailRow(
                'Status',
                user.isActive ? 'Aktif' : 'Nonaktif',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMemberDetail(BuildContext context, UMKMMember member) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Detail Anggota UMKM',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('ID', member.id),
              _buildDetailRow('Nama', member.name),
              _buildDetailRow('Jabatan', member.position),
              _buildDetailRow('Email', member.email),
              _buildDetailRow('Telepon', member.phone),
              _buildDetailRow('Keahlian', member.specialization),
              _buildDetailRow(
                'Bergabung',
                DateFormat('dd MMM yyyy', 'id_ID').format(member.joinDate),
              ),
              _buildDetailRow(
                'Status',
                member.status == 'active' ? 'Aktif' : 'Tidak Aktif',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: kGray),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kDark,
            ),
          ),
        ],
      ),
    );
  }
}
