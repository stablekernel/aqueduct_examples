import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'service_stream.dart';
import 'model.dart';

class Store {
  Store({
    Future<String> load(String pathOrKey),
    Future<bool> store(String pathOrKey, String contents),
    Future<bool> delete(String pathOrKey)
  }) : _storeFunction = store, _loadFunction = load, _deleteFunction = delete {
    noteController = new NoteController(this);
    userController = new UserController(this)
      ..listen((u) {
        if (u?.id != authenticatedUser?.id) {
          authenticatedUser = u;
        }
      });

    _loadPersistentUser();
  }

  static Store instance = new Store();

  UserController userController;
  NoteController noteController;
  String get clientAuthorization => "Basic ${new Base64Encoder().convert("com.dart.demo:abcd".codeUnits)}";

  User get authenticatedUser => _authenticatedUser;
  set authenticatedUser(User u) {
    _authenticatedUser = u;
    if (u != null && _storeFunction != null) {
      _storeFunction(_storedUserKey, JSON.encode(u.asMap()));
    } else if (u == null && _deleteFunction != null) {
      _deleteFunction(_storedUserKey);
    }
  }

  /* Private */

  final _StoreFunction _storeFunction;
  final _LoadFunction _loadFunction;
  final _DeleteFunction _deleteFunction;
  User _authenticatedUser;
  String get _storedUserKey => "user.json";

  void _loadPersistentUser() {
    if (_loadFunction != null) {
      _loadFunction(_storedUserKey).then((contents) {
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

class UserController extends ServiceController<User> {
  UserController(this.store);

  Store store;

  Future<User> login(String username, String password) async {
    try {
      var body = {
        "username": username,
        "password": password,
        "grant_type": "password"
      };

      var response = await http.post("http://localhost:8082/auth/token",
          headers: {
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
            "Authorization": store.clientAuthorization
          },
          body: body.keys.map((k) => "$k=${Uri.encodeQueryComponent(body[k])}").join("&"));

      var tokenOrError = JSON.decode(response.body);
      if (response.statusCode != 200) {
        throw tokenOrError["error"];
      }

      return getAuthenticatedUser(token: new AuthorizationToken.fromMap(tokenOrError));
    } catch (e, st) {
      addError(e, st);
    }

    return null;
  }

  Future<User> register(String username, String password) async {
    try {
      var response = await http.post("http://localhost:8082/register",
          headers: {
            "Content-Type": "application/json; charset=utf-8",
            "Authorization": store.clientAuthorization
          },
          body: JSON.encode({"username": username, "password": password}));

      var tokenOrError = JSON.decode(response.body);
      if (response.statusCode == 409) {
        throw "User already exists";
      } else if (response.statusCode != 200) {
        throw tokenOrError["error"];
      }

      return getAuthenticatedUser(token: new AuthorizationToken.fromMap(tokenOrError));
    } catch (e, st) {
      addError(e, st);
    }

    return null;
  }

  Future<User> getAuthenticatedUser({AuthorizationToken token}) async {
    try {
      token ??= store.authenticatedUser?.token;

      if (token?.isExpired ?? true) {
        throw new UnauthenticatedException();
      }

      var response = await http.get("http://localhost:8082/me",
          headers: {
            "Authorization": token.authorizationHeaderValue
          });
      var userOrError = JSON.decode(response.body);
      if (response.statusCode != 200) {
        throw userOrError["error"];
      }

      var user = new User.fromMap(userOrError)
        ..token = token;
      add(user);

      return user;
    } catch (e, st) {
      addError(e, st);
    }

    return null;
  }
}

class NoteController extends ServiceController<List<Note>> {
  NoteController(this.store);

  Store store;

  List<Note> _notes = [];

  Future<Note> createNote(String title, String contents) async {
    try {
      if (!(store.authenticatedUser?.isAuthenticated ?? false)) {
        throw new UnauthenticatedException();
      }

      var response = await http.post("http://localhost:8082/notes",
          headers: {
            "Content-Type": "application/json; charset=utf-8",
            "Authorization": store.authenticatedUser.token.authorizationHeaderValue
          },
          body: JSON.encode({"title": title, "contents": contents}));

      var noteOrError = JSON.decode(response.body);
      if (response.statusCode != 200) {
        throw noteOrError["error"];
      }

      var note = new Note.fromMap(noteOrError);
      _notes.insert(0, note);
      add(new List.from(_notes));

      return note;
    } catch (e, st) {
      addError(e, st);
    }

    return null;
  }

  Future<List<Note>> getNotes() async {
    try {
      if (!(store.authenticatedUser?.isAuthenticated ?? false)) {
        throw new UnauthenticatedException();
      }

      var response = await http.get("http://localhost:8082/notes",
          headers: {
            "Authorization": store.authenticatedUser.token.authorizationHeaderValue
          });
      var notesOrError = JSON.decode(response.body);
      if (response.statusCode != 200) {
        throw notesOrError["error"];
      }

      _notes = (notesOrError as List<Map>)
          .map((o) => new Note.fromMap(o))
          .toList();

      var outbound = new List.from(_notes);
      add(outbound);

      return outbound;
    } catch (e, st) {
      addError(e, st);
    }

    return null;
  }
}

class UnauthenticatedException implements Exception {}

typedef Future<String> _LoadFunction(String pathOrKey);
typedef Future<bool> _StoreFunction(String pathOrKey, String contents);
typedef Future<bool> _DeleteFunction(String pathOrKey);
