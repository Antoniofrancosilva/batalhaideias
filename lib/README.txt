BATALHA DE IDEIAS

Arquivos:
lib/main.dart
lib/models/ideia.dart
lib/services/ideia_service.dart
lib/providers/ideia_provider.dart
lib/pages/home_page.dart

Dependências do pubspec.yaml:
firebase_core
cloud_firestore
provider

IMPORTANTE:
1. Mantenha o firebase_options.dart gerado/configurado no seu projeto.
2. No Firebase, crie/ative o Cloud Firestore.
3. A coleção usada pelo aplicativo é: ideias
4. Cada documento terá:
   titulo
   descricao
   autor
   votos

O campo votos começa em 0.
Os votos usam FieldValue.increment(1), permitindo atualização atômica no Firestore.
A lista usa snapshots(), então alterações feitas por outro navegador/dispositivo aparecem automaticamente.
