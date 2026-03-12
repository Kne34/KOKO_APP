import 'package:flutter/material.dart';
import 'package:koko_app/apis/api.dart';
import 'package:koko_app/pages/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themes = prefs.getString('theme') ?? 'light';
    setState(() {
      _themeMode = (themes == 'dark') ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    updateTheme(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KOKO (KOmunitas KOpi)',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      themeMode: _themeMode,
      routes: {'/login': (context) => LoginPage(koTheme: toggleTheme)},
      home: LoginPage(koTheme: toggleTheme),
    );
  }
}
