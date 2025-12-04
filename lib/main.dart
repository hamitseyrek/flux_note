import 'package:flutter/material.dart';
import 'package:flux_note/data/datasources/in_memory_note_data_source.dart';
import 'package:flux_note/data/repositories/note_repository_imp.dart';
import 'package:flux_note/domain/usecases/add_note.dart';
import 'package:flux_note/domain/usecases/delete_note.dart';
import 'package:flux_note/domain/usecases/get_notes.dart';
import 'package:flux_note/domain/usecases/update_note.dart';
import 'package:flux_note/presentation/viewmodels/home_view_model.dart';
import 'package:flux_note/presentation/views/home_page.dart';

void main() {
  final dataSource = InMemoryNoteDataSource();
  final repository = NoteRepositoryImp(dataSource);

  final getNotes = GetNotes(noteRepository: repository);
  final addNote = AddNote(repository);
  final updateNote = UpdateNote(repository);
  final deleteNote = DeleteNote(repository);

  final homeViewModel = HomeViewModel(
    getNotes: getNotes,
    addNote: addNote,
    deleteNote: deleteNote,
    updateNote: updateNote,
  );

  runApp(MyApp(
    homeViewModel: homeViewModel,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,
  required this.homeViewModel,
  });
  final HomeViewModel homeViewModel;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(homeViewModel: homeViewModel));
  }
}
