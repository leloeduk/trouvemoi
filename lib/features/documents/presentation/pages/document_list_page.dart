import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/constants/constants.dart';
import '../../document_entity.dart';
import '../widgets/document_card.dart';

class DocumentListPage extends StatelessWidget {
  final String? documentType;

  const DocumentListPage({super.key, this.documentType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(documentType ?? 'Toutes les pièces')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final ref = FirestoreService.instance.firestore
        .collection(AppConstants.collectionDocuments)
        .orderBy('createdAt', descending: true);

    final query = documentType != null
        ? ref.where('type', isEqualTo: documentType)
        : ref;

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Erreur: ${snapshot.error}'),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs
            .map((doc) => DocumentEntity.fromFirestore(doc))
            .toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('Aucune pièce trouvée',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DocumentCard(
                  document: docs[index],
                  onTap: () =>
                      context.push('/document-details/${docs[index].id}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
