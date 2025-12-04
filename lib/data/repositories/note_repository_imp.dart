import 'package:flux_note/data/datasources/in_memory_note_data_source.dart';
import 'package:flux_note/domain/entities/note_entity.dart';
import 'package:flux_note/domain/repositories/note_repository.dart';

class NoteRepositoryImp implements NoteRepository {
  final InMemoryNoteDataSource dataSource;

  NoteRepositoryImp(this.dataSource);

  @override
  List<NoteEntity> getNotes() {
    return dataSource.getNotes();
  }

  @override
  void addNote(NoteEntity note) {
    dataSource.addNote(note);
  }

  @override
  void deleteNote(String noteId) {
    dataSource.deleteNote(noteId);
  }

  @override
  void updateNote(NoteEntity note) {
    dataSource.updateNote(note);
  }
}