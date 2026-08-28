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
      backgroundColor: const Color(0xFF33333D), // Premium solid dark background
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (context) => Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text("Book Options", style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ListTile(leading: const Icon(Icons.picture_as_pdf, color: Colors.white), title: const Text("Download as PDF", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _downloadPdf(books[index]); }),
          ListTile(leading: const Icon(Icons.edit, color: Colors.white), title: const Text("Edit Book Title", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _showAddEditDialog(index: index); }),
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
        backgroundColor: const Color(0xFF33333D), // Solid Dark Dialog
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(index == null ? "Create New Book" : "Edit Book Title", style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
              const SizedBox(height: 20),
              TextField(
                controller: _ctrl, 
                style: const TextStyle(color: Colors.white), 
                decoration: const InputDecoration(
                  hintText: "Enter Title", 
                  hintStyle: TextStyle(color: Colors.white54), 
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))), // Gold highlight
                )
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37), // Luxury Gold Button
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
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
                    child: Text(index == null ? "Create Book" : "Save Changes", style: const TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // YAHAN HAI LUXURY BOOK KA ASLI DESIGN
  Widget _buildLuxuryBookCard(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4E342E), Color(0xFF3E2723)], // Dark Leather Brown Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(4, 4))
        ],
        border: const Border(
          left: BorderSide(color: Color(0xFF1F100B), width: 14), // Moti Jild (Spine)
        ),
      ),
      child: Stack(
        children: [
          // Book Title
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8D5B5), // Elegant Gold/Off-white text
                  fontFamily: 'Georgia',
                  letterSpacing: 1.2,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black87, offset: Offset(1, 1))]
                ),
              ),
            ),
          ),
          // Subtle Gold Line design (like old books)
          Positioned(
            left: 10, top: 15, bottom: 15,
            child: Container(width: 1, color: Colors.white12),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark || Theme.of(context).scaffoldBackgroundColor == const Color(0xFF25252B);
    Color textColor = isDark ? const Color(0xFFE8D5B5) : Colors.brown[900]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Library', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 1.5)), 
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        foregroundColor: textColor,
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF25252B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1F100B)), // Dark Brown header
              child: const Text('App Settings', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
            ),
            ListTile(leading: const Icon(Icons.menu_book, color: Colors.white70), title: const Text('Premium Dark (Default)', style: TextStyle(color: Colors.white)), onTap: () => MyLibraryApp.of(context)?.changeTheme(0)),
            ListTile(leading: const Icon(Icons.dark_mode, color: Colors.white70), title: const Text('Pitch Black', style: TextStyle(color: Colors.white)), onTap: () => MyLibraryApp.of(context)?.changeTheme(1)),
            ListTile(leading: const Icon(Icons.wb_sunny, color: Colors.white70), title: const Text('Classic White', style: TextStyle(color: Colors.white)), onTap: () => MyLibraryApp.of(context)?.changeTheme(2)),
          ],
        ),
      ),
      body: books.isEmpty 
        ? Center(child: Text("Library is empty.\nTap + to create a book.", textAlign: TextAlign.center, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 18)))
        : GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: 25, 
              mainAxisSpacing: 25, 
              childAspectRatio: 0.70 // Lamba book shape
            ),
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
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("New Book", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD4AF37), // Luxury Gold FAB
        elevation: 6,
      ),
    );
  }
}
