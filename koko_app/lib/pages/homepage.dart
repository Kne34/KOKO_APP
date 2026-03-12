import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:koko_app/pages/itempage.dart';
import 'package:koko_app/pages/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:koko_app/apis/api.dart';

class HomePage extends StatefulWidget {
  final Function(bool) koTheme;

  const HomePage({super.key, required this.koTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  final List<Map<String, String>> _carouselItems = [
    {
      'image':
          'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800',
      'title': 'Premium Arabica',
      'subtitle': 'Single Origin from Flores',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
      'title': 'Promo Bulan Ini',
      'subtitle': 'Buy 2 Get 1 Free - All Espresso',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
      'title': 'Coffee Tasting Event',
      'subtitle': 'Sabtu, 15 Maret 2025 - Pukul 10.00',
    },
  ];

  final List<Map<String, dynamic>> _infographics = [
    {'icon': Icons.coffee, 'value': '20+', 'label': 'Varian Kopi'},
    {'icon': Icons.location_on, 'value': '5', 'label': 'Cabang'},
    {'icon': Icons.star, 'value': '4.9', 'label': 'Rating'},
    {'icon': Icons.people, 'value': '10K+', 'label': 'Member'},
  ];

  Future<void> _logout() async {
    try {
      await logout();
    } finally {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage(koTheme: widget.koTheme)),
        );
      }
    }
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
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF2C1A12)
            : const Color(0xFF4B2C20),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $_username',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Komunitas Kopi',
              style: TextStyle(color: Colors.brown, fontSize: 12),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: isDark ? const Color(0xFF3C2415) : Colors.white,
            onSelected: (value) {
              if (value == 'toggle_theme') {
                widget.koTheme(!isDark);
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_theme',
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.yellow : Colors.brown,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDark ? 'Light Mode' : 'Dark Mode',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        backgroundColor: isDark
            ? const Color(0xFF2C1A12)
            : const Color(0xFF4B2C20),
        selectedItemColor: Colors.orange[300],
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeBody(isDark, cardColor, textColor, subTextColor),
          const ItemPage(),
          const Center(child: Text('Favorit')),
          const Center(child: Text('Profil')),
        ],
      ),
    );
  }

  Widget _buildHomeBody(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          CarouselSlider(
            items: _carouselItems.map((item) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item['image']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF8B4513),
                        child: const Icon(
                          Icons.coffee,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item['subtitle']!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayInterval: const Duration(seconds: 3),
              viewportFraction: 0.92,
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tentang Kami',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: _infographics.length,
              itemBuilder: (context, index) {
                final item = _infographics[index];
                return Container(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF8B4513,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: const Color(0xFF8B4513),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['value'] as String,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
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

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
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
                    'Komunitas Kopi',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kami adalah komunitas pecinta kopi yang berdedikasi '
                    'menghadirkan pengalaman kopi terbaik dari seluruh penjuru '
                    'Nusantara. Dari biji kopi pilihan hingga racikan barista '
                    'berpengalaman, setiap tegukan adalah sebuah perjalanan rasa.',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
