# Todo App

A simple Todo application built with **Flutter** that allows users to create, view, update, delete, and manage tasks. The app uses **local storage (CSV files)** to persist todos and includes functionality for uploading a **JSON file** to add a list of todos.

## Features

- **Create Todo**: Add new todos with a title, description, and status.
- **View Todos**: Display all the todos in a list with the title, description, creation date, and current status.
- **Update Todo Status**: Change the status of a todo between "Pending", "Ready", and "Completed".
- **Delete Todo**: Remove todos from the list.
- **Local Storage**: Todos are saved in a **CSV** file stored locally on the device.
- **Upload Todos**: Allows users to upload a **JSON** file containing todos and add them to the current todo list.

## Requirements

- **Flutter SDK** (version 3.0 or later)
- **Dart** (version 2.14 or later)

### Dependencies:

- `path_provider`: To access the device’s storage.
- `csv`: To read and write CSV files.
- `uuid`: To generate unique identifiers for each todo.
- `file_picker`: To upload a JSON file.
- `json`: To parse JSON file contents.

## Installation

### Clone the Repository

```bash
git clone https://github.com/AvijitDasAvi/todo-app.git
cd todo-app
