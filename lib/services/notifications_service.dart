import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class NotificationsService {
  static Future<void> sendOneSignalNotification({
  required String userId,
  required String title,
  required String message,
  Map<String, dynamic>? data,
}) async {
  const String oneSignalAppId = '924b44f7-e96e-477c-8547-55b98800accc';
  const String restApiKey = 'os_v2_app_sjfuj57jnzdxzbkhkw4yqafmztho7b3c4qcerw57bwbvbyupmiyepxen6jxtkqkjaoe2ptdwizjkvtcfgg6yzp444xuargxwk5aqeoy';

  final response = await http.post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic $restApiKey',
    },
    body: jsonEncode({
      'app_id': oneSignalAppId,
      'include_external_user_ids': [userId],
      'headings': {'en': title},
      'contents': {'en': message},
      "small_icon": "ic_stat_chingoo",
      'data': data ?? {},
    }),
  );

  if (response.statusCode == 200) {
    print(' Notification sent successfully');
  } else {
    print(' Failed to send notification: ${response.body}');
  }
}

static Future<Map<String, bool>> getNotificationSettings(String uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final settings = doc.data()?['notificationSettings'] ?? {};

  return {
    'messages': settings['messages'] ?? true,
    'rideUpdates': settings['rideUpdates'] ?? true,
    'announcements': settings['announcements'] ?? true,
  };
}

}
