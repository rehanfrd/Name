import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static const String _key = 'my_library_books';

  static Future<List<Map<String, dynamic>>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    
    if (data == null) {
      // Pehli baar khulne par Default Tense Book
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
          "title": "Present Simple Tense",
          "meaning": "Aadatein (Habits), Sach (Facts) aur Routine batane ke liye.",
          "examples": [
            "Affirmative: Sub + V1 (s/es) + Obj -> He goes to school.",
            "Negative: Sub + do/does + not + V1 + Obj -> He does not go to school.",
            "Interrogative: Do/Does + Sub + V1 + Obj? -> Does he go to school?"
          ]
        },
        {
          "title": "Present Continuous Tense",
          "meaning": "Jo kaam abhi is waqt ho raha hai.",
          "examples": [
            "Affirmative: Sub + is/am/are + V4(ing) + Obj -> I am playing.",
            "Negative: Sub + is/am/are + not + V4(ing) + Obj -> I am not playing.",
            "Interrogative: Is/Am/Are + Sub + V4(ing) + Obj? -> Am I playing?"
          ]
        },
        {
          "title": "Past Simple Tense",
          "meaning": "Jo kaam beete hue kal me poora ho gaya.",
          "examples": [
            "Affirmative: Sub + V2 + Obj -> I played cricket.",
            "Negative: Sub + did + not + V1 + Obj -> I did not play cricket.",
            "Interrogative: Did + Sub + V1 + Obj? -> Did I play cricket?"
          ]
        }
      ]
    };
  }
}
