import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:todo_app/widgets/todo.dart';

class TodoFileHelper {
  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/todos.csv');
  }

  static Future<void> writeTodosToFile(List<Todo> todos) async {
    final file = await _getLocalFile();
    List<List<String>> rows = [
      ["ID", "Title", "Description", "CreatedAt", "Status"], // Headers
    ];

    for (var todo in todos) {
      rows.add([
        todo.id,
        todo.title,
        todo.description,
        todo.createdAt.millisecondsSinceEpoch.toString(),
        todo.status
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
  }

  static Future<List<Todo>> readTodosFromFile() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) return [];

      final csvString = await file.readAsString();
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvString);

      List<Todo> todos = [];

      if (csvTable.isNotEmpty) {
        for (var i = 1; i < csvTable.length; i++) {
          int? milliseconds;
          if (csvTable[i][3] != null && csvTable[i][3].isNotEmpty) {
            milliseconds = int.tryParse(csvTable[i][3].toString());
          }

          DateTime createdAt = (milliseconds != null)
              ? DateTime.fromMillisecondsSinceEpoch(milliseconds)
              : DateTime.now();

          todos.add(Todo(
            id: csvTable[i][0],
            title: csvTable[i][1],
            description: csvTable[i][2],
            createdAt: createdAt,
            status: csvTable[i][4],
          ));
        }
      }

      return todos;
    } catch (e) {
      print("Error reading todos from file: $e");
      return [];
    }
  }
}
