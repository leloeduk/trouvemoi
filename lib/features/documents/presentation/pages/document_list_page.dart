import 'package:flutter/material.dart';

class DocumentListPage extends StatelessWidget {
  final String? documentType;

  const DocumentListPage({super.key, this.documentType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(documentType ?? 'Pièces')),
      body: const Center(child: Text('Liste des pièces disponible ici.')),
    );
  }
}
