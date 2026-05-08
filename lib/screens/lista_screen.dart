import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import '../widgets/calendario_widget.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  int? _tabSelecionada;
  DateTime? _dataDestaque;
  bool _argLido = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argLido) {
      _argLido = true;
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is DateTime) {
        _dataDestaque = arg;
      }
    }
  }

  void _irParaData(DateTime data) {
    setState(() {
      _tabSelecionada = null;
      _dataDestaque = data;
    });
  }

  List<Task> _tarefasFiltradas(TaskProvider provider) {
    switch (_tabSelecionada) {
      case 0:
        return provider.importantes;
      case 1:
        return provider.realizadas;
      case 2:
        return provider.naoRealizadas;
      case 3:
        return provider.atrasadas;
      default:
        return provider.tasks.toList();
    }
  }

  String get _tituloFiltro {
    switch (_tabSelecionada) {
      case 0:
        return 'Importantes';
      case 1:
        return 'Realizadas';
      case 2:
        return 'Pendentes';
      case 3:
        return 'Atrasadas';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _tabSelecionada == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _tabSelecionada != null) {
          setState(() => _tabSelecionada = null);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'TaskFlow',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF820AD1),
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            Consumer<TaskProvider>(
              builder: (context, provider, _) {
                final pendentes = provider.tasks
                    .where((t) => !t.realizada)
                    .toList()
                  ..sort((a, b) =>
                      a.dataDateTime.compareTo(b.dataDateTime));
                return _NotificacaoBotaoAgenda(
                  pendentes: pendentes,
                  onIrParaData: _irParaData,
                );
              },
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: Color(0xFF820AD1)),
              tooltip: 'Criar Tarefa',
              onPressed: () =>
                  Navigator.pushNamed(context, '/inserir'),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            if (_tabSelecionada == null) {
              return CalendarioWidget(
                key: ValueKey(_dataDestaque),
                tasks: provider.tasks.toList(),
                onTaskTap: (task) => Navigator.pushNamed(
                    context, '/detalhe',
                    arguments: task),
                initialDate: _dataDestaque,
              );
            }

            final lista = _tarefasFiltradas(provider);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Text(
                    _tituloFiltro,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF820AD1),
                    ),
                  ),
                ),
                Expanded(
                  child: lista.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma tarefa aqui',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          itemCount: lista.length,
                          itemBuilder: (context, index) {
                            final task = lista[index];
                            return TaskCard(
                              task: task,
                              onTap: () => Navigator.pushNamed(
                                  context, '/detalhe',
                                  arguments: task),
                              onDelete: () => context
                                  .read<TaskProvider>()
                                  .deleteTask(task.id!),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: _BarraInferior(
          selecionado: _tabSelecionada,
          onTap: (index) {
            setState(() {
              _tabSelecionada =
                  _tabSelecionada == index ? null : index;
            });
          },
        ),
      ),
    );
  }
}

class _BarraInferior extends StatelessWidget {
  final int? selecionado;
  final ValueChanged<int> onTap;

  const _BarraInferior({
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itens = [
      const _ItemBarra(
        icone: Icons.star_outline_rounded,
        iconeAtivo: Icons.star_rounded,
        label: 'Importantes',
        cor: Color(0xFFFF6B35),
      ),
      const _ItemBarra(
        icone: Icons.check_circle_outline_rounded,
        iconeAtivo: Icons.check_circle_rounded,
        label: 'Realizadas',
        cor: Color(0xFF43A047),
      ),
      const _ItemBarra(
        icone: Icons.hourglass_empty_rounded,
        iconeAtivo: Icons.hourglass_bottom_rounded,
        label: 'Pendentes',
        cor: Color(0xFF1976D2),
      ),
      const _ItemBarra(
        icone: Icons.warning_amber_rounded,
        iconeAtivo: Icons.warning_rounded,
        label: 'Atrasadas',
        cor: Color(0xFFE53935),
      ),
    ];

    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final contagens = [
          provider.importantes.length,
          provider.realizadas.length,
          provider.naoRealizadas.length,
          provider.atrasadas.length,
        ];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: List.generate(itens.length, (i) {
                  final item = itens[i];
                  final ativo = selecionado == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  child: Icon(
                                    ativo
                                        ? item.iconeAtivo
                                        : item.icone,
                                    key: ValueKey(ativo),
                                    color: ativo
                                        ? item.cor
                                        : Colors.grey.shade400,
                                    size: 26,
                                  ),
                                ),
                                if (contagens[i] > 0)
                                  Positioned(
                                    top: -4,
                                    right: -6,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: ativo
                                            ? item.cor
                                            : Colors.grey.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                          minWidth: 16, minHeight: 16),
                                      child: Text(
                                        '${contagens[i]}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration:
                                  const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: ativo
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: ativo
                                    ? item.cor
                                    : Colors.grey.shade500,
                              ),
                              child: Text(item.label),
                            ),
                            AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(top: 4),
                              height: 3,
                              width: ativo ? 28 : 0,
                              decoration: BoxDecoration(
                                color: item.cor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ItemBarra {
  final IconData icone;
  final IconData iconeAtivo;
  final String label;
  final Color cor;

  const _ItemBarra({
    required this.icone,
    required this.iconeAtivo,
    required this.label,
    required this.cor,
  });
}

class _NotificacaoBotaoAgenda extends StatelessWidget {
  final List<Task> pendentes;
  final void Function(DateTime) onIrParaData;

  const _NotificacaoBotaoAgenda({
    required this.pendentes,
    required this.onIrParaData,
  });

  @override
  Widget build(BuildContext context) {
    final count = pendentes.length;
    return GestureDetector(
      onTap: () => _mostrarNotificacoes(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.notifications_outlined,
                color: Color(0xFF820AD1)),
          ),
          if (count > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4757),
                  shape: BoxShape.circle,
                ),
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
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
              top: offset.dy + size.height + 4,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: _PainelNotificacoes(
                  pendentes: pendentes,
                  onClose: () => Navigator.pop(ctx),
                  onTaskTap: (task) {
                    Navigator.pop(ctx);
                    onIrParaData(task.dataDateTime);
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

  const _PainelNotificacoes({
    required this.pendentes,
    required this.onClose,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    final proximas = pendentes.take(5).toList();

    return Container(
      width: 290,
      constraints: const BoxConstraints(maxHeight: 380),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
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
          else
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
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
        ],
      ),
    );
  }
}
