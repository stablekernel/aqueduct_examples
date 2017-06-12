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
              child: new LoginWidget());
        }
      }),

      Store.instance.userController.listen((user) {
        if (user != null) {
          Store.instance.noteController.getNotes();
        } else {
          showDialog(context: context, barrierDismissible: false,
              child: new LoginWidget());
        }
      })
    ];
  }

  @override
  void dispose() {
    super.dispose();
    subscriptions.forEach((s) => s.cancel());
  }

  List<Container> get rows => notes?.map(noteRowForNote)?.toList() ?? [];

  Container noteRowForNote(Note note) {
    return new Container(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Text(note.title),
          new Padding(padding: const EdgeInsets.all(5.0)),
          new Text(dateString(note.createdAt), style: new TextStyle(color: Colors.grey))
        ],
      )
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
