import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/ideia.dart';
import '../services/ideia_service.dart';

class IdeiaProvider extends ChangeNotifier {
  final IdeiaService _service = IdeiaService();

  List<Ideia> ideias = [];
  bool carregando = true;
  String? erro;

  StreamSubscription<List<Ideia>>? _subscription;

  IdeiaProvider() {
    _carregarIdeias();
  }

  void _carregarIdeias() {
    _subscription = _service.listarIdeias().listen(
      (lista) {
        ideias = lista;
        carregando = false;
        erro = null;
        notifyListeners();
      },
      onError: (error) {
        carregando = false;
        erro = 'Não foi possível carregar as ideias.';
        notifyListeners();
      },
    );
  }

  Future<void> adicionar({
    required String titulo,
    required String descricao,
    required String autor,
  }) async {
    if (titulo.trim().isEmpty ||
        descricao.trim().isEmpty ||
        autor.trim().isEmpty) {
      return;
    }

    await _service.adicionarIdeia(
      titulo: titulo,
      descricao: descricao,
      autor: autor,
    );
  }

  Future<void> votar(String id) async {
    await _service.votar(id);
  }

  Future<void> excluir(String id) async {
    await _service.excluirIdeia(id);
  }

  Ideia? get ideiaMaisVotada {
    if (ideias.isEmpty) {
      return null;
    }

    return ideias.first;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
