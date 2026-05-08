import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  DateTime? _dataSelecionada;
  bool _importante = false;
  String _prioridade = 'media';
  bool _isEditing = false;
  Task? _taskOriginal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isEditing) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Task) {
        _taskOriginal = args;
        _isEditing = true;
        _tituloCtrl.text = args.titulo;
        _descricaoCtrl.text = args.descricao;
        _dataSelecionada = args.dataDateTime;
        _importante = args.importante;
        _prioridade = args.prioridade;
      }
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Selecionar data prevista',
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() => _dataSelecionada = picked);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma data prevista.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<TaskProvider>();
    final dataStr =
        DateFormat('yyyy-MM-dd').format(_dataSelecionada!);

    if (_isEditing && _taskOriginal != null) {
      final updated = _taskOriginal!.copyWith(
        titulo: _tituloCtrl.text.trim(),
        descricao: _descricaoCtrl.text.trim(),
        dataPrevista: dataStr,
        importante: _importante,
        prioridade: _prioridade,
      );
      await provider.updateTask(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa atualizada com sucesso!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      final nova = Task(
        titulo: _tituloCtrl.text.trim(),
        descricao: _descricaoCtrl.text.trim(),
        dataPrevista: dataStr,
        importante: _importante,
        prioridade: _prioridade,
      );
      await provider.addTask(nova);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa criada com sucesso!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Tarefa' : 'Nova Tarefa',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _SectionLabel(label: 'Título *'),
            TextFormField(
              controller: _tituloCtrl,
              decoration: _inputDecoration(
                  hint: 'Ex: Reunião com equipe', icon: Icons.title_rounded),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe o título' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Descrição'),
            TextFormField(
              controller: _descricaoCtrl,
              decoration: _inputDecoration(
                  hint: 'Detalhe a tarefa...', icon: Icons.notes_rounded),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Data Prevista *'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: theme.colorScheme.primary, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      _dataSelecionada == null
                          ? 'Toque para selecionar a data'
                          : DateFormat('dd/MM/yyyy')
                              .format(_dataSelecionada!),
                      style: TextStyle(
                        fontSize: 16,
                        color: _dataSelecionada == null
                            ? Colors.grey.shade500
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right,
                        color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Prioridade (atributo extra)'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _PriorityOption(
                    label: 'Baixa',
                    value: 'baixa',
                    selected: _prioridade == 'baixa',
                    color: Colors.green,
                    icon: Icons.arrow_downward_rounded,
                    onTap: () => setState(() => _prioridade = 'baixa'),
                  ),
                  const Divider(height: 1),
                  _PriorityOption(
                    label: 'Média',
                    value: 'media',
                    selected: _prioridade == 'media',
                    color: Colors.orange,
                    icon: Icons.remove_rounded,
                    onTap: () => setState(() => _prioridade = 'media'),
                  ),
                  const Divider(height: 1),
                  _PriorityOption(
                    label: 'Alta',
                    value: 'alta',
                    selected: _prioridade == 'alta',
                    color: Colors.red,
                    icon: Icons.arrow_upward_rounded,
                    onTap: () => setState(() => _prioridade = 'alta'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SwitchListTile(
                title: const Text('Tarefa Importante',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('Marcar como prioritária'),
                secondary: Icon(
                  Icons.star_rounded,
                  color: _importante ? Colors.amber : Colors.grey.shade400,
                ),
                value: _importante,
                onChanged: (v) => setState(() => _importante = v),
                activeThumbColor: Colors.amber,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),

            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFF820AD1), size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Para marcar como realizada, vá aos detalhes da tarefa.',
                          style: TextStyle(
                              color: Color(0xFF5C0093), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvar,
                icon: Icon(_isEditing ? Icons.save_outlined : Icons.add,
                    color: Colors.white),
                label: Text(
                  _isEditing ? 'Salvar Alterações' : 'Criar Tarefa',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.blueGrey)),
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: selected ? color : Colors.grey.shade400, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? color : Colors.grey.shade700,
                    fontSize: 15)),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
