import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sohba/service/local_service.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<UserDataService>(UserDataService(prefs));
}
