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
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(widget, this),
        '/newEntry': (context) => NewEntry(),
      }
    );
  }
}

class HomePage extends StatefulWidget {
  MyApp myApp;
  _MyAppState materialState;

  HomePage(this.myApp, this.materialState);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State <HomePage> {

  Widget preferenceDrawer() {
    return 
      Drawer(
        child: AppBar(
          title: Text("Dark Theme"),
          actions: [Switch(
            value: widget.myApp.darkTheme,
            onChanged: (value) {
              widget.materialState.setState(() {
                widget.myApp.darkTheme = value;
                widget.myApp.prefs.setBool("dark", value);
              });
            }
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Welcome", textAlign: TextAlign.center), centerTitle: true),
        endDrawer: preferenceDrawer(),
        body: Center(
          child: noEntries()
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () { Navigator.pushNamed(context, '/newEntry'); },
          child: Icon(Icons.add)
        ),
      );
  }
}

class NewEntry extends StatefulWidget {

  @override
  _NewEntryState createState() => _NewEntryState();
}

class _NewEntryState extends State<NewEntry> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Entry"), centerTitle: true),
      body: EntryForm()
    );
  }
}

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();

  Widget createTextField(final name) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      child: TextFormField(
        decoration: InputDecoration(border: OutlineInputBorder(), labelText: name),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter some text';
          }

          return null;
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          createTextField('Title'),
          createTextField('Description'),
          createTextField('Rating'),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: RaisedButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context);
                    }
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: RaisedButton(
                    color: Colors.blue,
                    child: Text("Submit"),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Content')));
                      }
                    }
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}