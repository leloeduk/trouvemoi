import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ad_banner.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../domain/entities/document_entity.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';
import 'document_card.dart';

class BrowseDocumentsPage extends StatefulWidget {
  const BrowseDocumentsPage({super.key});

  @override
  State<BrowseDocumentsPage> createState() => _BrowseDocumentsPageState();
}

class _BrowseDocumentsPageState extends State<BrowseDocumentsPage> {
  DocumentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<DocumentBloc>().add(LoadAllDocumentsEvent());
  }

  void _setStatus(DocumentStatus? status) {
    setState(() => _selectedStatus = status);
    if (status == null) {
      context.read<DocumentBloc>().add(LoadAllDocumentsEvent());
    } else {
      context.read<DocumentBloc>().add(FilterByStatusEvent(status));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: const AppBackButton(),
            title: const Text('Documents'),
            actions: [
              IconButton(
                tooltip: 'Rechercher',
                icon: const Icon(Icons.search),
                onPressed: () => context.go('/search-document'),
              ),
            ],
          ),
          // Filter chips
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  _StatusFilterChip(
                    label: 'Tous',
                    icon: Icons.grid_view,
                    selected: _selectedStatus == null,
                    onTap: () => _setStatus(null),
                  ),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: 'Perdus',
                    icon: Icons.search,
                    selected: _selectedStatus == DocumentStatus.lost,
                    onTap: () => _setStatus(DocumentStatus.lost),
                  ),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: 'Trouvés',
                    icon: Icons.check_circle,
                    selected: _selectedStatus == DocumentStatus.found,
                    onTap: () => _setStatus(DocumentStatus.found),
                  ),
                ],
              ),
            ),
          ),
          // Documents list
          BlocBuilder<DocumentBloc, DocumentState>(
            builder: (context, state) {
              if (state is DocumentLoading) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: DocumentListSkeleton(count: 3),
                  ),
                );
              }
              if (state is DocumentLoaded) {
                if (state.documents.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 72,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun document trouvé',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList.builder(
                    itemCount: state.documents.length,
                    itemBuilder: (context, index) {
                      return DocumentCard(document: state.documents[index]);
                    },
                  ),
                );
              }
              if (state is DocumentError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Erreur: ${state.message}')),
                );
              }
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Chargement...')),
              );
            },
          ),
          const SliverToBoxAdapter(child: AdBannerWidget()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Publier un document',
        onPressed: () => context.go('/add-document'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}