import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:globetrottr_draft/components/bottom_nav_bar.dart';
import 'package:globetrottr_draft/pages/languages_page.dart';
import 'package:globetrottr_draft/pages/selection_page.dart';
import 'package:globetrottr_draft/pages/visited_countries_selection_page.dart';
import 'package:globetrottr_draft/utilities/convert_special_chars.dart';
import 'package:http/http.dart' as http;
import '../utilities/sort_map_alphabetically.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<String> countries = [];
  Map<String, String> flags = {};

  var _isLoading = true;

  Map<String, List<String>> languages = {};

  int _selectedIndex = 0;

  @override
  void initState() {
    // load all countries and languages
    getNationData();
    super.initState();
  }

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void getNationData() async {
    const String url =
        "https://restcountries.com/v3.1/all?fields=name,languages,flag";
    try {
      // start spinner
      setState(() {
        _isLoading = true;
      });
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(convertSpecialChars(response.body));
        setState(() {
          for (final country in data) {
            final String name = (country['name']['common']);
            countries.add(name);
            flags[name] = country['flag'];

            if (country.containsKey('languages')) {
              Map languageMap = country['languages'];
              languageMap.forEach((key, value) {
                if (languages.containsKey(value)) {
                  languages[value]?.add(name);
                } else {
                  languages[value] = [name];
                }
              });
            }

            // sort the data
            countries.sort();
            languages = sortMapAlphabetically(languages);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    // stop spinner
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var pageList = [
      SelectionPage(
          nations: countries, flags: flags, key: ValueKey(_selectedIndex)),
      VisitedCountriesSelectionPage(
          flags: flags, key: ValueKey(_selectedIndex)),
      LanguagesPage(
          languages: languages, flags: flags, key: ValueKey(_selectedIndex)),
    ];
    return Scaffold(
      body: _isLoading
          ? const SpinKitRotatingPlain(
              color: Colors.black,
              size: 100.0,
            )
          : pageList.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
    );
  }
}
