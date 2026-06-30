import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../document_entity.dart';

class DocumentDetailsPage extends StatefulWidget {
  final String documentId;

  const DocumentDetailsPage({super.key, required this.documentId});

  @override
  State<DocumentDetailsPage> createState() => _DocumentDetailsPageState();
}

class _DocumentDetailsPageState extends State<DocumentDetailsPage> {
  DocumentEntity? _document;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final snapshot = await FirestoreService.instance.firestore
          .collection(AppConstants.collectionDocuments)
          .doc(widget.documentId)
          .get();
      if (!snapshot.exists) throw Exception('Document introuvable');
      final doc = DocumentEntity.fromFirestore(snapshot);
      if (mounted) setState(() => _document = doc);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails')),
      body: _isLoading
          ? const LoadingWidget(message: 'Chargement...')
          : _error != null
              ? AppErrorWidget(
                  message: _error!,
                  onRetry: _loadDocument,
                )
              : _document == null
                  ? const AppErrorWidget(message: 'Document introuvable')
                  : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final doc = _document!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (doc.photo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                doc.photo!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          const SizedBox(height: 20),
          _buildSection(context, 'Propriétaire', [
            _buildInfoRow(context, 'Nom', doc.nom),
            _buildInfoRow(context, 'Prénom', doc.prenom),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Pièce', [
            _buildInfoRow(context, 'Type', doc.type),
            _buildInfoRow(context, 'Numéro', doc.numero),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Localisation', [
            _buildInfoRow(context, 'Ville', doc.ville),
            _buildInfoRow(context, 'Lieu trouvé', doc.lieu),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Description', [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                doc.description.isEmpty
                    ? 'Aucune description'
                    : doc.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Informations', [
            _buildInfoRow(context, 'Date', _formatDate(doc.createdAt)),
            _buildInfoRow(
                context,
                'Statut',
                doc.status == 'trouvee' ? 'Trouvée' : 'Perdue'),
          ]),
          const SizedBox(height: 24),
          _buildContactButtons(context, doc),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButtons(BuildContext context, DocumentEntity doc) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: () => launchUrl(Uri.parse('tel:${doc.telephone}')),
          icon: const Icon(Icons.phone),
          label: const Text('Appeler'),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () {
            final message =
                'Bonjour, je vous contacte à propos de la pièce de ${doc.nom} ${doc.prenom} trouvée sur RetrouvePièce.';
            launchUrl(
              Uri.parse(
                  'https://wa.me/${doc.telephone}?text=${Uri.encodeComponent(message)}'),
              mode: LaunchMode.externalApplication,
            );
          },
          icon: const Icon(Icons.chat),
          label: const Text('WhatsApp'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
