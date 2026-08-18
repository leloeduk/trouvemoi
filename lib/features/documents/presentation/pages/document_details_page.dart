import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ad_banner.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../domain/entities/document_entity.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';

class DocumentDetailsPage extends StatefulWidget {
  final String docId;

  const DocumentDetailsPage({super.key, required this.docId});

  @override
  State<DocumentDetailsPage> createState() => _DocumentDetailsPageState();
}

class _DocumentDetailsPageState extends State<DocumentDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DocumentBloc>().add(LoadDocumentByIdEvent(widget.docId));
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir: $url')),
        );
      }
    }
  }

  String _buildWhatsAppUrl(DocumentEntity document) {
    var phone = document.finderPhone.replaceAll(' ', '');
    if (!phone.startsWith('+')) {
      phone = '242$phone';
    }
    return 'https://wa.me/$phone';
  }

  Future<void> _onWhatsAppTap(DocumentEntity document) async {
    final url = _buildWhatsAppUrl(document);

    // Sans publicités actives (développement/tests), contact direct.
    if (!AdService.instance.isInitialized.value) {
      await _launchUrl(url);
      return;
    }

    final shouldWatch = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter le propriétaire'),
        content: const Text(
          'Regardez une courte publicité pour débloquer le contact WhatsApp. '
          'Le contact restera gratuit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Plus tard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Regarder la pub'),
          ),
        ],
      ),
    );

    if (shouldWatch != true || !mounted) return;

    final shown = await AdService.instance.showRewardedAd(
      onRewarded: () {
        if (!mounted) return;
        _launchUrl(url);
      },
    );

    if (!shown && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucune publicité disponible pour le moment. Réessayez bientôt.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Détails du document'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          if (state is DocumentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DocumentDetailLoaded) {
            return _buildDocumentDetails(context, state.document);
          }

          if (state is DocumentDetailNotFound) {
            return _ErrorState(
              message: 'Document introuvable',
              onRetry: () {
                context
                    .read<DocumentBloc>()
                    .add(LoadDocumentByIdEvent(widget.docId));
              },
              onHome: () => context.go('/home'),
            );
          }

          if (state is DocumentError) {
            return _ErrorState(
              message: state.message,
              onRetry: () {
                context
                    .read<DocumentBloc>()
                    .add(LoadDocumentByIdEvent(widget.docId));
              },
              onHome: () => context.go('/home'),
            );
          }

          return const Center(child: Text('Chargement...'));
        },
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildDocumentDetails(BuildContext context, DocumentEntity document) {
    final isFound = document.status == DocumentStatus.found;
    final statusColor = isFound ? AppColors.success : AppColors.lost;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: document.imageUrl,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 260,
                  color: AppColors.background,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 260,
                  color: AppColors.background,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFound ? Icons.check_circle : Icons.search,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isFound ? 'DOCUMENT TROUVÉ' : 'DOCUMENT PERDU',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  document.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Publié le ${DateFormat('dd/MM/yyyy à HH:mm').format(document.date)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  document.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Informations
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (document.type.isNotEmpty) ...[
                          _InfoRow(
                            icon: Icons.category,
                            label: 'Type',
                            value: document.type,
                          ),
                          const Divider(),
                        ],
                        _InfoRow(
                          icon: Icons.location_on,
                          label: 'Ville',
                          value: document.location,
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.person,
                          label: 'Trouvé par',
                          value: document.finderName,
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.phone,
                          label: 'Téléphone',
                          value: document.finderPhone,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Contact
                Text(
                  'Contacter le trouveur',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Appelez ou contactez via WhatsApp pour récupérer votre document.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl('tel:${document.finderPhone}'),
                        icon: const Icon(Icons.phone),
                        label: const Text('Appeler'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _onWhatsAppTap(document),
                        icon: const Icon(Icons.chat),
                        label: const Text('WhatsApp'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bouton retour
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour à l\'accueil'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.onHome,
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
                color: AppColors.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Réessayer'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: onHome,
                  child: const Text('Accueil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}