import 'package:flutter/material.dart';
import 'data_manager.dart';

class AddPageScreen extends StatefulWidget {
  final int bookIndex;
  final List<Map<String, dynamic>> books;
  AddPageScreen({required this.bookIndex, required this.books});

  @override
  _AddPageScreenState createState() => _AddPageScreenState();
}

class _AddPageScreenState extends State<AddPageScreen> {
  final _titleController = TextEditingController();
  final _meaningController = TextEditingController();
  List<TextEditingController> _exampleControllers = [TextEditingController()]; 

  void _addExampleField() {
    setState(() { _exampleControllers.add(TextEditingController()); });
  }

  Future<void> _savePage() async {
    if (_titleController.text.isEmpty) return;

    List<String> examples = [];
    for (var controller in _exampleControllers) {
      if (controller.text.isNotEmpty) examples.add(controller.text);
    }

    widget.books[widget.bookIndex]["pages"].add({
      "title": _titleController.text,
      "meaning": _meaningController.text,
      "examples": examples,
    });

    await DataManager.saveBooks(widget.books);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color inputColor = isDark ? Colors.grey[800]! : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Page'),
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
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 55)),
              onPressed: _savePage,
              child: Text('Save Page', style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}
