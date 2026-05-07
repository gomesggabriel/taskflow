import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

class ListaScreen extends StatelessWidget {
  const ListaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minhas Tarefas',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Todas'),
              Tab(text: 'Importantes'),
              Tab(text: 'Realizadas'),
              Tab(text: 'Pendentes'),
              Tab(text: 'Atrasadas'),
            ],
          ),
        ),
        body: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            return TabBarView(
              children: [
                _TaskList(tasks: provider.tasks.toList()),
                _TaskList(tasks: provider.importantes),
                _TaskList(tasks: provider.realizadas),
                _TaskList(tasks: provider.naoRealizadas),
                _TaskList(tasks: provider.atrasadas),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/inserir'),
          icon: const Icon(Icons.add),
          label: const Text('Nova tarefa'),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;

  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Nenhuma tarefa aqui',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => Navigator.pushNamed(context, '/detalhe',
              arguments: task),
          onDelete: () =>
              context.read<TaskProvider>().deleteTask(task.id!),
        );
      },
    );
  }
}
