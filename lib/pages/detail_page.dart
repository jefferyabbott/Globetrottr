import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:globetrottr_draft/providers/visited_countries_provider.dart';
import 'package:globetrottr_draft/utilities/convert_special_chars.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../components/app_bar_title.dart';
import '../components/nation_map.dart';

class DetailPage extends ConsumerStatefulWidget {
  final String nationCommonName;
  const DetailPage({super.key, required this.nationCommonName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  Map<String, dynamic> nationDetailData = <String, dynamic>{};
  var formatter = NumberFormat('###,###,000');
  String officialName = '';
  String commonName = '';
  String capital = '';
  String currencies = '';
  String languages = '';
  String flagDescription = '';
  double zoom = 5.0;
  var _isLoading = true;

  Future getNationDetails(String commonName) async {
    const baseUrl = "https://restcountries.com/v3.1";
    const fields =
        "?fields=name,currencies,capital,languages,latlng,maps,flags,coatOfArms,population,area";
    final String url = "$baseUrl/name/$commonName$fields";
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(convertSpecialChars(response.body));
        for (final country in data) {
          if (country['name']['common'] == commonName) {
            return country;
          }
        }
        return data;
      } else {
        if (kDebugMode) {
          print(
              "Status code received while fetching data: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void getNationDetailData() async {
    setState(() {
      _isLoading = true;
    });
    final data = await getNationDetails(widget.nationCommonName);
    setState(() {
      nationDetailData = data;
      commonName = widget.nationCommonName;

      // official name
      officialName = nationDetailData['name']['official'] ?? '';

      // capital city
      if (nationDetailData.containsKey('capital')) {
        if (nationDetailData['capital'].length > 0) {
          capital = nationDetailData['capital'][0];
        }
      }

      // currencies
      if (nationDetailData.containsKey('currencies')) {
        List<String> currenciesStrList = [];
        Map currencyData = nationDetailData['currencies'];
        currencyData.forEach((key, value) {
          currenciesStrList.add("$key (${value['symbol']})");
        });

        currencies = currenciesStrList.join(", ");
      }

      // languages
      if (nationDetailData.containsKey('languages')) {
        List<String> languagesList = [];
        Map languageData = nationDetailData['languages'];
        languageData.forEach((key, value) {
          languagesList.add(value);
        });

        languages = languagesList.join(', ');
      }

      // flag description
      if (nationDetailData['flags']['alt'] != null) {
        flagDescription = nationDetailData['flags']['alt'];
      }

      // print(nationDetailData['area']);
      final area = nationDetailData['area'];
      if (area > 10000000) {
        zoom = 0.6;
      } else if (area > 5000000) {
        zoom = 2.2;
      } else if (area > 2000000) {
        zoom = 3.0;
      } else if (area > 1000000) {
        zoom = 4.0;
      } else if (area > 500000) {
        zoom = 5.0;
      } else if (area > 100000) {
        zoom = 6.0;
      } else if (area < 10000) {
        zoom = 12.0;
      }

      _isLoading = false;
    });
  }

  @override
  void initState() {
    getNationDetailData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final visitedCountries = ref.watch(visitedCountriesProvider);
    final visited = visitedCountries.contains(commonName);
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        centerTitle: true,
        title: const AppBarTitle(),
        actions: [
          IconButton(
            onPressed: () {
              final wasAdded = ref
                  .read(visitedCountriesProvider.notifier)
                  .toggleVisitedCountry(commonName);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(wasAdded
                      ? '$commonName added to the visited countries list'
                      : '$commonName removed from the visited countries list'),
                ),
              );
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                  child: child,
                );
              },
              child: Icon(
                visited ? Icons.flag_circle_sharp : Icons.flag_circle_outlined,
                color: visited ? Colors.deepOrange : Colors.grey,
                key: ValueKey(visited),
                semanticLabel: visited
                    ? "Tap here to remove $commonName from the visited countries list."
                    : "Tap here to add $commonName to the visited countries list.",
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const SpinKitRotatingPlain(
              color: Colors.black,
              size: 100.0,
            )
          : nationDetailData.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CachedNetworkImage(
                              imageUrl: nationDetailData['flags']['png'],
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              imageBuilder: (context, imageProvider) =>
                                  Semantics(
                                label: flagDescription,
                                child: Image(
                                  image: imageProvider,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            officialName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Center(
                          child: (commonName != officialName)
                              ? Text(
                                  "($commonName)",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const Divider(
                          color: Colors.grey,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // nation details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: (capital != ""),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        capital,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.people,
                                        color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      formatter.format(
                                          nationDetailData['population']),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Visibility(
                                  visible: (currencies.isNotEmpty),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.money,
                                          color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        currencies,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Visibility(
                                  visible: (languages.isNotEmpty),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.language,
                                          color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Wrap(children: [
                                        SizedBox(
                                          width: 160,
                                          child: Text(
                                            languages,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            (nationDetailData['coatOfArms']['png'] != null)
                                ? CachedNetworkImage(
                                    imageUrl: nationDetailData['coatOfArms']
                                        ['png'],
                                    height: 90,
                                    width: 100,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    imageBuilder: (context, imageProvider) =>
                                        Semantics(
                                      label: "Coat of Arms for $commonName",
                                      child: Image(
                                        image: imageProvider,
                                      ),
                                    ),
                                  )
                                : const SizedBox(height: 90, width: 100),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 300,
                          child: NationMap(
                            lat: nationDetailData['latlng'][0],
                            lon: nationDetailData['latlng'][1],
                            zoom: zoom,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
    );
  }
}
