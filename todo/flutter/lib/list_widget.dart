import 'dart:async';

import 'login_widget.dart';
import 'package:flutter/material.dart';
import 'package:todo_shared/shared.dart';

class NotesWidget extends StatefulWidget {
  NotesWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NotesWidgetState createState() => new _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  List<Note> notes;
  List<StreamSubscription> subscriptions;

  @override
  void initState() {
    super.initState();
    subscriptions = [
      Store.instance.noteController.listen((notes) {
        setState(() {
          this.notes = notes;
        });
      }, onError: (err) {
        if (err is UnauthenticatedException) {
          showDialog(context: context, barrierDismissible: false,
              builder: (context) =>  new LoginWidget());
        }
      }),

      Store.instance.userController.listen((user) {
        if (user != null) {
          Store.instance.noteController.getNotes();
        } else {
          showDialog(context: context, barrierDismissible: false,
              builder: (context) => new LoginWidget());
        }
      })
    ];
  }

  @override
  void dispose() {
    super.dispose();
    subscriptions.forEach((s) => s.cancel());
  }

  List<ListTile> get rows => notes?.map(noteRowForNote)?.toList() ?? [];

  ListTile noteRowForNote(Note note) {
    //todo: Make text editable, savable and stretch to bounds
    return new ListTile(
      title: new Text(note.title),
      subtitle: new Text(dateString(note.createdAt), style: new TextStyle(color: Colors.grey)),
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return new Scaffold(
              appBar: new AppBar(title: new Text(note.title)),
              body: new Center(
                child: new Text(note.contents)
              ),
            );
          },
        ));
      },
    );
  }

  String dateString(DateTime dateTime) {
    return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        actions: [
          new FlatButton(
              onPressed: Store.instance.userController.logout,
              child: new Text("LOGOUT",
              style: new TextStyle(color: Colors.white),))
        ],
      ),
      body: new Container(
        child: new ListView(
          children: rows
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/create");
        },
        tooltip: 'Create',
        child: new Icon(Icons.add),
      ),
    );
  }
}
