import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globetrottr_draft/pages/home_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: Globetrottr(),
    ),
  );
}

class Globetrottr extends StatelessWidget {
  const Globetrottr({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
