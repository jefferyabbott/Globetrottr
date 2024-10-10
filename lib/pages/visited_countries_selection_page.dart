import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globetrottr_draft/components/selection_search_bar.dart';
import 'package:globetrottr_draft/pages/detail_page.dart';
import 'package:globetrottr_draft/providers/visited_countries_provider.dart';

import '../components/app_bar_title.dart';

class VisitedCountriesSelectionPage extends ConsumerStatefulWidget {
  final Map<String, String> flags;
  const VisitedCountriesSelectionPage({super.key, required this.flags});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VisitedCountriesSelectionPageState();
}

class _VisitedCountriesSelectionPageState
    extends ConsumerState<VisitedCountriesSelectionPage> {
  List<String>? _filteredNations;
  final searchController = TextEditingController();

  void _search(String searchText) {
    final nations = ref.read(visitedCountriesProvider);
    searchText = searchText.toLowerCase();
    setState(() {
      if (searchText == '') {
        _filteredNations = nations;
      } else {
        _filteredNations = nations
            .where((string) => string.toLowerCase().contains(searchText))
            .toList();
      }
    });
  }

  Future<void> _navigateToDetail(String commonName) async {
    searchController.clear();
    _search('');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(
          nationCommonName: commonName,
        ),
      ),
    );

    if (mounted) {
      _search('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nations = ref.watch(visitedCountriesProvider);

    // Initialize filtered nations if it hasn't been set yet
    _filteredNations ??= nations;

    // Ensure filtered nations only contains valid entries
    _filteredNations =
        _filteredNations!.where((nation) => nations.contains(nation)).toList();

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
              itemCount: _filteredNations!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor:
                      (index % 2 == 0) ? Colors.white : Colors.grey.shade100,
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${widget.flags[_filteredNations![index]]}  ${_filteredNations![index]}",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onTap: () => _navigateToDetail(_filteredNations![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
