import 'package:flutter/material.dart';
import 'package:globetrottr_draft/components/app_bar_title.dart';
import 'package:globetrottr_draft/components/selection_search_bar.dart';
import 'package:globetrottr_draft/pages/detail_page.dart';

class SelectionPage extends StatefulWidget {
  final List<String> nations;
  final Map<String, String> flags;
  const SelectionPage({super.key, required this.nations, required this.flags});

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  late List<String> _filteredNations = widget.nations;
  final searchController = TextEditingController();

  void _search(String searchText) {
    searchText = searchText.toLowerCase();
    setState(() {
      if (searchText == '') {
        _filteredNations = widget.nations;
      } else {
        _filteredNations = widget.nations
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
              itemCount: _filteredNations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor:
                      (index % 2 == 0) ? Colors.white : Colors.grey.shade100,
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${widget.flags[_filteredNations[index]]}  ${_filteredNations[index]}",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onTap: () {
                    final commonName = _filteredNations[index];
                    searchController.clear();
                    _search('');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          nationCommonName: commonName,
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
