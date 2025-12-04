import 'package:flux_note/domain/entities/note_entity.dart';
import 'package:flux_note/domain/repositories/note_repository.dart';

class UpdateNote {
  final NoteRepository repository;
  UpdateNote(this.repository);

  void call(NoteEntity note) => repository.updateNote(note);
}