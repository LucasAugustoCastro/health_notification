import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_notification/provider/medicines.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'firebase_options.dart';
import 'register.dart';
import 'login.dart';
import 'home.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  
  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );


  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) async {
      debugPrint('notification payload: $details');
    },
  );
}

Future<void> onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title ?? ''),
      content: Text(body ?? ''),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        )
      ],
    ),
  );
}
Future<void> _requestIOSPermissions() async {
  final IOSFlutterLocalNotificationsPlugin iosPlugin =
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!;

  await iosPlugin.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
}
Future<void> _requestAndroidPermissions() async {
  if (Platform.isAndroid && (await Permission.notification.isDenied)) {
    await Permission.notification.request();
  }
}








void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await initializeNotifications();
  if (Platform.isIOS) {
    _requestIOSPermissions();
  }
  if (Platform.isAndroid) {
    await _requestAndroidPermissions();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Medicines()),
      ],
      child: MaterialApp(
        builder: (context, child) =>
            MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthGate(),
          '/register': (context) => RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Aguarde a conclusão da construção do widget antes de fazer a navegação
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!snapshot.hasData) {
            Navigator.pushReplacementNamed(context, '/login');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
        // Retorne um widget vazio durante o processo
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()), // Mostra algo enquanto decide a navegação
        );
      },
    );
  }
}

