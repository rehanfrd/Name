import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'data_manager.dart';
import 'main.dart';
import 'book_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> books = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    books = await DataManager.loadBooks();
    setState(() {});
  }

  void _saveBooks() async {
    await DataManager.saveBooks(books);
    setState(() {});
  }

  Future<void> _downloadPdf(Map<String, dynamic> book) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(book["title"], style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold))),
          ...book["pages"].map((page) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Text(page["title"], style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text("Meaning: ${page["meaning"]}", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text("Examples:", style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic)),
              ...page["examples"].map((ex) => pw.Bullet(text: ex, style: pw.TextStyle(fontSize: 14))),
            ]
          )).toList(),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: "${book['title']}.pdf");
  }

  void _showBookOptions(int index) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => _glassContainer(
        child: Wrap(
          children: [
            ListTile(leading: Icon(Icons.picture_as_pdf, color: Colors.white), title: Text("Download PDF", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _downloadPdf(books[index]); }),
            ListTile(leading: Icon(Icons.edit, color: Colors.white), title: Text("Edit Title", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _showAddEditDialog(index: index); }),
            ListTile(leading: Icon(Icons.delete, color: Colors.redAccent), title: Text("Delete Book", style: TextStyle(color: Colors.redAccent)), onTap: () { Navigator.pop(context); books.removeAt(index); _saveBooks(); }),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog({int? index}) {
    TextEditingController _ctrl = TextEditingController(text: index != null ? books[index]["title"] : "");
    showDialog(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Dialog(
        child: _glassContainer(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(index == null ? "Create New Book" : "Edit Book Title", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextField(controller: _ctrl, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Enter Title", hintStyle: TextStyle(color: Colors.white54), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)))),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: Colors.white70))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent.withOpacity(0.8)),
                      onPressed: () {
                        if (_ctrl.text.isEmpty) return;
                        if (index == null) {
                          books.insert(0, {"id": DateTime.now().toString(), "title": _ctrl.text, "pages": []});
                        } else {
                          books[index]["title"] = _ctrl.text;
                        }
                        _saveBooks();
                        Navigator.pop(context);
                      },
                      child: Text(index == null ? "Create" : "Save", style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.2))),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1E1E2C) : Color(0xFFF4ECD8),
      appBar: AppBar(title: Text('My Library', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: isDark ? Colors.white : Colors.brown[900]),
      body: GridView.builder(
        padding: EdgeInsets.all(15),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.75),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => BookViewScreen(bookIndex: index, books: books)));
              _loadData();
            },
            onLongPress: () => _showBookOptions(index),
            child: _glassContainer(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(books[index]["title"], textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 5, color: Colors.black54)])),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEditDialog,
        icon: Icon(Icons.add),
        label: Text("New Book"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.8),
      ),
    );
  }
}
