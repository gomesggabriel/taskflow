import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

/// Custom card widget for displaying a task in the list
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool atrasada = task.atrasada;

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Excluir tarefa'),
            content: Text('Deseja excluir "${task.titulo}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Excluir',
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: atrasada
                  ? Colors.red.shade300
                  : task.realizada
                      ? Colors.green.shade200
                      : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_statusIcon(), color: _statusColor(), size: 24),
                ),
                const SizedBox(width: 14),
                // Title and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.titulo,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                decoration: task.realizada
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.realizada
                                    ? Colors.grey
                                    : theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (task.importante)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 18),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 13,
                              color: atrasada
                                  ? Colors.red
                                  : Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.dataPrevista),
                            style: TextStyle(
                              fontSize: 12,
                              color: atrasada
                                  ? Colors.red.shade600
                                  : Colors.grey.shade600,
                              fontWeight: atrasada
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          if (atrasada) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Atrasada',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Priority badge
                PriorityBadge(prioridade: task.prioridade),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor() {
    if (task.realizada) return Colors.green;
    if (task.atrasada) return Colors.red;
    if (task.importante) return Colors.amber.shade700;
    return Colors.blue;
  }

  IconData _statusIcon() {
    if (task.realizada) return Icons.check_circle_outline;
    if (task.atrasada) return Icons.warning_amber_rounded;
    if (task.importante) return Icons.star_outline_rounded;
    return Icons.radio_button_unchecked;
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}

/// Reusable priority badge widget
class PriorityBadge extends StatelessWidget {
  final String prioridade;

  const PriorityBadge({super.key, required this.prioridade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _textColor(),
        ),
      ),
    );
  }

  String _label() {
    switch (prioridade) {
      case 'alta':
        return 'ALTA';
      case 'baixa':
        return 'BAIXA';
      default:
        return 'MÉDIA';
    }
  }

  Color _bgColor() {
    switch (prioridade) {
      case 'alta':
        return Colors.red.shade50;
      case 'baixa':
        return Colors.green.shade50;
      default:
        return Colors.orange.shade50;
    }
  }

  Color _textColor() {
    switch (prioridade) {
      case 'alta':
        return Colors.red.shade700;
      case 'baixa':
        return Colors.green.shade700;
      default:
        return Colors.orange.shade800;
    }
  }
}

/// Reusable styled button
class AppButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: c,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    );
  }
}

/// Reusable form field with label
class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.blueGrey)),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 16),
      ],
    );
  }
}
