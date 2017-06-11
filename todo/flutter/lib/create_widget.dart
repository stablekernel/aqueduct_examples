import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo_shared/shared.dart';

class CreateNoteWidget extends StatefulWidget {
  CreateNoteWidget({Key key}) : super(key: key);

  @override
  _CreateNoteState createState() => new _CreateNoteState();
}

class _CreateNoteState extends State<CreateNoteWidget> {
  final TextEditingController contentsController = new TextEditingController();
  final TextEditingController titleController = new TextEditingController();

  StreamSubscription subscription;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    subscription = Store.defaultInstance.noteController.listen((notes) {
      Navigator.pop(context);
    }, onError: (err) {
      isSaving = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  TextField get titleField =>
    new TextField(
      controller: titleController,
      decoration: new InputDecoration(
        hintText: 'Title'
      ),
    );

  TextField get contentsField =>
    new TextField(
      controller: contentsController,
      decoration: new InputDecoration(
        hintText: 'Contents'
      ),
    );

  void saveNote() {
    if (contentsController.text.isNotEmpty && titleController.text.isNotEmpty) {
      isSaving = true;
    } else {
      return;
    }

    setState(() {
      isSaving = true;
      Store.defaultInstance.noteController.createNote(
          titleController.text, contentsController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Create New Note"),
      ),

      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(
          children: [
            new Row(children: [new Expanded(child: titleField)]),
            new Row(children: [new Expanded(child: contentsField)]),
          ]
        ),
      ),
      floatingActionButton: isSaving ? null : new FloatingActionButton(
        onPressed: saveNote,
        tooltip: 'Save',
        child: new Icon(Icons.save),
      ),
    );
  }
}