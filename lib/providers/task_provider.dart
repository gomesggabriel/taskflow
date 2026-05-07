import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> get importantes => _tasks.where((t) => t.importante).toList();
  List<Task> get naoImportantes => _tasks.where((t) => !t.importante).toList();
  List<Task> get realizadas => _tasks.where((t) => t.realizada).toList();
  List<Task> get naoRealizadas => _tasks.where((t) => !t.realizada).toList();
  List<Task> get atrasadas => _tasks.where((t) => t.atrasada).toList();
  List<Task> get naoAtrasadas => _tasks.where((t) => !t.atrasada).toList();


  Task? get proximaTarefa {
    final pendentes = _tasks.where((t) => !t.realizada).toList();
    if (pendentes.isEmpty) return null;
    pendentes.sort((a, b) => a.dataDateTime.compareTo(b.dataDateTime));
    return pendentes.first;
  }

  Future<void> loadTasks() async {
    _tasks = await DatabaseHelper.instance.readAllTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final created = await DatabaseHelper.instance.create(task);
    _tasks.add(created);
    _sortTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await DatabaseHelper.instance.update(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
    _sortTasks();
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseHelper.instance.delete(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> marcarRealizada(Task task) async {
    final atualizada = task.copyWith(realizada: true);
    await updateTask(atualizada);
  }

  void _sortTasks() {
    _tasks.sort((a, b) => a.dataDateTime.compareTo(b.dataDateTime));
  }
}
