import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'services.dart';
import 'model.dart';

class Store {
  Store({this.storageProvider}) {
    noteController = new NoteService(this);
    userController = new UserService(this)
      ..listen((u) {
        if (u?.id != authenticatedUser?.id) {
          authenticatedUser = u;
        }
      });

    _loadPersistentUser();
  }

  static Store instance = new Store();

  UserService userController;
  NoteService noteController;
  String get clientAuthorization => "Basic ${new Base64Encoder().convert("com.dart.demo:abcd".codeUnits)}";

  User get authenticatedUser => _authenticatedUser;
  set authenticatedUser(User u) {
    _authenticatedUser = u;
    if (storageProvider != null) {
      if (u != null) {
        storageProvider.store(_storedUserKey, JSON.encode(u.asMap()));
      } else if (u == null) {
        storageProvider.delete(_storedUserKey);
      }
    }
  }

  /* Private */

  final StorageProvider storageProvider;
  User _authenticatedUser;
  String get _storedUserKey => "user.json";

  void _loadPersistentUser() {
    if (storageProvider != null) {
      storageProvider.load(_storedUserKey).then((contents) {
        try {
          authenticatedUser = new User.fromMap(JSON.decode(contents));
          userController.add(authenticatedUser);
        } catch (_) {
          userController.add(null);
        }
      }).catchError((_) {
        userController.add(null);
      });
    } else {
      userController.add(null);
    }
  }
}

abstract class StorageProvider {
  Future<String> load(String pathOrKey);
  Future<bool> store(String pathOrKey, String contents);
  Future<bool> delete(String pathOrKey);
}