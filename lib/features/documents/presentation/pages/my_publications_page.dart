import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/document_entity.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';
import 'document_card.dart';

class MyPublicationsPage extends StatefulWidget {
  const MyPublicationsPage({super.key});

  @override
  State<MyPublicationsPage> createState() => _MyPublicationsPageState();
}

class _MyPublicationsPageState extends State<MyPublicationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DocumentBloc>().add(LoadAllDocumentsEvent());
  }

  Future<void> _confirmDelete(DocumentEntity doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la publication'),
        content: Text('Voulez-vous vraiment supprimer « ${doc.title} » ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      context.read<DocumentBloc>().add(DeleteDocumentEvent(doc.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Mes publications'),
      ),
      body: BlocConsumer<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Publication supprimée')),
            );
          }
          if (state is DocumentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DocumentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final authState = context.read<AuthBloc>().state;
          final currentUserId = authState.status == AuthStatus.authenticated
              ? authState.user!.uid
              : '';

          if (state is DocumentLoaded) {
            final mine = state.documents
                .where((doc) => doc.finderId == currentUserId)
                .toList();

            if (mine.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.post_add_outlined,
                      size: 72,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune publication',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Publiez votre premier document',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.go('/add-document'),
                      icon: const Icon(Icons.add),
                      label: const Text('Publier'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: mine.length,
              itemBuilder: (context, index) {
                final doc = mine[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DocumentCard(document: doc),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                context.go('/edit-document/${doc.id}'),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Modifier'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _confirmDelete(doc),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.danger,
                            ),
                            label: const Text(
                              'Supprimer',
                              style: TextStyle(color: AppColors.danger),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return const Center(child: Text('Chargement...'));
        },
      ),
    );
  }
}