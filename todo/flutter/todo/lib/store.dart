import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'model.dart';

class Store {
  static Store get defaultInstance  {
    _defaultInstance ??= new Store();
    return _defaultInstance;
  }
  static Store _defaultInstance;

  String get _clientAuthorization => "Basic ${new Base64Encoder().convert("com.dart.demo:abcd".codeUnits)}";
  String get _bearerAuthorization => "Bearer ${_token.accessToken}";

  AuthorizationToken _token;
  bool get isAuthenticated =>
      (_token?.expiresAt?.difference(new DateTime.now().toUtc())?.inSeconds > 0)
          ?? false;

  User user;

  Future<User> login(String username, String password) async {
    var body = {
      "username": username,
      "password": password,
      "grant_type": "password"
    };
    var response = await http.post("http://localhost:8082/auth/token",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
          "Authorization": _clientAuthorization
        },
        body: body.keys.map((k) => "$k=${Uri.encodeQueryComponent(body[k])}").join("&"));

    var tokenOrError = JSON.decode(response.body);
    if (response.statusCode != 200) {
      throw tokenOrError["error"];
    }
    _token = new AuthorizationToken.fromMap(tokenOrError);

    return getAuthenticatedUser();
  }

  Future<User> register(String username, String password) async {
    var response = await http.post("http://localhost:8082/register",
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": _clientAuthorization
        },
        body: JSON.encode({"username": username, "password": password}));

    var tokenOrError = JSON.decode(response.body);
    if (response.statusCode != 200) {
      throw tokenOrError["error"];
    }
    _token = new AuthorizationToken.fromMap(tokenOrError);

    return getAuthenticatedUser();
  }

  Future<User> getAuthenticatedUser() async {
    if (!isAuthenticated) {
      throw "Not authenticated";
    }

    var response = await http.get("http://localhost:8082/me",
      headers: {
      "Authorization": _bearerAuthorization
    });
    var userOrError = JSON.decode(response.body);
    if (response.statusCode == 409) {
      throw "User already exists";
    } else if (response.statusCode != 200) {
      throw userOrError["error"];
    }

    user = new User.fromMap(userOrError);
    return user;
  }

  Future<Note> createNote(Note note) async {
    if (!isAuthenticated) {
      throw "Not authenticated";
    }

    print("Creating note: ${note.asMap()}");
    var response = await http.post("http://localhost:8082/notes",
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": _bearerAuthorization
        },
        body: JSON.encode(note.asMap()));

    var noteOrError = JSON.decode(response.body);
    if (response.statusCode != 200) {
      throw noteOrError["error"];
    }

    var createdNote = new Note.fromMap(noteOrError);
    user.notes.add(createdNote);
    user.notes.sort((n1, n2) => n1.updatedAt.compareTo(n2.createdAt));
    print("NOtes ${user.notes}");
    return createdNote;
  }

  Future<List<Note>> getNotes() async {
    var response = await http.get("http://localhost:8082/notes",
        headers: {
          "Authorization": _bearerAuthorization
        });
    var notesOrError = JSON.decode(response.body);
    if (response.statusCode != 200) {
      throw notesOrError["error"];
    }

    user.notes = (notesOrError as List<Map>).map((o) => new Note.fromMap(o)).toList();
    return user.notes;
  }
}

class AuthorizationToken {
  AuthorizationToken.fromMap(Map<String, dynamic> map) {
    accessToken = map["access_token"];
    refreshToken = map["refresh_token"];
    expiresAt = new DateTime.now().toUtc().add(new Duration(seconds: map["expires_in"]));
  }
  String accessToken;
  String refreshToken;
  DateTime expiresAt;
}