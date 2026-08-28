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
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (context) => Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text("Book Options", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ListTile(leading: Icon(Icons.picture_as_pdf, color: Theme.of(context).primaryColor), title: Text("Download PDF"), onTap: () { Navigator.pop(context); _downloadPdf(books[index]); }),
          ListTile(leading: Icon(Icons.edit, color: Theme.of(context).primaryColor), title: Text("Edit Title"), onTap: () { Navigator.pop(context); _showAddEditDialog(index: index); }),
          ListTile(leading: const Icon(Icons.delete, color: Colors.redAccent), title: const Text("Delete Book", style: TextStyle(color: Colors.redAccent)), onTap: () { Navigator.pop(context); books.removeAt(index); _saveBooks(); }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAddEditDialog({int? index}) {
    TextEditingController _ctrl = TextEditingController(text: index != null ? books[index]["title"] : "");
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(index == null ? "Create New Book" : "Edit Book Title", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _ctrl, 
                decoration: InputDecoration(
                  hintText: "Enter Title", 
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                )
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
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
                    child: Text(index == null ? "Create Book" : "Save", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryBookCard(String title) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12), topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(3, 3))],
        border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 14)), 
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Library', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Georgia')), centerTitle: true),
      drawer: Drawer(
        backgroundColor: Theme.of(context).cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text('App Settings', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListTile(leading: const Icon(Icons.menu_book), title: const Text('Premium Dark (Default)'), onTap: () => MyLibraryApp.of(context)?.changeTheme(0)),
            ListTile(leading: const Icon(Icons.dark_mode), title: const Text('Pitch Black'), onTap: () => MyLibraryApp.of(context)?.changeTheme(1)),
            ListTile(leading: const Icon(Icons.wb_sunny), title: const Text('Classic White'), onTap: () => MyLibraryApp.of(context)?.changeTheme(2)),
          ],
        ),
      ),
      body: books.isEmpty 
        ? const Center(child: Text("Library is empty.\nTap + to create a book.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)))
        : GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 25, mainAxisSpacing: 25, childAspectRatio: 0.70),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => BookViewScreen(bookIndex: index, books: books)));
                  _loadData();
                },
                onLongPress: () => _showBookOptions(index),
                child: _buildLuxuryBookCard(books[index]["title"]),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEditDialog,
        icon: Icon(Icons.add, color: Theme.of(context).scaffoldBackgroundColor),
        label: Text("New Book", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
