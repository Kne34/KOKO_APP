import 'package:flutter/material.dart';
import 'package:koko_app/apis/api.dart';
import 'package:koko_app/pages/loginpage.dart';

class RegisterPage extends StatefulWidget {
  final Function(bool) koTheme;
  const RegisterPage({super.key, required this.koTheme});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isPassVis = false;
  bool _isConfirmVis = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Form Error'),
          content: const Text('Pastikan semua field sudah diisi dengan benar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final (success, message) = await register(
        _username.text.trim(),
        _email.text.trim(),
        _password.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage(koTheme: widget.koTheme)),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Registrasi Gagal'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Koneksi Gagal'),
          content: const Text(
            'Tidak dapat terhubung ke server. Pastikan backend berjalan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4B2C20), Color(0xFF8B4513)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/logo-KOKO2.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bergabung dengan Komunitas Kopi',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _username,
                      style: const TextStyle(color: Colors.black),
                      validator: (val) {
                        if (val!.isEmpty) return 'Username tidak boleh kosong';
                        if (val.length < 4) {
                          return 'Username minimal 4 karakter';
                        }
                        if (val.contains(' ')) {
                          return 'Username tidak boleh ada spasi';
                        }
                        return null;
                      },
                      onSaved: (val) {},
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Username',
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _email,
                      style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val!.isEmpty) return 'Email tidak boleh kosong';
                        if (!RegExp(
                          r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(val)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                      onSaved: (val) {},
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _password,
                      style: const TextStyle(color: Colors.black),
                      obscureText: !_isPassVis,
                      validator: (val) {
                        if (val!.isEmpty) return 'Password tidak boleh kosong';
                        if (val.length < 8) {
                          return 'Password minimal 8 karakter';
                        }
                        if (!val.contains(RegExp(r'[0-9]'))) {
                          return 'Password harus mengandung angka';
                        }
                        return null;
                      },
                      onSaved: (val) {},
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPassVis
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => _isPassVis = !_isPassVis),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPassword,
                      style: const TextStyle(color: Colors.black),
                      obscureText: !_isConfirmVis,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong';
                        }
                        if (val != _password.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                      onSaved: (val) {},
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Konfirmasi Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmVis
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => _isConfirmVis = !_isConfirmVis),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B2C20),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFF4B2C20,
                          ).withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginPage(koTheme: widget.koTheme),
                          ),
                        ),
                        child: const Text.rich(
                          TextSpan(
                            text: 'Sudah punya akun? ',
                            style: TextStyle(color: Colors.white70),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
