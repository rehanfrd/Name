import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'data_manager.dart';

class AddPageScreen extends StatefulWidget {
  final int bookIndex;
  final List<Map<String, dynamic>> books;
  final int? editPageIndex;
  
  AddPageScreen({required this.bookIndex, required this.books, this.editPageIndex});

  @override
  _AddPageScreenState createState() => _AddPageScreenState();
}

class _AddPageScreenState extends State<AddPageScreen> {
  final _titleController = TextEditingController();
  late QuillController _quillController;

  @override
  void initState() {
    super.initState();
    
    if (widget.editPageIndex != null) {
      final page = widget.books[widget.bookIndex]["pages"][widget.editPageIndex!];
      _titleController.text = page["title"] ?? "";
      
      if (page.containsKey("contentJson")) {
        // Naya Word jaisa data load karna
        final doc = Document.fromJson(jsonDecode(page["contentJson"]));
        _quillController = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
      } else {
        // Purane data ko naye editor mein convert karna (Taki edit ho sake)
        String oldContent = "${page['meaning'] ?? ''}\n\nExamples:\n";
        if (page['examples'] != null) {
          for (var ex in page['examples']) {
            oldContent += "• $ex\n";
          }
        }
        final doc = Document()..insert(0, oldContent);
        _quillController = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
      }
    } else {
      _quillController = QuillController.basic();
    }
  }

  Future<void> _savePage() async {
    if (_titleController.text.isEmpty) return;

    // Word jaisa data JSON mein save hoga
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    final newPage = {
      "title": _titleController.text,
      "contentJson": contentJson, 
    };

    if (widget.editPageIndex == null) {
      widget.books[widget.bookIndex]["pages"].add(newPage);
    } else {
      widget.books[widget.bookIndex]["pages"][widget.editPageIndex!] = newPage;
    }

    await DataManager.saveBooks(widget.books);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editPageIndex == null ? 'Add New Page' : 'Edit Page'),
        actions: [
          IconButton(icon: const Icon(Icons.check, size: 30), onPressed: _savePage)
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: _titleController, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Page Title (e.g., Tense Name)', 
                filled: true, 
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)
              )
            ),
          ),
          
          // MS Word jaisa Toolbar
          Container(
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: QuillToolbar.basic(
                controller: _quillController,
                showFontFamily: false,
                showSearchButton: false,
                showIndent: false,
              ),
            ),
          ),
          
          const Divider(height: 1, thickness: 2),
          
          // Typing Area
          Expanded(
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(15),
              child: QuillEditor.basic(
                controller: _quillController, 
                readOnly: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
