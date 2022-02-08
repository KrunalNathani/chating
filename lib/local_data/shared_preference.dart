import 'package:shared_preferences/shared_preferences.dart';

loginUIDData(String? userid)async{
  final prefs = await SharedPreferences.getInstance();
  print("prefs ${prefs}");  print("userid11 ${userid}");
  await prefs.setString('LoginUID', userid!);
  print("prefs.setString ${prefs.setString('LoginUID', userid)}");
}