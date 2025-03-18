import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:todo_app/widgets/todo.dart';
import 'package:todo_app/widgets/todo_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Todo> _todos = [];
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _loadTodosFromFile();
  }

  Future<void> _loadTodosFromFile() async {
    List<Todo> todos = await TodoFileHelper.readTodosFromFile();
    setState(() {
      _todos.addAll(todos);
    });
  }

  void _addTodo() {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) return;

    setState(() {
      final newTodo = Todo(
        id: uuid.v4(),
        title: _titleController.text,
        description: _descController.text,
        createdAt: DateTime.now(),
        status: "Pending",
      );
      _todos.add(newTodo);
      TodoFileHelper.writeTodosToFile(_todos);
    });

    _titleController.clear();
    _descController.clear();
    Navigator.of(context).pop();
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
      TodoFileHelper.writeTodosToFile(_todos);
    });
  }

  void _toggleStatus(String id) {
    setState(() {
      final todo = _todos.firstWhere((todo) => todo.id == id);
      if (todo.status == "Pending") {
        todo.status = "Ready";
      } else if (todo.status == "Ready") {
        todo.status = "Completed";
      } else {
        todo.status = "Pending";
      }
      TodoFileHelper.writeTodosToFile(_todos);
    });
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
              child: Text('Add New Todo',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_titleController, 'Title'),
              SizedBox(height: 10.0),
              _buildTextField(_descController, 'Description'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: _addTodo,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      padding: EdgeInsets.only(left: 5.0),
      decoration: BoxDecoration(
          color: Color.fromARGB(20, 0, 0, 0),
          borderRadius: BorderRadius.circular(10.0)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            hintStyle: TextStyle(color: Colors.black54),
            border: InputBorder.none),
      ),
    );
  }

  Future<void> _uploadJson() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['json']);

    if (result != null) {
      try {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);

        List<Todo> uploadedTodos = [];
        for (var todoJson in jsonData) {
          Todo todo = Todo(
            id: todoJson['id'],
            title: todoJson['title'],
            description: todoJson['description'],
            createdAt:
                DateTime.fromMillisecondsSinceEpoch(todoJson['createdAt']),
            status: todoJson['status'],
          );
          uploadedTodos.add(todo);
        }

        setState(() {
          _todos.addAll(uploadedTodos);
        });

        TodoFileHelper.writeTodosToFile(_todos);
      } catch (e) {
        print("Error reading JSON file: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3.0,
        centerTitle: true,
        title: Text('Todo List',
            style: TextStyle(
                fontSize: 25.0,
                color: Colors.blue,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _uploadJson,
            tooltip: 'Upload JSON',
          ),
        ],
      ),
      body: Material(
        elevation: 5.0,
        child: ListView.builder(
          itemCount: _todos.length,
          itemBuilder: (context, index) {
            final todo = _todos[index];
            return Card(
              child: ListTile(
                title: Text(todo.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(todo.description),
                    Text(
                        'Created At: ${DateTime.fromMillisecondsSinceEpoch(todo.createdAt.millisecondsSinceEpoch)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('Status: ${todo.status}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check_circle,
                          color: _getStatusColor(todo.status)),
                      onPressed: () => _toggleStatus(todo.id),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTodo(todo.id),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == "Completed") {
      return Colors.green;
    } else if (status == "Ready") {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
