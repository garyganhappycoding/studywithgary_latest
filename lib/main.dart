import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studywithgary/services/background_timer_service.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';


void main() async { //async: this task take some time, wait for some time
  // note that async and await are tied together
  // async : tells flutter required some time
  // await: tells flutter to wait for async to done the job
  WidgetsFlutterBinding.ensureInitialized();
  //to get the phone hardware prepare, sometimes flutter need internet connection, phone's id, storage
  //this make sure the phone is ready to connect with firebase
  await Firebase.initializeApp( // connect flutter to firebase
    options: DefaultFirebaseOptions.currentPlatform, //to tell flutter to use which api key in the firebase_options based on what device we are running
  );
  await _initializeNotifications();
  await BackgroundTimerService.initializeBackgroundService();
  runApp(const MyApp());
}


Future<void> _initializeNotifications() async { //Future<void> .. async meaning that this task won't finish instanlty, it is a promise to finish later
  //create notification manager object, use for creating a pop up message on the screen
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  const AndroidInitializationSettings androidInitializationSettings =
  AndroidInitializationSettings('app_icon');
  //tells android when i send a notification, use icon named app_icon to show in the top status bar
  // you must have a file name app_icon.png in your android/app/src/main/res/drawable folder or else the app will crash


  const InitializationSettings initializationSettings =
  InitializationSettings(
    android: androidInitializationSettings,
    iOS: DarwinInitializationSettings(),
  );
  // set up that combine for IOS and android set up setting

  await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
// tells flutter to register the notification function first

  const AndroidNotificationChannel timerChannel = AndroidNotificationChannel(
    'timer_channel',
    'Study Timer Progress',
    description: 'Shows your active countdown',
    importance: Importance.low, // No sound, no pop-up
    enableVibration: false,
  );

  // 2. THE LOUD CHANNEL (For the "Time is Up" Alarm)
  const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
    'alarm_channel',
    'Timer Alarms',
    description: 'Alerts you when your study session ends',
    importance: Importance.max, // Makes sound and pops up on screen
    enableVibration: true,
    playSound: true,
  );

  // const datatype var_name = datatype( unique id, name, description, importance, enableVibration, playSound )

  // 3. REGISTER BOTH CHANNELS
  // We ask the Android specialist to create both folders in the phone settings
  final androidImplementation = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//flutter is for both ios and android but we only need flutter to create a android notification plugin if it is android
  await androidImplementation?.createNotificationChannel(timerChannel);
  await androidImplementation?.createNotificationChannel(alarmChannel);
  //ask flutter to create notification channel for timerChannel and alarmChannel
}


class MyApp extends StatelessWidget {
  const MyApp({super.key}); //when you have a list of pages or ID in your main dart and you need flutter to listen and find which one to listen yo will use super.key


  @override
  Widget build(BuildContext context) {
    return MultiProvider( //when you have more than one data going to present in the screen but flutter don't know which one, we will use multiprovider
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), //ChangeNotifierProvider = when there is something change in authprovider class, it will call the flutter and change something
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'study with gary',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthGate(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
        }, //tells the app where to navigate when first run through the app
      ),
    );
  }
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>( // consumer: who am i listening to? (AuthProvider)
      builder: (context, authProvider, _) { // how do i build the UI. listening to the address(context), where to listen: authProvider class, _: child in the authProvider
        if (authProvider.isAuthenticated) { //if the authProvider, isAuthenticated meaning the user has already login it will show homescreen)
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

