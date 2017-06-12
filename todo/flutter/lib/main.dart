import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'list_widget.dart';
import 'create_widget.dart';
import 'login_widget.dart';
import 'package:todo_shared/shared.dart';

/*
flutter packages get

 */

void main() {
  Store.instance = new Store(storageProvider: new FlutterStorageProvider());

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

class FlutterStorageProvider implements StorageProvider {
  @override
  Future<String> load(String pathOrKey) async {
    var dir = await getApplicationDocumentsDirectory();
    var file = new File.fromUri(dir.uri.resolve(pathOrKey));

    return file.readAsString();
  }

  @override
  Future<bool> store(String pathOrKey, String contents) async {
    var dir = await getApplicationDocumentsDirectory();
    var file = new File.fromUri(dir.uri.resolve(pathOrKey));

    await file.writeAsString(contents);

    return true;
  }

  @override
  Future<bool> delete(String pathOrKey) async {
    var dir = await getApplicationDocumentsDirectory();
    var file = new File.fromUri(dir.uri.resolve(pathOrKey));
    await file.delete();

    return true;
  }
}