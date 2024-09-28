import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_notification/main.dart';
import 'package:timezone/timezone.dart' as tz;

class Medicine {
  late String? id;
  final String name;
  final String time;
  final String userId;
  bool taken;
  Timestamp? takenAt;

  Medicine({
    this.id,
    required this.name,
    required this.time,
    required this.userId,
    this.taken=false,
    this.takenAt
  });

  Map<String, dynamic> toMap() {
    return {
      'medicine_name': name,
      'reminder_time': time,
      'user_id': userId,
      'taken': taken,
      'taken_at': takenAt
    };
  }

  factory Medicine.fromDocument(DocumentSnapshot doc) {
    final id = doc.id;
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document snapshot has no data");
    }
    return Medicine(
      id:  id,
      name: doc['medicine_name'],
      time: doc['reminder_time'],
      userId: doc['user_id'],
      taken: doc['taken'],
      takenAt: doc['taken_at']
    );
  }

  Future<void> scheduleNotificationEvery30Minutes() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.high
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      sound: 'default',
    );


    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Parse da string de hora "HH:mm"
    final parts = time.split(":");
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    // Obtenha a data atual
    final localTimeZone = tz.getLocation('America/Sao_Paulo');
    final now = tz.TZDateTime.now(localTimeZone);
    const minutesToAdd = 2;
    tz.TZDateTime medicineTime = tz.TZDateTime(
      localTimeZone,
      now.year,
      now.month,
      now.day,
      hour,
      minute
    );
    if (medicineTime.isBefore(now)){
      int totalMinutes = now.hour * 60 + now.minute;
      int nextTotalMinutes = (totalMinutes + minutesToAdd) % (24 * 60);

      int nextHour = nextTotalMinutes ~/ 60;
      int nextMinute = nextTotalMinutes % 60;

      medicineTime = tz.TZDateTime(
          localTimeZone,
          now.year,
          now.month,
          now.day,
          nextHour,
          nextMinute
      );
    }
    int count = 0;
    for (medicineTime; medicineTime.day == now.day; medicineTime = medicineTime.add(Duration(minutes:minutesToAdd))) {
      flutterLocalNotificationsPlugin.zonedSchedule(
        id.hashCode + count,
        'Hora de tomar o remédio!',
        'Você precisa tomar o remédio: ${name}',
        medicineTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      count++;
    }
  }
  Future<void> cancelNotificationsForMedicine() async {
    // Parse da string de hora "HH:mm"
    final parts = time.split(":");
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    // Obtenha a data atual
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime medicineTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute
    );

    int count = 0;
    for (medicineTime; medicineTime.day == now.day; medicineTime = medicineTime.add(Duration(minutes:2))) {
      await flutterLocalNotificationsPlugin.cancel(id.hashCode + count);
      count++;
    }
  }

}