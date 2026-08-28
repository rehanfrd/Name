import 'package:flutter/material.dart';
import 'data_manager.dart';
import 'add_page.dart';

class BookViewScreen extends StatefulWidget {
  final int bookIndex;
  final List<Map<String, dynamic>> books;
  BookViewScreen({required this.bookIndex, required this.books});

  @override
  _BookViewScreenState createState() => _BookViewScreenState();
}

class _BookViewScreenState extends State<BookViewScreen> {
  late List<dynamic> pages;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    pages = widget.books[widget.bookIndex]["pages"];
  }

  void _showPageOptions(int pageIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.edit, color: Colors.blue),
            title: Text("Edit Page"),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPageScreen(bookIndex: widget.bookIndex, books: widget.books, editPageIndex: pageIndex)));
              setState(() { pages = widget.books[widget.bookIndex]["pages"]; });
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text("Delete Page"),
            onTap: () async {
              Navigator.pop(context);
              widget.books[widget.bookIndex]["pages"].removeAt(pageIndex);
              await DataManager.saveBooks(widget.books);
              setState(() { pages = widget.books[widget.bookIndex]["pages"]; });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1E1E2C) : Color(0xFFF4ECD8),
      appBar: AppBar(title: Text(widget.books[widget.bookIndex]["title"], style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: isDark ? Colors.white : Colors.brown[900]),
      body: pages.isEmpty
          ? Center(child: Text("This book is empty.\nTap + to add a page.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : Colors.black54)))
          : PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                return GestureDetector(
                  onLongPress: () => _showPageOptions(index),
                  child: Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(color: isDark ? Color(0xFF2C2C3E) : Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Text("(Long press anywhere to Edit/Delete)", style: TextStyle(fontSize: 12, color: Colors.grey))),
                          SizedBox(height: 10),
                          Text(page["title"], style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.brown[900])),
                          Divider(thickness: 2, height: 30),
                          Text("Meaning / Detail:", style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.brown[600])),
                          SizedBox(height: 5),
                          Text(page["meaning"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
                          SizedBox(height: 25),
                          Text("Examples:", style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.brown[600])),
                          SizedBox(height: 10),
                          ...List.generate(page["examples"].length, (exIndex) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                  Expanded(child: Text(page["examples"][exIndex], style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, height: 1.4, color: isDark ? Colors.white70 : Colors.black87))),
                                ],
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.8),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPageScreen(bookIndex: widget.bookIndex, books: widget.books)));
          setState(() { pages = widget.books[widget.bookIndex]["pages"]; });
        },
      ),
    );
  }
}
