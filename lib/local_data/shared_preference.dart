import 'package:shared_preferences/shared_preferences.dart';

LoginUIDData(String? userid)async{
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('LoginUID', userid!);
  print("prefs.setString ${prefs.setString('LoginUID', userid)}");
}