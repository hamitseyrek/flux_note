class NoteEntity {
  final int id;
  final String title;

  NoteEntity({
    required this.id,
    required this.title,
  });

  NoteEntity copyWith({int? id,String? title}) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}