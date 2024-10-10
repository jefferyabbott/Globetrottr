Map<String, List<String>> sortMapAlphabetically(
    Map<String, List<String>> inputMap) {
  // Create a new map to store the sorted result
  Map<String, List<String>> sortedMap =
      Map<String, List<String>>.fromEntries(inputMap.entries.toList()
        // Sort the entries based on their keys
        ..sort((a, b) => a.key.compareTo(b.key)));

  // Sort the values (List<String>) for each key
  sortedMap.forEach((key, value) {
    value.sort();
  });

  return sortedMap;
}
