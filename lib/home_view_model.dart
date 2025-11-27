import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flux_note/note_model.dart';

class HomeViewModel extends ChangeNotifier {
  String query = '';
  Timer? _debounceTimer;
  List<Note> notes = [];
  List<Note> get filteredNotes {
    if (query.isEmpty) {
      return notes;
    } else {
      return notes
          .where(
            (note) => note.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  void searchNotes(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 5000), () {
      query = value;
      notifyListeners();
    });
  }

  void addNote(Note note) {
    notes.add(note);
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final index = notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      notes[index] = updatedNote;
      notifyListeners();
    }
  }

  void deleteNote(int id) {
    notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
