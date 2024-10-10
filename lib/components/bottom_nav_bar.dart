import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final void Function(int)? onTabChange;

  const BottomNavBar({super.key, required this.onTabChange});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onTabChange!(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedFontSize: 0,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Semantics(
            label: "List all nations",
            child: const Icon(Icons.list, size: 30),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Semantics(
            label: "List visited nations",
            child: const Icon(Icons.flag, size: 30),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Semantics(
            label: "List official languages",
            child: const Icon(Icons.language, size: 30),
          ),
          label: '',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey.shade500,
      backgroundColor: Colors.grey.shade300,
      elevation: 10,
      onTap: _onItemTapped,
    );
  }
}
