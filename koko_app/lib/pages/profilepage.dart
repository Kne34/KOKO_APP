import 'package:flutter/material.dart';
import 'package:koko_app/pages/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final Function(bool) koTheme;
  const ProfilePage({super.key, required this.koTheme});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
      _email = prefs.getString('email') ?? '';
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage(koTheme: widget.koTheme)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A0E0A) : const Color(0xFFFFF8F4);
    final cardColor = isDark ? const Color(0xFF2C1A12) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2C1A12);
    final subTextColor = isDark ? Colors.brown[200] : Colors.brown[400];

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B4513)),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF8B4513).withValues(alpha: 0.15),
              child: Text(
                _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF8B4513),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              _username,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(_email, style: TextStyle(color: subTextColor, fontSize: 14)),
            const SizedBox(height: 32),

            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.person,
                    'Username',
                    _username,
                    textColor,
                    subTextColor,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.email,
                    'Email',
                    _email,
                    textColor,
                    subTextColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Color(0xFF8B4513)),
                label: const Text(
                  'Keluar',
                  style: TextStyle(color: Color(0xFF8B4513)),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF8B4513)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color? subTextColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF8B4513), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: subTextColor, fontSize: 11)),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
