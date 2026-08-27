import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static const String _key = 'my_library_books';

  static Future<List<Map<String, dynamic>>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    
    if (data == null) {
      List<Map<String, dynamic>> defaultBook = [_defaultTenseBook()];
      await saveBooks(defaultBook);
      return defaultBook;
    }
    return List<Map<String, dynamic>>.from(json.decode(data));
  }

  static Future<void> saveBooks(List<Map<String, dynamic>> books) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(books));
  }

  static Map<String, dynamic> _defaultTenseBook() {
    return {
      "id": "book_1",
      "title": "Tense Mastery (Grammar)",
      "pages": [
        {
          "title": "Present Simple",
          "meaning": "Aadatein (Habits), Sach (Facts) batane ke liye.",
          "examples": ["He goes to school.", "Does he go to school?"]
        }
      ]
    };
  }
}
