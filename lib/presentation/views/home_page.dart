import 'package:flutter/material.dart';
import 'package:flux_note/domain/entities/note_entity.dart';
import 'package:flux_note/presentation/views/common/app_dialog.dart';
import 'package:flux_note/presentation/viewmodels/home_view_model.dart';

class HomePage extends StatelessWidget {
  final HomeViewModel _homeViewModel;
  const HomePage({Key? key, required HomeViewModel homeViewModel})
    : _homeViewModel = homeViewModel,
      super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Flux Note App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search Notes',
              ),
              onChanged: (value) {
                _homeViewModel.searchNotes(value);
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListenableBuilder(
                listenable: _homeViewModel,
                builder: (context, child) {
                  if (_homeViewModel.filteredNotes.isEmpty) {
                    return const Center(child: Text('No notes available.'));
                  }
                  return ListView.builder(
                    itemCount: _homeViewModel.filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = _homeViewModel.filteredNotes[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                        ),
                        title: Text(note.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                NoteDialogs.showEditNoteDialog(
                                  context,
                                  note.title,
                                  onSave: (newTitle) {
                                    final updatedNote = note.copyWith(
                                      title: newTitle,
                                    );
                                    _homeViewModel.updateNote(updatedNote);
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            GestureDetector(
                              onTap: () {
                                _homeViewModel.deleteNote(note.id);
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NoteDialogs.showAddNoteDialog(context, (title) {
            final newNote = NoteEntity(
              id: _homeViewModel.notes.length + 1,
              title: title,
            );
            _homeViewModel.addNote(newNote);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
