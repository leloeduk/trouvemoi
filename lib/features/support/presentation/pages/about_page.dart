import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_back_button.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
            title: const Text('À propos de l\'app'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/logos/trouvemoi.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Trouve Moi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notre mission',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Trouve Moi aide les habitants du Congo-Brazzaville à '
                            'retrouver leurs documents perdus (carte d\'identité, '
                            'passeport, permis, carte bancaire...) et à rendre ceux '
                            'qu\'ils ont trouvés à leur propriétaire, le plus '
                            'simplement possible.',
                            style: TextStyle(height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Comment ça marche ?',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Publiez une photo du document trouvé ou perdu.\n'
                            '2. Indiquez la ville et votre numéro de téléphone.\n'
                            '3. La personne concernée vous contacte directement.',
                            style: TextStyle(height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          title: const Text('Rejoindre la communauté'),
                          subtitle: const Text('Groupe WhatsApp'),
                          onTap: () => _launchUrl(
                            context,
                            'https://chat.whatsapp.com/J5z73UFA8s18j8b7xotLYY',
                          ),
                        ),
                        const Divider(height: 1),
                        Column(
                          children: [
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.email_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: const Text('Nous écrire'),
                              subtitle:
                                  const Text('trouvemoisolution@gmail.com'),
                              onTap: () => _launchUrl(
                                context,
                                'mailto:trouvemoisolution@gmail.com',
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 1),
                        Column(
                          children: [
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.danger.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.call,
                                  color: AppColors.danger,
                                ),
                              ),
                              title: const Text('Applez'),
                              subtitle: const Text('+242 06 682 63 52'),
                              onTap: () => _launchUrl(
                                context,
                                '+242 06 682 63 52',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Fait par LeloEduk',
                      style: TextStyle(color: AppColors.textSecondary),
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
