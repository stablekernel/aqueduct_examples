# todo

An application built with [aqueduct](https://github.com/stablekernel/aqueduct).

## First Time Setup

Create a PostgreSQL database with the following information:

```
username: todo
password: todo
host: localhost
port: 5432
databaseName: todo_app
```

Here's an example of the SQL to do that:

```
CREATE DATABASE todo_app;
CREATE USER todo WITH PASSWORD 'todo';
GRANT ALL ON DATABASE todo_app TO todo;
```

Run the database migration to set the initial schema:

```
aqueduct db upgrade --connect postgres://todo:todo@localhost:5432/todo_app
```

Add an OAuth 2.0 Client:

```
aqueduct auth add-client --id com.dart.demo --secret abcd --connect postgres://todo:todo@localhost:5432/todo_app
```

## Run the Application

Either run the following in this directory:

```
aqueduct serve
```

Or

```
dart bin/main.dart
```
