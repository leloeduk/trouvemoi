import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/constants/constants.dart';
import '../../document_entity.dart';
import '../widgets/document_card.dart';

class SearchDocumentPage extends StatefulWidget {
  const SearchDocumentPage({super.key});

  @override
  State<SearchDocumentPage> createState() => _SearchDocumentPageState();
}

class _SearchDocumentPageState extends State<SearchDocumentPage> {
  final _searchController = TextEditingController();
  bool _searchByNumber = false;
  List<DocumentEntity> _results = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void dispose() {
    _searchController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _search(String query) {
    _subscription?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    final q = query.trim();
    final ref = FirestoreService.instance.firestore
        .collection(AppConstants.collectionDocuments);

    Stream<QuerySnapshot> stream;
    if (_searchByNumber) {
      final upper = q.toUpperCase();
      stream = ref
          .where('numero', isGreaterThanOrEqualTo: upper)
          .where('numero', isLessThanOrEqualTo: '$upper\uf8ff')
          .orderBy('numero')
          .snapshots();
    } else {
      final upper = q.toUpperCase();
      stream = ref
          .where('nom', isGreaterThanOrEqualTo: upper)
          .where('nom', isLessThanOrEqualTo: '$upper\uf8ff')
          .orderBy('nom')
          .snapshots();
    }

    _subscription = stream.listen((snapshot) {
      if (mounted) {
        setState(() {
          _results = snapshot.docs
              .map((doc) => DocumentEntity.fromFirestore(doc))
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: _searchByNumber
                            ? 'Numéro de la pièce'
                            : 'Nom du propriétaire',
                        prefixIcon: Icon(_searchByNumber
                            ? Icons.badge
                            : Icons.person_search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _subscription?.cancel();
                                  setState(() => _results = []);
                                },
                              )
                            : null,
                      ),
                      textCapitalization: _searchByNumber
                          ? TextCapitalization.none
                          : TextCapitalization.characters,
                      onChanged: (v) {
                        setState(() {});
                        _search(v);
                      },
                    ),
                    const SizedBox(height: 8),
                    ToggleButtons(
                      isSelected: [!_searchByNumber, _searchByNumber],
                      onPressed: (index) {
                        setState(() => _searchByNumber = index == 1);
                        _searchController.clear();
                        _subscription?.cancel();
                        setState(() => _results = []);
                      },
                      borderRadius: BorderRadius.circular(8),
                      constraints: const BoxConstraints(
                          minWidth: 80, minHeight: 36),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Par nom',
                              style:
                                  Theme.of(context).textTheme.labelMedium),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Par numéro',
                              style:
                                  Theme.of(context).textTheme.labelMedium),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Tapez un nom ou numéro pour rechercher'
                              : 'Aucun résultat trouvé',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DocumentCard(
                          document: _results[index],
                          onTap: () => context.push(
                              '/document-details/${_results[index].id}'),
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
