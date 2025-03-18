class Todo {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  String status;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
  });
}
