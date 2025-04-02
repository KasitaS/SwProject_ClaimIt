import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'dart:io';

class EmailSender {
  String username;
  String password;

  EmailSender({required this.username, required this.password});

  Future<void> sendEmail(String recipientEmail, String subject, String body,
      String imagePath) async {
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Lost And Found Teams')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = body
      ..attachments.add(FileAttachment(File(imagePath)));

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}
