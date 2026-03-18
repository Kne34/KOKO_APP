import 'package:flutter/material.dart';
import 'package:koko_app/apis/api.dart';
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

  void _showEditDialog() {
    final usernameCtrl = TextEditingController(text: _username);
    final emailCtrl = TextEditingController(text: _email);
    final passwordCtrl = TextEditingController();
    bool isLoading = false;
    bool showPassword = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardColor = isDark ? const Color(0xFF2C1A12) : Colors.white;
          final textColor = isDark ? Colors.white : const Color(0xFF2C1A12);

          return Dialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profil',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _editField(
                      usernameCtrl,
                      'Username',
                      textColor,
                      cardColor,
                      icon: Icons.person,
                    ),
                    _editField(
                      emailCtrl,
                      'Email',
                      textColor,
                      cardColor,
                      icon: Icons.email,
                      type: TextInputType.emailAddress,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: passwordCtrl,
                        obscureText: !showPassword,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText:
                              'Password Baru (kosongkan jika tidak diubah)',
                          labelStyle: const TextStyle(
                            color: Color(0xFF8B4513),
                            fontSize: 12,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xFF8B4513),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () => setDialogState(
                              () => showPassword = !showPassword,
                            ),
                          ),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setDialogState(() => isLoading = true);
                                  try {
                                    final (
                                      success,
                                      message,
                                    ) = await updateAccount(
                                      usernameCtrl.text.trim().isNotEmpty
                                          ? usernameCtrl.text.trim()
                                          : null,
                                      emailCtrl.text.trim().isNotEmpty
                                          ? emailCtrl.text.trim()
                                          : null,
                                      passwordCtrl.text.isNotEmpty
                                          ? passwordCtrl.text
                                          : null,
                                    );

                                    if (!mounted) return;
                                    Navigator.pop(ctx);

                                    if (success) {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                        'username',
                                        usernameCtrl.text.trim(),
                                      );
                                      await prefs.setString(
                                        'email',
                                        emailCtrl.text.trim(),
                                      );
                                      if (!mounted) return;
                                      setState(() {
                                        _username = usernameCtrl.text.trim();
                                        _email = emailCtrl.text.trim();
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Profil berhasil diupdate',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(message)),
                                      );
                                    }
                                  } finally {
                                    setDialogState(() => isLoading = false);
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Simpan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C1A12) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2C1A12);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Hapus Akun?', style: TextStyle(color: textColor)),
        content: Text(
          'Akun kamu akan dihapus permanen.',
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final (success, _) = await deleteAccount();
              if (!mounted) return;
              if (success) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginPage(koTheme: widget.koTheme),
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
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
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF8B4513).withValues(alpha: 0.15),
              child: Text(
                _username.isNotEmpty ? _username[0] : '?',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showEditDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showDeleteDialog,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Hapus Akun',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
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

  Widget _editField(
    TextEditingController ctrl,
    String label,
    Color textColor,
    Color cardColor, {
    IconData icon = Icons.edit,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF8B4513)),
          prefixIcon: Icon(icon, color: const Color(0xFF8B4513)),
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF8B4513)),
          ),
        ),
      ),
    );
  }
}
