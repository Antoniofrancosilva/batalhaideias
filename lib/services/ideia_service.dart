import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ideia.dart';

class IdeiaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String colecao = 'ideias';

  Stream<List<Ideia>> listarIdeias() {
    return _firestore.collection(colecao).snapshots().map((snapshot) {
      final ideias = snapshot.docs.map((doc) {
        return Ideia.fromMap(doc.id, doc.data());
      }).toList();

      ideias.sort((a, b) => b.votos.compareTo(a.votos));

      return ideias;
    });
  }

  Future<void> adicionarIdeia({
    required String titulo,
    required String descricao,
    required String autor,
  }) async {
    final ideia = Ideia(
      id: '',
      titulo: titulo.trim(),
      descricao: descricao.trim(),
      autor: autor.trim(),
      votos: 0,
    );

    await _firestore.collection(colecao).add(ideia.toMap());
  }

  Future<void> votar(String id) async {
    await _firestore.collection(colecao).doc(id).update({
      'votos': FieldValue.increment(1),
    });
  }

  Future<void> excluirIdeia(String id) async {
    await _firestore.collection(colecao).doc(id).delete();
  }
}
