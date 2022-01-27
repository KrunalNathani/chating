import 'dart:convert';

import 'package:http/http.dart' as http;

Future sendNotification(String body, String title, String token) async {
  String baseUrl = 'https://fcm.googleapis.com/fcm/send';
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAALsqCRfs:APA91bH--BZcndci-ZnenJpxOGd32BvwMGtQdET3aTDn1WYd4lifNAl7XCobFgcconbkw3Y9qjnyo7WN7cyXU9imWF23xO79Un7EC7FPnDpCI0-3VJfVJX6pnoIAWP1BssaRSqScsbr6',
    },
    body: jsonEncode({
      "notification": {
        "body": body,
        "title": title,
        "image":
            "https://images.idgesg.net/images/article/2017/08/lock_circuit_board_bullet_hole_computer_security_breach_thinkstock_473158924_3x2-100732430-large.jpg"
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "open_val": "B",
        "image":
            "https://images.idgesg.net/images/article/2017/08/lock_circuit_board_bullet_hole_computer_security_breach_thinkstock_473158924_3x2-100732430-large.jpg"
      },
      "registration_ids": ["eqXfnDHjQ1KZdZF1ficQDU:APA91bFsmNhr0QbI6QemF3mogckeBujTvXT7uZXSLwexWWf9TRBOFy1pqpiVlAf3T7Csk6-ZbpZ7-NTj4OL3bFhfEKfUAzaxxIGYI0q_WzT0fyoa7ZVuM0iNNFKzDmjLS2Stj0zEZDtz"]
    }),
  );
  print('Status code : ${response.statusCode}');
  print('Body : ${response.body}');
  if (response.statusCode == 200 || response.statusCode == 201) {
    var message = jsonDecode(response.body);
    return message;
  } else {
    print('Status code : ${response.statusCode}');
  }
}
