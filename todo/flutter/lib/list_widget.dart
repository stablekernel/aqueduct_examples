import 'package:flutter/material.dart';
import 'package:todo_shared/shared.dart';

class NotesWidget extends StatefulWidget {
  NotesWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NotesWidgetState createState() => new _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  @override
  void initState() {
    super.initState();
    Store.defaultInstance.getNotes().then((_) => setState((){}));
  }

  void createNewNote() {
    Navigator.pushNamed(context, "/create");
  }

  List<TableRow> get tableRows =>
      Store.defaultInstance.user.notes.map(noteRowForNote).toList();

  TableRow noteRowForNote(Note note) {
    return new TableRow(
        children: [
          new Container(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              child: new Text(note.title)
          )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        padding: const EdgeInsets.all(20.0),
        child: new Table(
            children: tableRows
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: createNewNote,
        tooltip: 'Create',
        child: new Icon(Icons.add),
      ),
    );
  }
}
