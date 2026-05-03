class Task {
  int? id;
  String titulo;
  String descricao;
  String dataPrevista; // stored as 'yyyy-MM-dd' text in SQLite
  bool importante;
  bool realizada;
  String prioridade; // atributo extra: 'baixa', 'media', 'alta'

  Task({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.dataPrevista,
    this.importante = false,
    this.realizada = false,
    this.prioridade = 'media',
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      dataPrevista: map['data_prevista'] as String,
      importante: (map['importante'] as int) == 1,
      realizada: (map['realizada'] as int) == 1,
      prioridade: map['prioridade'] as String? ?? 'media',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'data_prevista': dataPrevista,
      'importante': importante ? 1 : 0,
      'realizada': realizada ? 1 : 0,
      'prioridade': prioridade,
    };
  }

  Task copyWith({
    int? id,
    String? titulo,
    String? descricao,
    String? dataPrevista,
    bool? importante,
    bool? realizada,
    String? prioridade,
  }) {
    return Task(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataPrevista: dataPrevista ?? this.dataPrevista,
      importante: importante ?? this.importante,
      realizada: realizada ?? this.realizada,
      prioridade: prioridade ?? this.prioridade,
    );
  }

  DateTime get dataDateTime => DateTime.parse(dataPrevista);

  bool get atrasada {
    final hoje = DateTime.now();
    final data = dataDateTime;
    return !realizada &&
        data.isBefore(DateTime(hoje.year, hoje.month, hoje.day));
  }
}
