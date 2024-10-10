import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefs = FutureProvider<SharedPreferences>(
    (_) async => await SharedPreferences.getInstance());

class VisitedCountriesNotifier extends StateNotifier<List<String>> {
  VisitedCountriesNotifier(this.pref)
      : super(pref?.getStringList("visitedCountries") ?? []);

  final SharedPreferences? pref;

  bool toggleVisitedCountry(String country) {
    if (state.contains(country)) {
      state = state.where((c) => c != country).toList();
      pref!.setStringList("visitedCountries", state);
      return false;
    } else {
      state = [...state, country];
      state.sort();
      pref!.setStringList("visitedCountries", state);
      return true;
    }
  }
}

final visitedCountriesProvider =
    StateNotifierProvider<VisitedCountriesNotifier, List<String>>((ref) {
  final pref = ref.watch(sharedPrefs).maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );
  return VisitedCountriesNotifier(pref);
});
