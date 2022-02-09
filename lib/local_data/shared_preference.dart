import 'package:chating/constants/string_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

setLoginPrefData(String? userid)async{
  final prefs = await SharedPreferences.getInstance();
  print("prefs ${prefs}");  print("userid11 ${userid}");
  await prefs.setString('LoginUID', userid!);
  print("prefs.setString ${prefs.setString('LoginUID', userid)}");
}

Future<String?> getLoginPrefData()async{
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('LoginUID');
}

removePrefData()async{
  final prefs = await SharedPreferences.getInstance();
 return await prefs.remove('${loginUID}');

}