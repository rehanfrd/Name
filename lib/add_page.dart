import 'package:flutter/material.dart';
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
  final _meaningController = TextEditingController();
  List<TextEditingController> _exampleControllers = [TextEditingController()]; 

  @override
  void initState() {
    super.initState();
    if (widget.editPageIndex != null) {
      final page = widget.books[widget.bookIndex]["pages"][widget.editPageIndex!];
      _titleController.text = page["title"];
      _meaningController.text = page["meaning"];
      _exampleControllers = (page["examples"] as List).map((ex) => TextEditingController(text: ex)).toList();
      if (_exampleControllers.isEmpty) _exampleControllers.add(TextEditingController());
    }
  }

  void _addExampleField() {
    setState(() { _exampleControllers.add(TextEditingController()); });
  }

  Future<void> _savePage() async {
    if (_titleController.text.isEmpty) return;

    List<String> examples = [];
    for (var controller in _exampleControllers) {
      if (controller.text.isNotEmpty) examples.add(controller.text);
    }

    final newPage = {
      "title": _titleController.text,
      "meaning": _meaningController.text,
      "examples": examples,
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color inputColor = isDark ? Colors.grey[800]! : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1E1E2C) : Color(0xFFF4ECD8),
      appBar: AppBar(
        title: Text(widget.editPageIndex == null ? 'Add New Page' : 'Edit Page'),
        actions: [IconButton(icon: Icon(Icons.check, size: 30), onPressed: _savePage)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title / Word / Rule', filled: true, fillColor: inputColor)),
            SizedBox(height: 15),
            TextField(controller: _meaningController, maxLines: 2, decoration: InputDecoration(labelText: 'Meaning / Explanation', filled: true, fillColor: inputColor)),
            SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft, child: Text("Examples:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(height: 10),
            ...List.generate(_exampleControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _exampleControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Example ${index + 1}',
                    filled: true, fillColor: inputColor,
                    suffixIcon: index == _exampleControllers.length - 1
                        ? IconButton(icon: Icon(Icons.add_circle, color: Colors.blue), onPressed: _addExampleField)
                        : null,
                  ),
                ),
              );
            }),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 55), backgroundColor: Colors.deepPurpleAccent),
              onPressed: _savePage,
              child: Text('Save Page', style: TextStyle(fontSize: 18, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
