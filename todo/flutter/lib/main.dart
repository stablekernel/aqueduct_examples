import 'package:flutter/material.dart';
import 'list_widget.dart';
import 'create_widget.dart';
import 'login_widget.dart';

/*
flutter packages get

 */

void main() {
  runApp(new TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Todo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        "/": (_) => new NotesWidget(title: "Todo"),
        "/login": (_) => new LoginWidget(),
        "/create": (_) => new CreateNoteWidget()
      }
    );
  }
}
