import 'dart:async';

import 'package:flutter/material.dart';

import 'model.dart';
import 'store.dart';

class CreateNoteWidget extends StatefulWidget {
  CreateNoteWidget({Key key}) : super(key: key);

  @override
  _CreateNoteState createState() => new _CreateNoteState();
}

class _CreateNoteState extends State<CreateNoteWidget> {
  final TextEditingController contentsController = new TextEditingController();
  final TextEditingController titleController = new TextEditingController();

  bool isSaving = false;
  bool get isTitleValid => titleController.text.isNotEmpty;
  bool get areContentsValid => contentsController.text.isNotEmpty;

  TextField get titleField =>
    new TextField(
      controller: titleController,
      onChanged: (_) => setState(() {}),
      decoration: new InputDecoration(
        hintText: 'Title',
        errorText: !isTitleValid ? "required" : null
      ),
    );

  TextField get contentsField =>
    new TextField(
      controller: contentsController,
      onChanged: (_) => setState(() {}),
      decoration: new InputDecoration(
        hintText: 'Contents',
        errorText: !areContentsValid ? "required" : null
      ),
    );

  Future saveNote() async {
    if (areContentsValid && isTitleValid) {
      isSaving = true;
    } else {
      return;
    }

    setState(() {});
    try {
      var n = new Note()
        ..title = titleController.text
        ..contents = contentsController.text;

      await Store.defaultInstance.createNote(n);
      Navigator.pop(context);
    } catch (e) {

    } finally {
      isSaving = false;
      setState(() {});
    }
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