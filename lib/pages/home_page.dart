import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ideia.dart';
import '../providers/ideia_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _autorController = TextEditingController();

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _autorController.dispose();
    super.dispose();
  }

  Future<void> _cadastrarIdeia() async {
    final titulo = _tituloController.text.trim();
    final descricao = _descricaoController.text.trim();
    final autor = _autorController.text.trim();

    if (titulo.isEmpty || descricao.isEmpty || autor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha título, descrição e autor.'),
        ),
      );
      return;
    }

    try {
      await context.read<IdeiaProvider>().adicionar(
            titulo: titulo,
            descricao: descricao,
            autor: autor,
          );

      _tituloController.clear();
      _descricaoController.clear();
      _autorController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ideia cadastrada com sucesso!'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao cadastrar a ideia.'),
        ),
      );
    }
  }

  Future<void> _votar(Ideia ideia) async {
    try {
      await context.read<IdeiaProvider>().votar(ideia.id);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível registrar o voto.'),
        ),
      );
    }
  }

  Future<void> _excluir(Ideia ideia) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir ideia'),
          content: Text(
            'Deseja excluir a ideia "${ideia.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('EXCLUIR'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await context.read<IdeiaProvider>().excluir(ideia.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ideia excluída com sucesso!'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir a ideia.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batalha de Ideias'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _FormularioCadastro(
                  tituloController: _tituloController,
                  descricaoController: _descricaoController,
                  autorController: _autorController,
                  onCadastrar: _cadastrarIdeia,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<IdeiaProvider>(
                    builder: (context, provider, child) {
                      if (provider.carregando) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (provider.erro != null) {
                        return Center(
                          child: Text(provider.erro!),
                        );
                      }

                      if (provider.ideias.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhuma ideia cadastrada ainda.',
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }

                      return ListView(
                        children: [
                          if (provider.ideiaMaisVotada != null)
                            _RankingCard(
                              ideia: provider.ideiaMaisVotada!,
                            ),
                          const SizedBox(height: 12),
                          const Text(
                            'IDEIAS CADASTRADAS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...provider.ideias.map(
                            (ideia) => _IdeiaCard(
                              ideia: ideia,
                              onVotar: () => _votar(ideia),
                              onExcluir: () => _excluir(ideia),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormularioCadastro extends StatelessWidget {
  final TextEditingController tituloController;
  final TextEditingController descricaoController;
  final TextEditingController autorController;
  final VoidCallback onCadastrar;

  const _FormularioCadastro({
    required this.tituloController,
    required this.descricaoController,
    required this.autorController,
    required this.onCadastrar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cadastrar nova ideia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ex: Aplicativo para organizar campeonatos',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descricaoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Explique sua ideia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: autorController,
              decoration: const InputDecoration(
                labelText: 'Nome do autor',
                hintText: 'Ex: Lucas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCadastrar,
                icon: const Icon(Icons.add),
                label: const Text('CADASTRAR IDEIA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final Ideia ideia;

  const _RankingCard({required this.ideia});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Text(
              '🏆',
              style: TextStyle(fontSize: 36),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IDEIA MAIS VOTADA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ideia.titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${ideia.votos} votos'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeiaCard extends StatelessWidget {
  final Ideia ideia;
  final VoidCallback onVotar;
  final VoidCallback onExcluir;

  const _IdeiaCard({
    required this.ideia,
    required this.onVotar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ideia.titulo,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Autor: ${ideia.autor}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(ideia.descricao),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.favorite),
                const SizedBox(width: 6),
                Text(
                  '${ideia.votos} votos',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onVotar,
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('VOTAR'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Excluir',
                  onPressed: onExcluir,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
