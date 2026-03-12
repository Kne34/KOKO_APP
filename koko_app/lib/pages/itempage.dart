import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koko_app/apis/api.dart';
import 'package:koko_app/pages/detailpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isAdmin = prefs.getString('username') == 'admin');
    await _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final (success, data) = await getProducts();
      if (!mounted) return;
      if (success) {
        setState(() => _products = data);
      } else {
        setState(() => _errorMessage = data.toString());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Tidak dapat terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatPrice(dynamic price) {
    final p = int.tryParse(price.toString()) ?? 0;
    final result = p.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return 'Rp $result';
  }

  void _showAddDialog() {
    _showProductDialog();
  }

  void _showEditDialog(Map product) {
    _showProductDialog(product: product);
  }

  void _showProductDialog({Map? product}) {
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: product?['name']);
    final descCtrl = TextEditingController(text: product?['description']);
    final priceCtrl = TextEditingController(
      text: product?['price']?.toString(),
    );
    final categoryCtrl = TextEditingController(text: product?['category']);
    final stockCtrl = TextEditingController(
      text: product?['stock']?.toString(),
    );
    File? imageFile;
    bool isLoading = false;

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
                      isEdit ? 'Edit Produk' : 'Tambah Produk',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (picked != null) {
                          setDialogState(() => imageFile = File(picked.path));
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                              0xFF8B4513,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : product?['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product!['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.add_photo_alternate,
                                    color: Color(0xFF8B4513),
                                    size: 40,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.add_photo_alternate,
                                color: Color(0xFF8B4513),
                                size: 40,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _dialogField(nameCtrl, 'Nama Produk', textColor, cardColor),
                    _dialogField(
                      descCtrl,
                      'Deskripsi',
                      textColor,
                      cardColor,
                      maxLines: 2,
                    ),
                    _dialogField(
                      priceCtrl,
                      'Harga',
                      textColor,
                      cardColor,
                      type: TextInputType.number,
                    ),
                    _dialogField(
                      categoryCtrl,
                      'Kategori',
                      textColor,
                      cardColor,
                    ),
                    _dialogField(
                      stockCtrl,
                      'Stok',
                      textColor,
                      cardColor,
                      type: TextInputType.number,
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
                                    bool success;
                                    if (isEdit) {
                                      final (s, _) = await updateProduct(
                                        product['id'],
                                        nameCtrl.text.trim(),
                                        descCtrl.text.trim(),
                                        int.tryParse(priceCtrl.text),
                                        categoryCtrl.text.trim(),
                                        int.tryParse(stockCtrl.text),
                                        imageFile,
                                      );
                                      success = s;
                                    } else {
                                      final (s, _) = await addProduct(
                                        nameCtrl.text.trim(),
                                        descCtrl.text.trim(),
                                        int.tryParse(priceCtrl.text) ?? 0,
                                        categoryCtrl.text.trim(),
                                        int.tryParse(stockCtrl.text) ?? 0,
                                        imageFile,
                                      );
                                      success = s;
                                    }

                                    if (!mounted) return;
                                    Navigator.pop(ctx);
                                    if (success) {
                                      _fetchProducts();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEdit
                                                ? 'Produk berhasil diupdate'
                                                : 'Produk berhasil ditambahkan',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
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
                              : Text(isEdit ? 'Simpan' : 'Tambah'),
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

  void _confirmDelete(Map product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C1A12) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2C1A12);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Hapus Produk?', style: TextStyle(color: textColor)),
        content: Text(
          'Produk "${product['name']}" akan dihapus permanen.',
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
              final (success, message) = await deleteProduct(product['id']);
              if (!mounted) return;
              if (success) {
                _fetchProducts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produk berhasil dihapus'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    Color textColor,
    Color cardColor, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: type,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF8B4513)),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A0E0A) : const Color(0xFFFFF8F4);
    final cardColor = isDark ? const Color(0xFF2C1A12) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2C1A12);
    final subTextColor = isDark ? Colors.brown[200] : Colors.brown[400];

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF8B4513),
              onPressed: _showAddDialog,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B4513)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: TextStyle(color: textColor)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchProducts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF8B4513),
              onRefresh: _fetchProducts,
              child: _products.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada produk',
                        style: TextStyle(color: subTextColor),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(product: product),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    product['image'] ?? '',
                                    height: 130,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      height: 130,
                                      color: const Color(
                                        0xFF8B4513,
                                      ).withValues(alpha: 0.2),
                                      child: const Icon(
                                        Icons.coffee,
                                        color: Color(0xFF8B4513),
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? '-',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatPrice(product['price']),
                                        style: const TextStyle(
                                          color: Color(0xFF8B4513),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (_isAdmin) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => _showEditDialog(
                                                  Map.from(product),
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF8B4513,
                                                    ).withValues(alpha: 0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: Color(0xFF8B4513),
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => _confirmDelete(
                                                  Map.from(product),
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withValues(
                                                          alpha: 0.15,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
