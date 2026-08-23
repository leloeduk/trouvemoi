import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_back_button.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir: $url')),
      );
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
            title: const Text('Aide & Support'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comment utiliser l\'application ?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const _HelpItem(
                    icon: Icons.add_circle_outline,
                    title: 'Publier un document',
                    description:
                        'Touchez « Publier » dans l\'accueil, choisissez le type de document, ajoutez une photo et les informations de contact.',
                  ),
                  const _HelpItem(
                    icon: Icons.search,
                    title: 'Rechercher un document',
                    description:
                        'Utilisez la recherche pour filtrer par type, ville ou statut (Trouvé / Perdu).',
                  ),
                  const _HelpItem(
                    icon: Icons.phone,
                    title: 'Contacter le propriétaire',
                    description:
                        'Ouvrez une publication et utilisez le bouton WhatsApp pour contacter directement la personne.',
                  ),
                  const _HelpItem(
                    icon: Icons.history,
                    title: 'Gérer mes publications',
                    description:
                        'Retrouvez, modifiez ou supprimez vos publications depuis « Mes publications » dans le profil.',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Questions fréquentes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const _HelpItem(
                    icon: Icons.question_answer_outlined,
                    title: 'Comment est mon numéro de téléphone ?',
                    description:
                        '9 chiffres commençant par 04, 05 ou 06. Exemple : 06 635 24 55.',
                  ),
                  const _HelpItem(
                    icon: Icons.lock_outline,
                    title: 'Mes données sont-elles protégées ?',
                    description:
                        'Vos informations de profil sont privées. Seul votre nom et votre numéro apparaissent sur vos publications.',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nous contacter',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.success,
                            ),
                          ),
                          title: const Text('Groupe WhatsApp'),
                          subtitle:
                              const Text('Rejoignez la communauté pour aider'),
                          onTap: () => _launchUrl(
                            context,
                            'https://chat.whatsapp.com/J5z73UFA8s18j8b7xotLYY',
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.email_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          title: const Text('Email'),
                          subtitle: const Text('trouvemoisolution@gmail.com'),
                          onTap: () => _launchUrl(
                            context,
                            'mailto:trouvemoisolution@gmail.com',
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.call,
                              color: AppColors.danger,
                            ),
                          ),
                          title: const Text('Appeler'),
                          subtitle: const Text('+242 06 682 63 52'),
                          onTap: () => _launchUrl(
                            context,
                            'tel:+242066826352',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
        isThreeLine: true,
      ),
    );
  }
}
