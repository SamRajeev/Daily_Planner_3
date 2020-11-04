import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dailyplanner2_5/main.dart';



class Planner extends StatefulWidget {
  @override
  _PlannerState createState() => _PlannerState();
}

final time = DateFormat.MMMMd('en_us').format(DateTime.now());

class _PlannerState extends State<Planner> {
  CalendarController _calendarController;
  TextEditingController _eventController;
  //TextEditingController _renameController;
  String meetingName;
  List<Meeting> meetings;
  SharedPreferences prefs;
  List<List> meetings2;
  String helpText = " ";
//  String _text;
//  String _titleText;

  initState() {
    _calendarController = CalendarController();
    _eventController = TextEditingController();
    //_renameController = TextEditingController();
    meetings = <Meeting>[];
    super.initState();
    //_text='';
    //_titleText='';
    initPrefs();

  }


  initPrefs()async{
    prefs = await SharedPreferences.getInstance();
    final data = jsonDecode(prefs.getString('events'));
    for(int index = 0; index < data.length; index++){
      DateTime from = DateTime.parse(data[index][1]);
      DateTime to = DateTime.parse(data[index][2]);
      setState(() {
        meetings.add(Meeting(data[index][0],from,to,const Color(0xFF0F8644),false));
      });
    }
  }


  inputdatabase(){
    meetings2 = [];
    for(int index = 0; index < meetings.length; index++){
      meetings2.add([meetings[index].eventName.toString(),meetings[index].from.toString(),meetings[index].to.toString(),jsonEncode(false)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(time),
        centerTitle: true,
        actions: <Widget>[
          RaisedButton(
            child:Icon(Icons.arrow_back),
            color: Colors.blue,
            onPressed: (){
              Navigator.pushNamed(context, '/');
            },
            elevation: 0.0,
          )
        ],
      ),

      body: SfCalendar(
        dataSource: MeetingDataSource(meetings),
        controller: _calendarController,
        showNavigationArrow: true,
        //onTap: calendarTapped,
        selectionDecoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color:Colors.blue , width: 3),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          shape: BoxShape.rectangle,),
        appointmentTextStyle: TextStyle(
            fontSize: 16,
            //fontWeight: FontWeight.bold
    ),
        timeSlotViewSettings: TimeSlotViewSettings(
            timeInterval: Duration(hours: 1),
            timeIntervalWidth:80,
            timeTextStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              fontSize: 15,
              color: Colors.blue,
            )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
            Icons.add
        ),
        onPressed: (){
         eventAdder();
        },
      ),
      drawer:  Drawer(

          child: Container(
            color: Colors.blue,
            child: ListView(

              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text("Help",style: TextStyle(
                    fontSize: 15.0
                  ),),
                  onTap: (){helpTextContent();},
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(helpText,style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold
                  ),),
                )

              ],
            ),
          )
      ),
    );
  }
  Future onSelection(String payload)async{
    showDialog(
      context: context,
      builder: (context) =>AlertDialog(
        content: Text('Notification Clicked $payload'),
      )

    );


  }
  eventAdder() async{
    await showDialog(
        context:context,
        builder: (context) => AlertDialog(
          content: TextField(
            controller: _eventController,
            autofocus: true,
          ),
          actions: <Widget>[
            FlatButton(
              child:Text("Cancel"),
              onPressed: (){
                _eventController.clear();
                Navigator.pop(context, true);
                },
            ),
            FlatButton(
              child:Text("Save"),
              onPressed: (){
                //print(_calendarController.);
                setState(() {
                  if(_eventController.text.isEmpty) return;
                  else{
                    setState(() {
                      meetingName = _eventController.text;
                    });
                  }
                  _eventController.clear();
                }
                );
                Navigator.pop(context, true);
                setState((){
                  final DateTime startTime = _calendarController.selectedDate;
                  final DateTime endTime = startTime.add(const Duration(hours: 1));
                  scheduleEvent(startTime, meetingName);
                  meetings.add(Meeting(meetingName, startTime, endTime, const Color(0xFF0F8644), false));
                  inputdatabase();
                  prefs.setString('events',jsonEncode(meetings2));


                });
              },
            ),
          ],
        )
      );
    }

  void helpTextContent() {
    setState(() {
      helpText = "To schedule your event follow the given steps:\n\n 1. Just select the specific time slot.\n\n"
          " 2. Then click on the add button and \n enter your event's name.\n\n 3. Save it.\n\n\n""Thanks for using help.\n";
    });
  }
  void scheduleEvent(DateTime startTime,meetingName)async{
    var scheduledNotificationDateTime = startTime;

    var androidPlatformSpecifics = AndroidNotificationDetails(
        '0',
        meetingName,
        'Reminder',
        icon: 'app_icon',
        largeIcon: DrawableResourceAndroidBitmap('app_icon.jpg')
    );
    var iosPlatformSpecifics =  IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      //presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformSpecifics,iosPlatformSpecifics
    );
    int id = DateTime.now().millisecondsSinceEpoch.toUnsigned(31);
    print(id);

    await flutterLocalNotificationsPlugin.schedule(id, 'Reminder', meetingName, scheduledNotificationDateTime, platformChannelSpecifics);


  }
}




/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting>source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;
}


