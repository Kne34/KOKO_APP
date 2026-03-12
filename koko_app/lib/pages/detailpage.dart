import 'package:flutter/material.dart';
import 'package:koko_app/apis/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final Map product;
  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _reviews = [];
  bool _isLoadingReviews = false;
  String _username = '';
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _reviews.isEmpty) {
        _fetchReviews();
      }
    });
    _loadUsername();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _username = prefs.getString('username') ?? '');
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final (success, data) = await getReviews(widget.product['id']);
      if (!mounted) return;
      if (success) setState(() => _reviews = data);
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _submitReview() async {
    if (_commentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final (success, message) = await postReview(
        widget.product['id'],
        _rating,
        _commentCtrl.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        _commentCtrl.clear();
        setState(() => _rating = 5);
        await _fetchReviews();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        // pindah ke tab review list
        _tabController.animateTo(1);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatPrice(dynamic price) {
    final p = int.tryParse(price.toString()) ?? 0;
    final str = p.toString().split('').reversed.join();
    final result = RegExp(
      r'.{1,3}',
    ).allMatches(str).map((m) => m.group(0)).join('.');
    return 'Rp ${result.split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A0E0A) : const Color(0xFFFFF8F4);
    final cardColor = isDark ? const Color(0xFF2C1A12) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2C1A12);
    final subTextColor = isDark ? Colors.brown[200] : Colors.brown[400];
    final product = widget.product;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF2C1A12)
            : const Color(0xFF4B2C20),
        elevation: 0,
        title: Text(
          product['name'] ?? 'Detail Produk',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange[300],
          labelColor: Colors.orange[300],
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Detail'),
            Tab(text: 'Ulasan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailTab(isDark, cardColor, textColor, subTextColor, product),
          _buildReviewTab(isDark, cardColor, textColor, subTextColor),
        ],
      ),
    );
  }

  Widget _buildDetailTab(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
    Map product,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            product['image'] ?? '',
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 250,
              color: const Color(0xFF8B4513).withValues(alpha: 0.2),
              child: const Icon(
                Icons.coffee,
                color: Color(0xFF8B4513),
                size: 80,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product['name'] ?? '-',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B4513).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF8B4513).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        product['category'] ?? '-',
                        style: const TextStyle(
                          color: Color(0xFF8B4513),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatPrice(product['price']),
                  style: const TextStyle(
                    color: Color(0xFF8B4513),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: subTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stok: ${product['stock']}',
                      style: TextStyle(color: subTextColor, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product['description'] ?? '-',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tulis Ulasan',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sebagai $_username',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (i) {
                          return GestureDetector(
                            onTap: () => setState(() => _rating = i + 1),
                            child: Icon(
                              i < _rating ? Icons.star : Icons.star_border,
                              color: Colors.orange[400],
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _commentCtrl,
                        maxLines: 3,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText:
                              'Bagaimana pendapat kamu tentang produk ini?',
                          hintStyle: TextStyle(
                            color: subTextColor,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF3C2415)
                              : const Color(0xFFFFF0E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            _isSubmitting ? 'Mengirim...' : 'Kirim Ulasan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
  ) {
    if (_isLoadingReviews) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B4513)),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: subTextColor),
            const SizedBox(height: 12),
            Text(
              'Belum ada ulasan',
              style: TextStyle(color: subTextColor, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadilah yang pertama memberi ulasan!',
              style: TextStyle(color: subTextColor, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF8B4513),
      onRefresh: _fetchReviews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          final rating = review['rating'] as int? ?? 0;
          final isOwn = review['username'] == _username;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(
                        0xFF8B4513,
                      ).withValues(alpha: 0.15),
                      child: Text(
                        (review['username'] ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF8B4513),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review['username'] ?? '-',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: Colors.orange[400],
                          size: 16,
                        );
                      }),
                    ),
                    if (isOwn) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () async {
                          final (success, message) = await deleteReview(
                            widget.product['id'],
                            review['id'],
                          );
                          if (!mounted) return;
                          if (success) {
                            _fetchReviews();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Review dihapus'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          }
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  review['comment'] ?? '-',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  review['created_at']?.toString().substring(0, 10) ?? '',
                  style: TextStyle(color: subTextColor, fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
