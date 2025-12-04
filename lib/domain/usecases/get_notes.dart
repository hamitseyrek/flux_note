import 'package:flux_note/domain/entities/note_entity.dart';
import 'package:flux_note/domain/repositories/note_repository.dart';

class GetNotes {
  final NoteRepository noteRepository;
  GetNotes({required this.noteRepository});
  List<NoteEntity> call() => noteRepository.getNotes();
}