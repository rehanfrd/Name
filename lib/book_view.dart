import 'package:flutter/material.dart';
import 'add_page.dart';
import 'data_manager.dart';

class BookViewScreen extends StatefulWidget {
  final int bookIndex;
  final List<Map<String, dynamic>> books;
  BookViewScreen({required this.bookIndex, required this.books});

  @override
  _BookViewScreenState createState() => _BookViewScreenState();
}

class _BookViewScreenState extends State<BookViewScreen> {
  late List<dynamic> pages;

  @override
  void initState() {
    super.initState();
    pages = widget.books[widget.bookIndex]["pages"];
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.books[widget.bookIndex]["title"], style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.brown[900],
      ),
      body: pages.isEmpty
          ? Center(child: Text("This book is empty.\nTap + to add a page.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)))
          : PageView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(page["title"], style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.brown[900])),
                        Divider(thickness: 2, height: 30),
                        Text("Meaning / Detail:", style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.brown[600])),
                        SizedBox(height: 5),
                        Text(page["meaning"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        SizedBox(height: 25),
                        Text("Examples:", style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.brown[600])),
                        SizedBox(height: 10),
                        ...List.generate(page["examples"].length, (exIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Expanded(child: Text(page["examples"][exIndex], style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, height: 1.4))),
                              ],
                            ),
                          );
                        })
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: isDark ? Colors.blueGrey : Colors.brown[800],
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPageScreen(
            bookIndex: widget.bookIndex,
            books: widget.books,
          )));
          setState(() { pages = widget.books[widget.bookIndex]["pages"]; });
        },
      ),
    );
  }
}
