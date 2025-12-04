import 'package:flux_note/domain/entities/note_entity.dart';
import 'package:flux_note/domain/repositories/note_repository.dart';

class AddNote {
  final NoteRepository repository;
  AddNote(this.repository);

  void call(NoteEntity note) => repository.addNote(note);
}