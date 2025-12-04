import 'package:flux_note/domain/entities/note_entity.dart';

class InMemoryNoteDataSource {
  final List<NoteEntity> _notes = [];

  List<NoteEntity> getNotes() {
    return List.unmodifiable(_notes);
  }
  void addNote(NoteEntity note) {
    _notes.add(note);
  }
  void deleteNote(String noteId) {
    _notes.removeWhere((note) => note.id.toString() == noteId);
  }
  void updateNote(NoteEntity updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
    }
  }
}