import 'package:flutter/material.dart';
import 'journal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NewEntry extends StatefulWidget {
  List<Entry> entries;
  NewEntry(this.entries);

  @override
  _NewEntryState createState() => _NewEntryState();
}

class _NewEntryState extends State<NewEntry> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Entry"), centerTitle: true),
      body: EntryForm(widget.entries)
    );
  }
}

class EntryForm extends StatefulWidget {
  List<Entry> entries;
  EntryForm(this.entries);

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
                          id: widget.entries.length + 1, 
                          title: formData.title,
                          description: formData.description, 
                          rating: formData.rating, 
                          date: DateTime.now().millisecondsSinceEpoch,
                        );
                        
                        await db.insert(
                          'journal_entries',
                          newEntry.toMap(), 
                        );

                        widget.entries.add(newEntry);
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Content')));
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/');
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

class DisplayEntry extends StatelessWidget {
  final Entry entry;
  DisplayEntry(this.entry);

  @override
  Widget build(BuildContext context) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(entry.date);
    return Scaffold(
      appBar: AppBar(title: Text(date.month.toString() + '-' + date.day.toString()), centerTitle: true,),
      body: Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: [
          SizedBox(child: Text(entry.title, style: Theme.of(context).textTheme.headline4, textAlign: TextAlign.left), width: double.infinity), 
          SizedBox(child: Text(entry.description), width: double.infinity)
        ]
      )
      )
    );
  }
}