import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF820AD1), Color(0xFFBB6BD9)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(60, 60),
                          painter: _AlvoComDardoPainter(
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'TaskFlow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Gerencie suas tarefas com eficiência',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/lista'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          padding:
                              const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 16,
                child: Consumer<TaskProvider>(
                  builder: (context, provider, _) {
                    final pendentes = provider.tasks
                        .where((t) => !t.realizada)
                        .toList()
                      ..sort((a, b) =>
                          a.dataDateTime.compareTo(b.dataDateTime));
                    final count = pendentes.length;
                    return _NotificacaoBotao(
                      pendentes: pendentes,
                      count: count,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlvoComDardoPainter extends CustomPainter {
  final Color color;
  _AlvoComDardoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.width * 0.068;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width * 0.41;
    final cy = size.height * 0.57;
    final center = Offset(cx, cy);

    canvas.drawCircle(center, size.width * 0.37, strokePaint);
    canvas.drawCircle(center, size.width * 0.25, strokePaint);
    canvas.drawCircle(center, size.width * 0.12, strokePaint);

    final tail = Offset(size.width * 0.87, size.height * 0.13);

    canvas.drawLine(tail, center, strokePaint);

    final barrelStart = Offset.lerp(center, tail, 0.27)!;
    final barrelEnd = Offset.lerp(center, tail, 0.43)!;
    final barrelPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw * 2.8
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(barrelStart, barrelEnd, barrelPaint);

    final dx = tail.dx - center.dx;
    final dy = tail.dy - center.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    final px = -dy / len;
    final py = dx / len;

    final flightLen = size.width * 0.13;
    final f1 = Offset(tail.dx + px * flightLen, tail.dy + py * flightLen);
    final f2 = Offset(tail.dx - px * flightLen, tail.dy - py * flightLen);
    final flightBase = Offset.lerp(center, tail, 0.82)!;

    canvas.drawLine(tail, f1, strokePaint);
    canvas.drawLine(tail, f2, strokePaint);
    canvas.drawLine(f1, flightBase, strokePaint);
    canvas.drawLine(f2, flightBase, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotificacaoBotao extends StatelessWidget {
  final List<Task> pendentes;
  final int count;

  const _NotificacaoBotao({
    required this.pendentes,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarNotificacoes(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4757),
                  shape: BoxShape.circle,
                ),
                constraints:
                    const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _mostrarNotificacoes(BuildContext context) {
    final RenderBox renderBox =
        context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              top: offset.dy + size.height + 8,
              right: MediaQuery.of(context).size.width -
                  offset.dx -
                  size.width,
              child: Material(
                color: Colors.transparent,
                child: _PainelNotificacoes(
                  pendentes: pendentes,
                  onClose: () => Navigator.pop(ctx),
                  onTaskTap: (task) {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/lista',
                        arguments: task.dataDateTime);
                  },
                  onNavegar: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/lista');
                  },
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, -0.1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}

class _PainelNotificacoes extends StatelessWidget {
  final List<Task> pendentes;
  final VoidCallback onClose;
  final void Function(Task) onTaskTap;
  final VoidCallback onNavegar;

  const _PainelNotificacoes({
    required this.pendentes,
    required this.onClose,
    required this.onTaskTap,
    required this.onNavegar,
  });

  @override
  Widget build(BuildContext context) {
    final proximas = pendentes.take(5).toList();

    return Container(
      width: 300,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: const BoxDecoration(
              color: Color(0xFF820AD1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Próximas Tarefas',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close,
                      color: Colors.white70, size: 18),
                ),
              ],
            ),
          ),
          if (pendentes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.celebration_outlined,
                      size: 40, color: Color(0xFF820AD1)),
                  SizedBox(height: 10),
                  Text(
                    'Nenhuma tarefa pendente! 🎉',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: proximas.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, i) {
                  final task = proximas[i];
                  final hoje = DateTime.now();
                  final hojeNorm =
                      DateTime(hoje.year, hoje.month, hoje.day);
                  final dataTask = DateTime(
                    task.dataDateTime.year,
                    task.dataDateTime.month,
                    task.dataDateTime.day,
                  );
                  final diff = dataTask.difference(hojeNorm).inDays;

                  String labelData;
                  Color corData;
                  if (diff < 0) {
                    labelData = 'Atrasada ${-diff}d';
                    corData = const Color(0xFFE53935);
                  } else if (diff == 0) {
                    labelData = 'Hoje';
                    corData = const Color(0xFFFF6B35);
                  } else if (diff == 1) {
                    labelData = 'Amanhã';
                    corData = const Color(0xFFFF9800);
                  } else {
                    labelData =
                        DateFormat('dd/MM').format(task.dataDateTime);
                    corData = const Color(0xFF820AD1);
                  }

                  return InkWell(
                    onTap: () => onTaskTap(task),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 36,
                            decoration: BoxDecoration(
                              color: task.importante
                                  ? const Color(0xFF820AD1)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.titulo,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 11, color: corData),
                                    const SizedBox(width: 3),
                                    Text(
                                      labelData,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: corData,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    if (task.importante) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.star,
                                          size: 11,
                                          color: Color(0xFF820AD1)),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              size: 16, color: Color(0xFF820AD1)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            InkWell(
              onTap: onNavegar,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF820AD1).withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ver todas as tarefas',
                      style: TextStyle(
                        color: Color(0xFF820AD1),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color(0xFF820AD1)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
