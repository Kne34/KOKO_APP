import 'package:flutter/material.dart';
import 'package:koko_app/apis/api.dart';
import 'package:koko_app/pages/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString('theme') ?? 'light';
  runApp(MyApp(savedTheme: theme));
}

class MyApp extends StatefulWidget {
  final String savedTheme;
  const MyApp({super.key, required this.savedTheme});

  // This widget is the root of your application.
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
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
