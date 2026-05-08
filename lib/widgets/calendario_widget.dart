import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class CalendarioWidget extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onTaskTap;

  const CalendarioWidget({
    super.key,
    required this.tasks,
    required this.onTaskTap,
  });

  @override
  State<CalendarioWidget> createState() => _CalendarioWidgetState();
}

class _CalendarioWidgetState extends State<CalendarioWidget> {
  late DateTime _mesSelecionado;
  late DateTime _diaSelecionado;
  late PageController _pageController;
  int _paginaInicial = 600;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _mesSelecionado = DateTime(agora.year, agora.month);
    _diaSelecionado = DateTime(agora.year, agora.month, agora.day);
    _pageController = PageController(initialPage: _paginaInicial);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _mesFromPagina(int pagina) {
    final diff = pagina - _paginaInicial;
    final agora = DateTime.now();
    int mes = agora.month + diff;
    int ano = agora.year;
    while (mes > 12) {
      mes -= 12;
      ano++;
    }
    while (mes < 1) {
      mes += 12;
      ano--;
    }
    return DateTime(ano, mes);
  }

  List<Task> _tasksNoDia(DateTime dia) {
    return widget.tasks.where((t) {
      try {
        final dt = DateTime.parse(t.dataPrevista);
        return dt.year == dia.year && dt.month == dia.month && dt.day == dia.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Color _prioridadeCor(String prioridade, bool importante) {
    switch (prioridade) {
      case 'baixa':
        return const Color(0xFF43A047);
      case 'alta':
        return importante ? const Color(0xFF8B0000) : const Color(0xFFE53935);
      default:
        return const Color(0xFFFDD835);
    }
  }

  Color _corDoDia(DateTime dia) {
    final tasks = _tasksNoDia(dia).where((t) => !t.realizada).toList();
    if (tasks.isEmpty) return Colors.transparent;

    bool temEmergencia = tasks.any((t) => t.prioridade == 'alta' && t.importante);
    if (temEmergencia) return const Color(0xFF8B0000);

    bool temAlta = tasks.any((t) => t.prioridade == 'alta');
    if (temAlta) return const Color(0xFFE53935);

    bool temMedia = tasks.any((t) => t.prioridade == 'media');
    if (temMedia) return const Color(0xFFFDD835);

    return const Color(0xFF43A047);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CabecalhoMes(
          mes: _mesSelecionado,
          onAnterior: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          onProximo: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          onHoje: () {
            final agora = DateTime.now();
            setState(() {
              _mesSelecionado = DateTime(agora.year, agora.month);
              _diaSelecionado = DateTime(agora.year, agora.month, agora.day);
            });
            _pageController.animateToPage(
              _paginaInicial,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
        ),
        const _DiasSemanaCabecalho(),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (pagina) {
              final novoMes = _mesFromPagina(pagina);
              setState(() {
                _mesSelecionado = novoMes;
                if (_diaSelecionado.year != novoMes.year ||
                    _diaSelecionado.month != novoMes.month) {
                  _diaSelecionado = novoMes;
                }
              });
            },
            itemBuilder: (context, pagina) {
              final mes = _mesFromPagina(pagina);
              return _GradeMes(
                mes: mes,
                diaSelecionado: _diaSelecionado,
                corDoDia: _corDoDia,
                tasksNoDia: _tasksNoDia,
                onDiaTap: (dia) {
                  setState(() => _diaSelecionado = dia);
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _ListaDoDia(
            dia: _diaSelecionado,
            tasks: _tasksNoDia(_diaSelecionado),
            onTaskTap: widget.onTaskTap,
            prioridadeCor: _prioridadeCor,
          ),
        ),
      ],
    );
  }
}

class _CabecalhoMes extends StatelessWidget {
  final DateTime mes;
  final VoidCallback onAnterior;
  final VoidCallback onProximo;
  final VoidCallback onHoje;

  const _CabecalhoMes({
    required this.mes,
    required this.onAnterior,
    required this.onProximo,
    required this.onHoje,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = DateFormat('MMMM yyyy', 'pt_BR').format(mes);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Text(
            titulo[0].toUpperCase() + titulo.substring(1),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF820AD1),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onHoje,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Hoje', style: TextStyle(fontSize: 13)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 22),
            onPressed: onAnterior,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 22),
            onPressed: onProximo,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _DiasSemanaCabecalho extends StatelessWidget {
  const _DiasSemanaCabecalho();

  @override
  Widget build(BuildContext context) {
    const dias = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: dias
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _GradeMes extends StatelessWidget {
  final DateTime mes;
  final DateTime diaSelecionado;
  final Color Function(DateTime) corDoDia;
  final List<Task> Function(DateTime) tasksNoDia;
  final Function(DateTime) onDiaTap;

  const _GradeMes({
    required this.mes,
    required this.diaSelecionado,
    required this.corDoDia,
    required this.tasksNoDia,
    required this.onDiaTap,
  });

  @override
  Widget build(BuildContext context) {
    final primeiroDia = DateTime(mes.year, mes.month, 1);
    final diasNoMes = DateUtils.getDaysInMonth(mes.year, mes.month);
    final offsetInicio = primeiroDia.weekday % 7;
    final hoje = DateTime.now();
    final hojeNorm = DateTime(hoje.year, hoje.month, hoje.day);

    final totalCelulas = offsetInicio + diasNoMes;
    final linhas = (totalCelulas / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: List.generate(linhas, (linha) {
          return Expanded(
            child: Row(
              children: List.generate(7, (col) {
                final idx = linha * 7 + col;
                final diaNum = idx - offsetInicio + 1;

                if (diaNum < 1 || diaNum > diasNoMes) {
                  return const Expanded(child: SizedBox());
                }

                final dia = DateTime(mes.year, mes.month, diaNum);
                final ehHoje = dia == hojeNorm;
                final ehSelecionado = dia.year == diaSelecionado.year &&
                    dia.month == diaSelecionado.month &&
                    dia.day == diaSelecionado.day;
                final cor = corDoDia(dia);
                final temTasks = tasksNoDia(dia).isNotEmpty;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDiaTap(dia),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: ehSelecionado
                            ? const Color(0xFF820AD1)
                            : ehHoje
                                ? const Color(0xFF820AD1).withValues(alpha: 0.12)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$diaNum',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: ehHoje || ehSelecionado
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: ehSelecionado
                                  ? Colors.white
                                  : ehHoje
                                      ? const Color(0xFF820AD1)
                                      : Colors.black87,
                            ),
                          ),
                          if (temTasks) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: cor == Colors.transparent
                                    ? Colors.grey
                                    : cor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class _ListaDoDia extends StatelessWidget {
  final DateTime dia;
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final Color Function(String, bool) prioridadeCor;

  const _ListaDoDia({
    required this.dia,
    required this.tasks,
    required this.onTaskTap,
    required this.prioridadeCor,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(dia);
    final tituloFmt = titulo[0].toUpperCase() + titulo.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            tituloFmt,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        if (tasks.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_outlined,
                      size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhuma tarefa neste dia',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final task = tasks[i];
                final cor = prioridadeCor(task.prioridade, task.importante);
                final ehEmergencia = task.prioridade == 'alta' && task.importante;

                return GestureDetector(
                  onTap: () => onTaskTap(task),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(color: cor, width: 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (ehEmergencia) ...[
                                      const Icon(Icons.priority_high,
                                          size: 14,
                                          color: Color(0xFF8B0000)),
                                      const SizedBox(width: 4),
                                    ],
                                    Expanded(
                                      child: Text(
                                        task.titulo,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          decoration: task.realizada
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: task.realizada
                                              ? Colors.grey
                                              : Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (task.descricao.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    task.descricao,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      decoration: task.realizada
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PrioridadeChip(
                            prioridade: task.prioridade,
                            importante: task.importante,
                            cor: cor,
                          ),
                          if (task.realizada) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _PrioridadeChip extends StatelessWidget {
  final String prioridade;
  final bool importante;
  final Color cor;

  const _PrioridadeChip({
    required this.prioridade,
    required this.importante,
    required this.cor,
  });

  String get _label {
    if (prioridade == 'alta' && importante) return 'EMERGÊNCIA';
    switch (prioridade) {
      case 'alta':
        return 'ALTA';
      case 'baixa':
        return 'BAIXA';
      default:
        return 'MÉDIA';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: cor == const Color(0xFFFDD835)
              ? const Color(0xFF795B00)
              : cor,
        ),
      ),
    );
  }
}
