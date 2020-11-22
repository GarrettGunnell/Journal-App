import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool darkTheme = prefs.getBool("dark");
  runApp(new MyApp(darkTheme, prefs));
}

class MyApp extends StatefulWidget {
  bool darkTheme;
  SharedPreferences prefs;

  MyApp(this.darkTheme, this.prefs);

  @override
  _MyAppState createState() => _MyAppState();
}

Widget preferenceDrawer(MyApp app, _MyAppState state) {
  return 
    Drawer(
      child: AppBar(
        title: Text("Dark Theme"),
        actions: [Switch(
          value: app.darkTheme,
          onChanged: (value) {
            state.setState(() {
              app.darkTheme = value;
              app.prefs.setBool("dark", value);
            });
          }
        )
      ],
    ),
  );
}

Widget noEntries() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.book, size: 100),
      Text("Journal")
    ]
  );
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: widget.darkTheme ? Brightness.dark : Brightness.light
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Welcome", textAlign: TextAlign.center), centerTitle: true),
        endDrawer: preferenceDrawer(widget, this),
        body: Center(
          child: noEntries()
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: null,
          child: Icon(Icons.add)
        ),
      ),
    );
  }
}
