import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parceiroezze/firebase_options.dart';
import 'package:parceiroezze/service/firebase_messaging_service.dart';
import 'package:parceiroezze/service/notification_service.dart';
import 'package:parceiroezze/view/tela_login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();

  void initialize() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    _flutterLocalNotificationPlugin.initialize(initializationSettings);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(providers: [
      Provider<NotificationService>(
        create: (context) => NotificationService(),
      ),
      Provider<FirebaseMessagingService>(
        create: (context) =>
            FirebaseMessagingService(context.read<NotificationService>()),
      )
    ], child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initilizeFirebaseMessaging();
  }

  initilizeFirebaseMessaging() async {
    await Provider.of<FirebaseMessagingService>(context, listen: false)
        .initilize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
              iconTheme:
                  IconThemeData(color: Color.fromRGBO(113, 0, 150, 0.8)))),
      debugShowCheckedModeBanner: false,
      title: 'Ezze',
      home: const TelaLogin(),
    );
  }
}
