import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, String path) {
    Navigator.pop(context);
    context.go(path);
  }

  void _signOut(BuildContext context) {
    Navigator.pop(context);
    context.read<AuthBloc>().add(SignOutRequested());
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, UserEntity?>(
      (bloc) => bloc.state.user,
    );

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF60A5FA)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logos/trouvemoi.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Trouve Moi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.displayName ?? 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Accueil',
                    onTap: () => _navigate(context, '/home'),
                  ),
                  _DrawerItem(
                    icon: Icons.search_outlined,
                    label: 'Rechercher',
                    onTap: () => _navigate(context, '/search-document'),
                  ),
                  _DrawerItem(
                    icon: Icons.list_alt_outlined,
                    label: 'Parcourir',
                    onTap: () => _navigate(context, '/browse'),
                  ),
                  _DrawerItem(
                    icon: Icons.add_circle_outline,
                    label: 'Publier',
                    onTap: () => _navigate(context, '/add-document'),
                  ),
                  _DrawerItem(
                    icon: Icons.history_outlined,
                    label: 'Mes publications',
                    onTap: () => _navigate(context, '/my-publications'),
                  ),
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    onTap: () => _navigate(context, '/profile'),
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline,
                    label: 'Aide & Support',
                    onTap: () => _navigate(context, '/support'),
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline,
                    label: 'À propos de l\'app',
                    onTap: () => _navigate(context, '/about'),
                  ),
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: 'Se déconnecter',
                    color: AppColors.danger,
                    onTap: () => _signOut(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Trouve Moi — Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.textPrimary;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}