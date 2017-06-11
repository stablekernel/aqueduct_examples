import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo_shared/shared.dart';

class LoginWidget extends StatefulWidget {
  LoginWidget({Key key}) : super(key: key);

  @override
  _LoginWidgetState createState() => new _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  String errorMessage = "";
  bool get isPasswordFieldValid => usernameController.text.isNotEmpty;
  bool get isUsernameFieldValid => passwordController.text.isNotEmpty;

  TextField get usernameField =>
      new TextField(
        keyboardType: TextInputType.emailAddress,
        controller: usernameController,
        decoration: new InputDecoration(
            hintText: 'username',
            errorText: !isUsernameFieldValid  ? "required" : null
        ),
      );

  TextField get passwordField =>
      new TextField(
        obscureText: true,
        controller: passwordController,
        decoration: new InputDecoration(
            hintText: 'password',
            errorText: !isPasswordFieldValid ? "required" : null
        ),
      );

  Future register() async {
    if (isPasswordFieldValid && isUsernameFieldValid) {
      try {
        await Store.defaultInstance.register(usernameController.text, passwordController.text);
        Navigator.pushNamed(context, '/home');
      } catch (error) {
        setState(() {
          errorMessage = error;
        });
      }
    }
  }

  Future login() async {
    if (isPasswordFieldValid && isUsernameFieldValid) {
      try {
        await Store.defaultInstance.login(usernameController.text, passwordController.text);
        Navigator.pushNamed(context, '/home');
      } catch (error) {
        setState(() {
          errorMessage = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Login"),
      ),

      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(
            children: [
              new Row(children: [new Expanded(child: usernameField)]),
              new Row(children: [new Expanded(child: passwordField)]),
              new Row(children: [
                new FlatButton(onPressed: register, child: const Text("REGISTER")),
                new FlatButton(onPressed: login, child: const Text("LOGIN"))]),
                new Text(errorMessage)
            ]
        ),
      ),     
    );
  }
}