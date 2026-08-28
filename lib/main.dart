import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  int savedTheme = prefs.getInt('theme_index') ?? 0;
  runApp(MyLibraryApp(initialTheme: savedTheme));
}

class MyLibraryApp extends StatefulWidget {
  final int initialTheme;
  MyLibraryApp({required this.initialTheme});

  static _MyLibraryAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyLibraryAppState>();

  @override
  _MyLibraryAppState createState() => _MyLibraryAppState();
}

class _MyLibraryAppState extends State<MyLibraryApp> {
  late int _themeIndex;

  final List<ThemeData> _themes = [
    // 0: Premium Dark
    ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFD4AF37),
      scaffoldBackgroundColor: const Color(0xFF25252B),
      cardColor: const Color(0xFF33333D),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF25252B), foregroundColor: Color(0xFFD4AF37), elevation: 0),
    ), 
    // 1: Pitch Black
    ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.black,
      cardColor: const Color(0xFF151515),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black, foregroundColor: Colors.white, elevation: 0),
    ),
    // 2: Classic Book
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.brown[900],
      scaffoldBackgroundColor: const Color(0xFFF4ECD8),
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(backgroundColor: const Color(0xFFF4ECD8), foregroundColor: Colors.brown[900], elevation: 0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _themeIndex = widget.initialTheme;
  }

  void changeTheme(int index) async {
    setState(() => _themeIndex = index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Library',
      debugShowCheckedModeBanner: false,
      theme: _themes[_themeIndex],
      home: HomeScreen(),
    );
  }
}
