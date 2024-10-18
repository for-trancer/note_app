import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:note_app_sample/data/data.dart';
import 'package:note_app_sample/data/note_model/note_model.dart';

enum ActionType {
  addNote,
  editNote,
}

class ScreenAddNote extends StatelessWidget {
  final ActionType type;
  final String? id;

  ScreenAddNote({
    super.key,
    required this.type,
    this.id,
  });

  Widget get saveButton => TextButton.icon(
        onPressed: () {
          switch (type) {
            case ActionType.addNote:
              saveNote();
              break;
            case ActionType.editNote:
              saveEditedNote();
              break;
          }
        },
        icon: const Icon(
          Icons.save,
          color: Colors.black,
        ),
        label: const Text(
          'Save',
          style: TextStyle(color: Colors.black),
        ),
      );

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (type == ActionType.editNote) {
      if (id == null) {
        Navigator.of(context).pop();
      }

      final note = NoteDB.instance.getNoteById(id!);
      if (note == null) {
        Navigator.of(context).pop();
      }

      _titleController.text = note!.title ?? 'No Title';
      _contentController.text = note.content ?? 'No Content';
    }
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(type.name.toUpperCase()),
          backgroundColor: Colors.yellow,
          actions: [
            saveButton,
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Title'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Content',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 10.0)),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    final newNote0 = NoteModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
    );

    final newNote = await NoteDB().createNote(newNote0);
    if (newNote != null) {
      await NoteDB.instance.getAllNotes();
      Navigator.of(_scaffoldKey.currentContext!).pop();
    } else {}
  }

  Future<void> saveEditedNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    final editedNote = NoteModel.create(
      id: id,
      title: title,
      content: content,
    );

    final note = await NoteDB.instance.updateNote(editedNote);
    if (note == null) {
    } else {
      Navigator.of(_scaffoldKey.currentContext!).pop();
      NoteDB.instance.noteListNotifier.notifyListeners();
    }
  }
}
