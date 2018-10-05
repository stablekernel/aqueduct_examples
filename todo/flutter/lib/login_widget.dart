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
  StreamSubscription userSubscription;

  TextField get usernameField =>
      new TextField(
        keyboardType: TextInputType.emailAddress,
        controller: usernameController,
        decoration: new InputDecoration(
            hintText: 'username'
        ),
      );

  TextField get passwordField =>
      new TextField(
        obscureText: true,
        controller: passwordController,
        decoration: new InputDecoration(
            hintText: 'password'
        ),
      );

  @override
  void initState() {
    super.initState();

    userSubscription = Store.instance.userController.listen((user) {
      if (mounted && user != null) {
        Navigator.pop(context);
      }
    }, onError: (Object err) {
      setState(() {
        errorMessage = err.toString();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    userSubscription.cancel();
  }

  void register() {
    if (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      Store.instance.userController.register(
            usernameController.text, passwordController.text);
    } else {
      setState(() {
        errorMessage = "Missing username and/or password.";
      });
    }
  }

  void login() {
    if (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      Store.instance.userController.login(
          usernameController.text, passwordController.text);
    } else {
      setState(() {
        errorMessage = "Missing username and/or password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(
            children: [
              new Center(child: new Row(children: [new Expanded(child: usernameField)])),
              new Row(children: [new Expanded(child: passwordField)]),
              new Row(children: [
                new FlatButton(onPressed: register, child: const Text("REGISTER")),
                new FlatButton(onPressed: login, child: const Text("LOGIN"))]),
                new Text(errorMessage, style: new TextStyle(color: Colors.red),)
            ]
        ),
      ),     
    );
  }
}