import 'package:flutter/material.dart';
import 'package:triptourapp/notificationcheck/messages.dart';

class NotificationCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        messagesCheck(),
      ],
    );
  }
}
