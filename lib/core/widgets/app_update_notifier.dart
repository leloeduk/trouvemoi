import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_update_service.dart';
import '../theme/app_theme.dart';

/// Vérifie une fois au démarrage si une mise à jour est disponible
/// (via Firestore) et affiche une notification à l'utilisateur.
class AppUpdateNotifier extends StatefulWidget {
  final Widget child;

  const AppUpdateNotifier({super.key, required this.child});

  @override
  State<AppUpdateNotifier> createState() => _AppUpdateNotifierState();
}

class _AppUpdateNotifierState extends State<AppUpdateNotifier> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    if (_checked) return;
    _checked = true;

    final info = await AppUpdateService.instance.checkForUpdate();
    if (info == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.system_update_alt,
          size: 40,
          color: AppColors.primary,
        ),
        title: const Text('Nouvelle version disponible'),
        content: Text(
          'La version ${info.latestVersion} est disponible '
          '(vous utilisez la ${info.currentVersion}).\n\n${info.message}',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              launchUrl(Uri.parse(info.url));
            },
            icon: const Icon(Icons.system_update_alt),
            label: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}