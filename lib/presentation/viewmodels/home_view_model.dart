import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flux_note/domain/entities/note_entity.dart';
import 'package:flux_note/domain/usecases/add_note.dart';
import 'package:flux_note/domain/usecases/delete_note.dart';
import 'package:flux_note/domain/usecases/get_notes.dart';
import 'package:flux_note/domain/usecases/update_note.dart';

class HomeViewModel extends ChangeNotifier {

  HomeViewModel({
    required GetNotes getNotes,
    required AddNote addNote,
    required DeleteNote deleteNote,
    required UpdateNote updateNote,
  }) : _getNotes = getNotes,
       _addNote = addNote,
       _deleteNote = deleteNote,
       _updateNote = updateNote {
    _loadNotes();
  }

  final GetNotes _getNotes;
  final AddNote _addNote;
  final DeleteNote _deleteNote;
  final UpdateNote _updateNote;

  String query = '';
  Timer? _debounceTimer;
  List<NoteEntity> _notes = [];
  List<NoteEntity> get notes => List.unmodifiable(_notes);

  List<NoteEntity> get filteredNotes {
    if (query.isEmpty) {
      return _getNotes();
    } else {
      return _getNotes()
          .where(
            (note) => note.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  void searchNotes(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      query = value;
      _loadNotes();
    });
  }

  void _loadNotes() {
debugPrint('Notes loaded1: ${_notes.length} items');
    _notes = filteredNotes;
debugPrint('Notes loaded2: ${_notes.length} items');
    notifyListeners();
  }

  void addNote(NoteEntity note) {
    _addNote(note);
    _loadNotes();
  }

  void updateNote(NoteEntity updatedNote) {
    _updateNote(updatedNote);
    _loadNotes();
  }

  void deleteNote(int id) {
    _deleteNote(id.toString());
    _loadNotes();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
