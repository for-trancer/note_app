import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:note_app_sample/data/data.dart';
import 'package:note_app_sample/data/note_model/note_model.dart';
import 'package:note_app_sample/screens/screen_add_note.dart';

class ScreenAllNotes extends StatelessWidget {
  const ScreenAllNotes({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NoteDB.instance.getAllNotes();
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note App'),
        backgroundColor: Colors.yellow,
      ),
      body: ValueListenableBuilder(
        valueListenable: NoteDB.instance.noteListNotifier,
        builder: (context, List<NoteModel> newNotes, _) {
          if (newNotes.isEmpty) {
            return const Center(
              child: Text('Note List Is Empty'),
            );
          }
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: const EdgeInsets.all(20.0),
            children: List.generate(newNotes.length, (index) {
              final note = NoteDB.instance.noteListNotifier.value[index];
              if (note.id == null) {
                return const SizedBox();
              }
              return NoteItem(
                id: note.id!,
                title: note.title ?? 'No Title',
                content: note.content ?? 'No Content',
              );
            }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => ScreenAddNote(type: ActionType.addNote)));
        },
        label: const Text('Add Note'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class NoteItem extends StatelessWidget {
  final String id;
  final String title;
  final String content;

  const NoteItem({
    super.key,
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => ScreenAddNote(
                  type: ActionType.editNote,
                  id: id,
                )));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    NoteDB.instance.deleteNote(id);
                  },
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                )
              ],
            ),
            Text(
              content,
              maxLines: 5,
              style: const TextStyle(
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
