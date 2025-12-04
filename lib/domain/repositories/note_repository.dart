import 'package:flux_note/domain/entities/note_entity.dart';

abstract class NoteRepository {
  List<NoteEntity> getNotes();
  void addNote(NoteEntity note);
  void deleteNote(String noteId);
  void updateNote(NoteEntity note);
}