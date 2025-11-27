class Note {
  final int id;
  final String title;

  Note({
    required this.id,
    required this.title,
  });

  Note copyWith({int? id,String? title}) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}