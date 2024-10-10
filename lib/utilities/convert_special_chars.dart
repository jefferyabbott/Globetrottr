import 'dart:convert';

String convertSpecialChars(String word) {
  final codeUnits = word.codeUnits;
  return const Utf8Decoder().convert(codeUnits);
}
