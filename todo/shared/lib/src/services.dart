import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'model.dart';
import 'service_controller.dart';
import 'store.dart';

class UserService extends ServiceController<User> {
  UserService(this.store);

  Store store;

  Future<User> login(String username, String password) async {
    var req = new Request.post("/auth/token", {
      "username": username,
      "password": password,
      "grant_type": "password"
    }, contentType: new ContentType("application", "x-www-form-urlencoded"));

    var response = await store.executeClientRequest(req);
    if (response.error != null) {
      addError(response.error);
      return null;
    }

    switch (response.statusCode) {
      case 200: return getAuthenticatedUser(token: new AuthorizationToken.fromMap(response.body));
      default: addError(new APIError(response.body["error"]));
    }

    return null;
  }

  Future<User> register(String username, String password) async {
    var req = new Request.post(
        "/register", {"username": username, "password": password});

    var response = await store.executeClientRequest(req);
    if (response.error != null) {
      addError(response.error);
      return null;
    }

    switch (response.statusCode) {
      case 200: return getAuthenticatedUser(token: new AuthorizationToken.fromMap(response.body));
      case 409: addError(new APIError("User already exists")); break;
      default: addError(new APIError(response.body["error"]));
    }

    return null;
  }

  Future<User> getAuthenticatedUser({AuthorizationToken token}) async {
    var req = new Request.get("/me");
    var response = await store.executeUserRequest(req, token: token);

    if (response.error != null) {
      addError(response.error);
      return null;
    }

    switch (response.statusCode) {
      case 200: {
        var user = new User.fromMap(response.body)
          ..token = token;
        add(user);

        return user;
      } break;

      default: addError(new APIError(response.body["error"]));
    }

    return null;
  }
}

class NoteService extends ServiceController<List<Note>> {
  NoteService(this.store);

  Store store;

  List<Note> _notes = [];

  Future<Note> createNote(String title, String contents) async {
    var req = new Request.post("/notes", {"title": title, "contents": contents});
    var response = await store.executeUserRequest(req);

    if (response.error != null) {
      addError(response.error);
      return null;
    }

    switch (response.statusCode) {
      case 200: {
        var note = new Note.fromMap(response.body);
        _notes.insert(0, note);
        add(new List.from(_notes));

        return note;
      } break;

      default: addError(new APIError(response.body["error"]));
    }

    return null;
  }

  Future<List<Note>> getNotes() async {
    var req = new Request.get("/notes");
    var response = await store.executeUserRequest(req);

    if (response.error != null) {
      addError(response.error);
      return null;
    }

    switch (response.statusCode) {
      case 200: {
        _notes = (response.body as List<Map>)
            .map((o) => new Note.fromMap(o))
            .toList();

        var outbound = new List.from(_notes);
        add(outbound);

        return outbound;
      } break;

      default: addError(new APIError(response.body["error"]));
    }

    return null;
  }
}
