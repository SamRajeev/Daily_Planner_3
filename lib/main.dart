import 'package:flutter/material.dart';
import 'package:dailyplanner2_5/Home_Page.dart';
import 'package:dailyplanner2_5/Planner.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();
void main()async {
     WidgetsFlutterBinding.ensureInitialized();
     AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
     final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
         requestAlertPermission: true,
         requestBadgePermission: true,
         requestSoundPermission: true,
         onDidReceiveLocalNotification:(int id,String tile,String body,String payload) async{});
     final InitializationSettings initializationSettings = InitializationSettings(
         initializationSettingsAndroid, initializationSettingsIOS);
     await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification:(String payload) async{
//          if (payload != null){
//               debugPrint('notification payload':payload);
//          }
     });
     runApp(MaterialApp(
          routes: {
               '/':(context) => Home(),
               '/planner':(context) =>Planner()
          },
          debugShowCheckedModeBanner: false,
     ));
}




