import 'package:Journal/journal.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool darkTheme = prefs.getBool("dark");

  final Database database = await openDatabase(
    join(await getDatabasesPath(), 'journal.sqlite3.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE journal_entries(id INTEGER PRIMARY KEY, title TEXT, description TEXT, rating INTEGER, date INTEGER)"
        );
    },
    version: 1,
  );

  //await deleteDatabase(join(await getDatabasesPath(), 'journal.sqlite3.db'));
  await database.close();
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
  EntryDataTransfer formData = new EntryDataTransfer();

  Widget createTextField(final name) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      child: TextFormField(
        decoration: InputDecoration(border: OutlineInputBorder(), labelText: name),
        validator: (value) {
          if (value.isEmpty) {
            if (name == 'Title') formData.title = null;
            else if (name == 'Description') formData.description = null;
            else if (name == 'Rating') formData.rating = null;
            return 'Please enter some text';
          }
        
          if (name == 'Title') formData.title = value;
          else if (name == 'Description') formData.description = value;
          else if (name == 'Rating') {
            int rating;
            try {
              rating = int.parse(value);
            }
            on FormatException {
              return 'Please enter a number';
            }

            if (rating < 1 || 4 < rating) return 'Please enter a number between 1 and 4';
            formData.rating = rating;
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
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        final Database db = await openDatabase(join(await getDatabasesPath(), 'journal.sqlite3.db'));
                        
                        Entry newEntry = Entry(
                          id: 0, 
                          title: formData.title,
                          description: formData.description, 
                          rating: formData.rating, 
                          date: DateTime.now().millisecondsSinceEpoch,
                        );
                        
                        await db.insert(
                          'journal_entries',
                          newEntry.toMap(), 
                        );

                        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Content')));
                        Navigator.pop(context);
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