import 'package:flutter/material.dart';

class SelectionSearchBar extends StatefulWidget {
  final void Function(String searchText) search;
  final TextEditingController searchController;

  const SelectionSearchBar(
      {super.key, required this.search, required this.searchController});

  @override
  State<SelectionSearchBar> createState() => _SelectionSearchBarState();
}

class _SelectionSearchBarState extends State<SelectionSearchBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.90,
      child: TextField(
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        controller: widget.searchController,
        onChanged: (value) => widget.search(value),
      ),
    );
  }
}
