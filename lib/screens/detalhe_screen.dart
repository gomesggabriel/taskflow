import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class DetalheScreen extends StatelessWidget {
  const DetalheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)!.settings.arguments as Task;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () =>
                Navigator.pushNamed(context, '/editar', arguments: task)
                    .then((_) => Navigator.pop(context)),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final current = provider.tasks
              .cast<Task?>()
              .firstWhere((t) => t?.id == task.id, orElse: () => null);

          if (current == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) {
                Navigator.popUntil(context, ModalRoute.withName('/lista'));
              }
            });
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBanner(task: current),
                const SizedBox(height: 20),
                _InfoCard(
                  icon: Icons.title_rounded,
                  label: 'Título',
                  value: current.titulo,
                  valueStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.tag_rounded,
                  label: 'ID',
                  value: '#${current.id}',
                  valueStyle:
                      TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.description_outlined,
                  label: 'Descrição',
                  value: current.descricao.isEmpty
                      ? 'Sem descrição'
                      : current.descricao,
                  valueStyle: const TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.calendar_month_outlined,
                  label: 'Data prevista',
                  value: DateFormat('dd/MM/yyyy')
                      .format(current.dataDateTime),
                  valueStyle: TextStyle(
                    fontSize: 16,
                    color: current.atrasada
                        ? Colors.red.shade700
                        : theme.colorScheme.onSurface,
                    fontWeight: current.atrasada
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8)
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: Colors.blueGrey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Prioridade',
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            PriorityBadge(
                              prioridade: current.prioridade,
                              importante: current.importante,
                            ),
                          ],
                        ),
                      ),
                      if (current.importante)
                        const Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text('Importante',
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (!current.realizada)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await provider.marcarRealizada(current);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tarefa marcada como realizada! ✅'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                      label: const Text('Marcar como Realizada',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 10),
                        Text('Tarefa já realizada!',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Excluir tarefa'),
                          content: const Text(
                              'Tem certeza que deseja excluir esta tarefa?'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar')),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: Text('Excluir',
                                    style: TextStyle(
                                        color: theme.colorScheme.error))),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await provider.deleteTask(current.id!);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Excluir Tarefa',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Task task;
  const _StatusBanner({required this.task});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (task.realizada) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
      icon = Icons.check_circle_outline;
      label = 'Realizada';
    } else if (task.atrasada) {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
      icon = Icons.warning_amber_rounded;
      label = 'Atrasada';
    } else {
      bg = const Color(0xFFF3E8FF);
      fg = const Color(0xFF820AD1);
      icon = Icons.pending_outlined;
      label = 'Pendente';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: valueStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
