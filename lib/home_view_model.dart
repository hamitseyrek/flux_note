
import 'package:flutter/material.dart';
import 'package:flux_note/note_model.dart';

class HomeViewModel extends ChangeNotifier {
String query = '';
  
  List<Note> notes = [];
List<Note> get filteredNotes {
    if (query.isEmpty) {
      return notes;
    } else {
      return notes
          .where((note) => note.title.toLowerCase().contains(query.toLowerCase()))
          .toList(); 
    }
  }

  void searchNotes(String value) {
    query = value;
    notifyListeners();
  }

  void addNote(Note note) {
    notes.add(note);
    notifyListeners();
  }
}