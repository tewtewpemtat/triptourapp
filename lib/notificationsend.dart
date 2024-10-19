import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendNotification(String token, String title, String body) async {
  final url =
      'https://us-central1-triptour-63a6f.cloudfunctions.net/sendNotification2';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'token': token,
      'title': title,
      'body': body,
    }),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully: ${response.body}');
  } else {
    print(
        'Failed to send notification: ${response.statusCode}, ${response.body}');
  }
}
