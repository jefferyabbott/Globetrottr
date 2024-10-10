import 'package:flutter/material.dart';
import 'package:globetrottr_draft/pages/selection_page.dart';

import '../components/app_bar_title.dart';
import '../components/selection_search_bar.dart';

class LanguagesPage extends StatefulWidget {
  final Map<String, List<String>> languages;
  final Map<String, String> flags;
  const LanguagesPage(
      {super.key, required this.languages, required this.flags});

  @override
  State<LanguagesPage> createState() => _LanguagesPageState();
}

class _LanguagesPageState extends State<LanguagesPage> {
  late List<String> _filteredLanguages = widget.languages.keys.toList();
  final searchController = TextEditingController();

  void _search(String searchText) {
    searchText = searchText.toLowerCase();
    setState(() {
      if (searchText == '') {
        _filteredLanguages = widget.languages.keys.toList();
      } else {
        _filteredLanguages = widget.languages.keys
            .toList()
            .where((string) => string.toLowerCase().contains(searchText))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey.shade300,
        title: const AppBarTitle(),
      ),
      body: Column(
        children: [
          SelectionSearchBar(
            search: _search,
            searchController: searchController,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _filteredLanguages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor:
                      (index % 2 == 0) ? Colors.white : Colors.grey.shade100,
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _filteredLanguages[index],
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onTap: () {
                    final language =
                        widget.languages[_filteredLanguages[index]]!;
                    searchController.clear();
                    _search('');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectionPage(
                          nations: language,
                          flags: widget.flags,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
