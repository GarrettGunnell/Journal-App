import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool themeState = prefs.getBool("dark");
  runApp(new MyApp(themeState, prefs));
}

class MyApp extends StatefulWidget {
  bool themeState;
  SharedPreferences prefs;

  MyApp(this.themeState, this.prefs);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: widget.themeState ? Brightness.dark : Brightness.light
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Welcome")),
        endDrawer: Drawer(
          child: AppBar(
            title: Text("Dark Theme"),
            actions: [Switch(
              value: widget.themeState,
              onChanged: (value) {
                setState(() {
                  widget.themeState = value;
                  widget.prefs.setBool("dark", value);
                });
              }
            )],
          ),
        ),
        body: Center(

        ),
      )
    );
  }
}
