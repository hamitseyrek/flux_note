import 'package:flux_note/domain/repositories/note_repository.dart';

class DeleteNote {
  final NoteRepository repository;
  DeleteNote(this.repository);

  void call(String noteId) => repository.deleteNote(noteId);
}