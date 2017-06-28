# chat

An application built with [aqueduct](https://github.com/stablekernel/aqueduct).

Ensure that the `aqueduct` tool is installed:

```
pub global activate aqueduct
```

Run the server from this directory:

```
aqueduct serve
```

Connect multiple chat clients:

```
dart bin/client.dart
```

Enter text into the client or use `/name <name>` to name the connected user.
