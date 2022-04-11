import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
// widgets
import '../widgets/custom_app_bar.dart';
import '../widgets/goal_and_add.dart';
import '../widgets/weather_suggestion.dart';
import '../widgets/loading_screen.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
// providers
import '../providers/home_provider.dart';
import '../providers/auth_provider.dart';

// models
import '../models/app_user.dart';

// widgets
import '../widgets/custom_progress_indicator.dart';
import '../widgets/custom_form_field.dart';

class HomeScreen extends StatefulWidget {
  final Function openDrawer;
  static const routeName = 'entry-screen';
  HomeScreen({this.openDrawer});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  double threshold = 2;
  var response;
  var lastResponse;
  @override
  void initState() {
    super.initState();
    init();
  }

  void toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  List status = [];
  Future<Null> delay(int milliseconds) {
    return new Future.delayed(new Duration(milliseconds: milliseconds));
  }

  load() async {
    status = [];
    response = await http.get(Uri.parse(
        'https://api.thingspeak.com/channels/1676702/feeds.json?api_key=C83WP04RKMVYBZ77&results=5000'));

    lastResponse = await http.get(Uri.parse(
        'https://api.thingspeak.com/channels/1676702/feeds/last?api_key=C83WP04RKMVYBZ77'));

    int checkPeriod = 0;

    bool lastState = false;
    // double lastValue = 0;

    jsonDecode(response.body)['feeds'].forEach((value) {
      if (value['field3'] == null) {
        return;
      }
      print(status);
      if (double.parse(value['field3']) < threshold) {
        if (lastState) {
          checkPeriod++;

          if (checkPeriod > 0) {
            checkPeriod = 0;
            lastState = false;
            status.add(value);
          }
        } else {
          checkPeriod = 0;
          lastState = false;
        }
      } else {
        if (!lastState) {
          checkPeriod++;

          if (checkPeriod > 0) {
            checkPeriod = 0;
            lastState = true;
            status.add(value);
          }
        } else {
          checkPeriod = 0;
          lastState = true;
        }
      }

      // lastValue = double.parse(value['field3']);

      // if (lastValue > threshold && lastState == false) {
      //   status.add(value);
      //   lastState = true;
      // } else if (lastValue < threshold && lastState == true) {
      //   status.add(value);
      //   lastState = false;
      // }
    });
    status = status.reversed.toList();
    setState(() {});
  }

  void init() async {
    load();
    Timer.periodic(Duration(seconds: 10), (Timer t) => load());
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading || response == null || status == null
        ? LoadingScreen()
        : Scaffold(
            body: ListView.builder(
              itemBuilder: (BuildContext context, int i) {
                if (i == 0)
                  return CustomAppBar(
                    openDrawer: widget.openDrawer,
                    trailing: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        User user = authProvider.user;
                        return CircleAvatar(
                          radius: 19,
                          backgroundImage: NetworkImage(user.photoURL),
                        );
                      },
                    ),
                  );

                if (i == 1)
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: 50, right: 50, top: 30, bottom: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          child: Container(
                            child: GoalAndAdd(
                                value: jsonDecode(lastResponse.body)),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Motor Status',
                          style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 20,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  );

                if (status[i] != null) {
                  return ListTile(
                    leading: Icon(
                      Icons.stop_circle,
                      color: double.parse(status[i]['field3']) > threshold
                          ? Colors.blue
                          : Colors.blue.shade100,
                    ),
                    // title: jsonDecode(response.body).feeds[i].field3,
                    title: Text(double.parse(status[i]['field3']) > threshold
                        ? 'Turned On'
                        : 'Turned Off'),

                    subtitle: Text(
                        "${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(status[i]['created_at']).toLocal())}  (${timeago.format(DateTime.parse(status[i]['created_at']))})"),
                  );
                } else {
                  return Container();
                }
              },
              itemCount: status.length,
            ),
            // floatingActionButton: FloatingActionButton(
            //     elevation: 3,
            //     backgroundColor: Color.fromARGB(255, 0, 60, 192),
            //     child: Icon(
            //       Icons.add,
            //       size: 30,
            //     ),
            //     onPressed: () {
            //       //Navigator.of(context).pushNamed(AddWaterScreen.routeName);
            //       showDialog(
            //           context: context,
            //           builder: (BuildContext ctx) {
            //             return AddWaterWidget();
            //           });
            //     }),
          );
  }
}

class AddWaterWidget extends StatefulWidget {
  @override
  _AddWaterWidgetState createState() => _AddWaterWidgetState();
}

class _AddWaterWidgetState extends State<AddWaterWidget> {
  bool _loading = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // data
  DateTime _time = DateTime.now();
  int _water;

  void toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  void submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    toggleLoading();
    try {
      await Provider.of<HomeProvider>(context, listen: false)
          .addWater(_water, _time);
      Navigator.of(context).pop();
      return;
    } catch (e) {
      print(e);
    }
    toggleLoading();
  }

  @override
  Widget build(BuildContext context) {
    AppUser appUser = Provider.of<HomeProvider>(context).appUser;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Text(
            'Add Water',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          SizedBox(
            height: 20,
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    DateTime date = await showDatePicker(
                      context: context,
                      initialDate: _time,
                      firstDate: DateTime(1960),
                      lastDate: _time,
                    );
                    if (date != null && date.isBefore(DateTime.now())) {
                      setState(() {
                        _time = date;
                      });
                    }
                  },
                  child: CustomFormField(
                      label: 'Date',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMd('en_US').format(_time),
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          Icon(Icons.arrow_drop_down)
                        ],
                      )),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          )
        ],
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      actions: <Widget>[
        // FlatButton(
        //   textColor: Color.fromARGB(255, 0, 60, 192),
        //   child: Text('Cancel',
        //       style: GoogleFonts.poppins(
        //           fontSize: 13, fontWeight: FontWeight.w500)),
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //   },
        // ),
        // FlatButton(
        //   color: Color.fromARGB(255, 0, 60, 192),
        //   child: _loading
        //       ? SizedBox(
        //           height: 22, width: 22, child: CustomProgressIndicatior())
        //       : Text('Add',
        //           style: GoogleFonts.poppins(
        //               fontSize: 13, fontWeight: FontWeight.w500)),
        //   onPressed: submit,
        // ),
      ],
    );
  }
}
