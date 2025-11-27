
import 'package:flutter/material.dart';
import 'package:flux_note/app_dialog.dart';
import 'package:flux_note/home_view_model.dart';
import 'package:flux_note/note_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
late final HomeViewModel _homeViewModel;

@override
  void initState() {
    super.initState();
    _homeViewModel = HomeViewModel()..addListener(() {
      setState(() {});
    });
  }

@override
  void dispose() {
    _homeViewModel.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Flux Note App'),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0),
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
          Expanded(child: _homeViewModel.filteredNotes.isEmpty
              ? const Center(child: Text('No notes available.'))
              : ListView.builder(
            itemCount: _homeViewModel.filteredNotes.length,
            itemBuilder: (context, index) {
              final note = _homeViewModel.filteredNotes[index];
              return ListTile(
                title: Text(note.title),
              );
            },
          )),
        ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NoteDialogs.showAddNoteDialog(
            context,
            (title) {
              final newNote = Note(
                id: _homeViewModel.notes.length + 1,
                title: title,
              );
              setState(() {
                _homeViewModel.addNote(newNote);
              });
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}