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
  int _currentPage = 0;
  String _searchQuery = "";
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    pages = widget.books[widget.bookIndex]["pages"];
  }

  void _showPageOptions(int pageIndex, Map<String, dynamic> actualPage) {
    int realIndex = pages.indexOf(actualPage);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            title: const Text("Edit Page"),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPageScreen(bookIndex: widget.bookIndex, books: widget.books, editPageIndex: realIndex)));
              setState(() { pages = widget.books[widget.bookIndex]["pages"]; });
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete Page", style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              widget.books[widget.bookIndex]["pages"].removeAt(realIndex);
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
    List<dynamic> filteredPages = _searchQuery.isEmpty 
        ? pages 
        : pages.where((p) => p["title"].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? TextField(
                autofocus: true,
                style: TextStyle(color: Theme.of(context).primaryColor),
                decoration: const InputDecoration(hintText: "Search page title...", border: InputBorder.none),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Text(widget.books[widget.bookIndex]["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search), 
            onPressed: () => setState(() { _isSearching = !_isSearching; _searchQuery = ""; }),
          )
        ],
      ),
      body: filteredPages.isEmpty
          ? const Center(child: Text("No pages found.\nTap + to add.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)))
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: filteredPages.length,
                    itemBuilder: (context, index) {
                      final page = filteredPages[index];
                      return GestureDetector(
                        onLongPress: () => _showPageOptions(index, page),
                        child: Container(
                          margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)],
                            border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 8)), 
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Center(child: Text("(Long press anywhere to Edit/Delete)", style: TextStyle(fontSize: 12, color: Colors.grey))),
                                  const SizedBox(height: 10),
                                  Text(page["title"], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                  const Divider(thickness: 2, height: 30),
                                  const Text("Meaning / Detail:", style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  const SizedBox(height: 5),
                                  Text(page["meaning"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 25),
                                  const Text("Examples:", style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  const SizedBox(height: 10),
                                  ...List.generate(page["examples"].length, (exIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 15),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          Expanded(child: Text(page["examples"][exIndex], style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, height: 1.4))),
                                        ],
                                      ),
                                    );
                                  })
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // PAGE SWITCH BUTTONS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).cardColor, foregroundColor: Theme.of(context).primaryColor),
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        label: const Text("Prev"),
                        onPressed: _currentPage > 0 ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
                      ),
                      Text("Page ${_currentPage + 1} of ${filteredPages.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).cardColor, foregroundColor: Theme.of(context).primaryColor),
                        onPressed: _currentPage < filteredPages.length - 1 ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
                        child: Row(children: const [Text("Next "), Icon(Icons.arrow_forward_ios, size: 16)]),
                      ),
                    ],
                  ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Theme.of(context).scaffoldBackgroundColor),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPageScreen(bookIndex: widget.bookIndex, books: widget.books)));
          setState(() { pages = widget.books[widget.bookIndex]["pages"]; _searchQuery = ""; _isSearching = false; });
        },
      ),
    );
  }
}
