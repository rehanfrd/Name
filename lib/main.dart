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

  // Themes list
  final List<ThemeData> _themes = [
    // 0: Halka Dark (Premium Luxury Theme - Default now)
    ThemeData(
      primarySwatch: Colors.brown,
      scaffoldBackgroundColor: const Color(0xFF25252B), // Halka Dark Charcoal
      fontFamily: 'Georgia',
    ), 
    // 1: Pitch Black (Dark Mode)
    ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
    ),
    // 2: Classic White
    ThemeData(
      primarySwatch: Colors.blueGrey,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Georgia',
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
