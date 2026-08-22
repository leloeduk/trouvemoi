import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/congo_cities.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ad_banner.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../domain/entities/document_entity.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';
import 'document_card.dart';

class SearchDocumentsPage extends StatefulWidget {
  const SearchDocumentsPage({super.key});

  @override
  State<SearchDocumentsPage> createState() => _SearchDocumentsPageState();
}

class _SearchDocumentsPageState extends State<SearchDocumentsPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String? _selectedType;
  String? _selectedCity;
  DocumentStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isNotEmpty) {
      setState(() => _isSearching = true);
      context.read<DocumentBloc>().add(SearchDocumentsEvent(query.trim()));
    } else {
      setState(() => _isSearching = false);
      context.read<DocumentBloc>().add(LoadAllDocumentsEvent());
    }
  }

  List<DocumentEntity> _applyFilters(List<DocumentEntity> documents) {
    return documents.where((doc) {
      if (_selectedType != null && doc.type != _selectedType) return false;
      if (_selectedCity != null && doc.location != _selectedCity) return false;
      if (_selectedStatus != null && doc.status != _selectedStatus) {
        return false;
      }
      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCity = null;
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: const AppBackButton(),
            title: const Text('Rechercher'),
          ),
          // Search Bar
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Titre, description ou ville...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Effacer',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),

          // Filters
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            prefixIcon: Icon(Icons.category_outlined),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Tous les types'),
                            ),
                            ...AppConstants.documentTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedType = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCity,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Ville',
                            prefixIcon: Icon(Icons.location_city),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Toutes les villes'),
                            ),
                            ...CongoCities.all.map((city) {
                              return DropdownMenuItem(
                                value: city.name,
                                child: Text(
                                  city.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedCity = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'Tous',
                                icon: Icons.grid_view,
                                selected: _selectedStatus == null,
                                onTap: () =>
                                    setState(() => _selectedStatus = null),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Trouvés',
                                icon: Icons.check_circle,
                                selected:
                                    _selectedStatus == DocumentStatus.found,
                                onTap: () => setState(
                                    () => _selectedStatus = DocumentStatus.found),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Perdus',
                                icon: Icons.search,
                                selected:
                                    _selectedStatus == DocumentStatus.lost,
                                onTap: () => setState(
                                    () => _selectedStatus = DocumentStatus.lost),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Effacer les filtres',
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.filter_alt_off_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),

          // Search Results
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
                final results = _applyFilters(state.documents);

                if (results.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      icon: _isSearching || state.documents.isNotEmpty
                          ? Icons.filter_alt_off
                          : Icons.search,
                      title: _isSearching || state.documents.isNotEmpty
                          ? 'Aucun résultat'
                          : 'Recherchez un document',
                      subtitle:
                          'Modifiez la recherche ou les filtres pour voir plus de résultats',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return DocumentCard(document: results[index]);
                    },
                  ),
                );
              }

              if (state is DocumentError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    icon: Icons.error_outline,
                    title: 'Une erreur est survenue',
                    subtitle: state.message,
                  ),
                );
              }

              return SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  icon: Icons.search,
                  title: 'Recherchez un document',
                  subtitle: 'Tapez pour commencer la recherche',
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: AdBannerWidget()),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
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
          Icon(icon, size: 15, color: color),
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
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}