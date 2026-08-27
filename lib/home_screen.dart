import 'package:flutter/material.dart';
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

  void _createNewBook(String title) async {
    if (title.isEmpty) return;
    books.insert(0, {"id": DateTime.now().toString(), "title": title, "pages": []});
    await DataManager.saveBooks(books);
    setState(() {});
  }

  void _showAddBookDialog() {
    TextEditingController _bookController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create a New Book"),
        content: TextField(controller: _bookController, decoration: InputDecoration(hintText: "Enter Book Title (e.g., Vocabulary)")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _createNewBook(_bookController.text);
              Navigator.pop(context);
            },
            child: Text("Create"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Library', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.brown[900],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.brown[700]),
              child: Text('Settings & Themes', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(leading: Icon(Icons.menu_book), title: Text('Eye Comfort (Sepia)'), onTap: () => MyLibraryApp.of(context)?.changeTheme(0)),
            ListTile(leading: Icon(Icons.dark_mode), title: Text('Dark Mode'), onTap: () => MyLibraryApp.of(context)?.changeTheme(1)),
            ListTile(leading: Icon(Icons.wb_sunny), title: Text('Classic White'), onTap: () => MyLibraryApp.of(context)?.changeTheme(2)),
            ListTile(leading: Icon(Icons.eco), title: Text('Mint Green'), onTap: () => MyLibraryApp.of(context)?.changeTheme(3)),
          ],
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(15),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.75),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => BookViewScreen(bookIndex: index, books: books)));
              _loadData(); // Refresh on back
            },
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.brown[600],
                borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15), topLeft: Radius.circular(3), bottomLeft: Radius.circular(3)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(3, 3))],
                border: Border(left: BorderSide(color: isDark ? Colors.black : Colors.brown[900]!, width: 10)),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(books[index]["title"], textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBookDialog,
        icon: Icon(Icons.add),
        label: Text("New Book"),
        backgroundColor: isDark ? Colors.blueGrey : Colors.brown[800],
      ),
    );
  }
}
