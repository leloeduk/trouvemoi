import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trouvemoi/core/theme/app_theme.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_state.dart';
import 'package:trouvemoi/features/auth/presentation/pages/login_page.dart';
import 'package:trouvemoi/features/documents/presentation/bloc/document_bloc.dart';
import 'package:trouvemoi/features/documents/presentation/pages/add_document_page.dart';
import 'package:trouvemoi/features/documents/presentation/pages/browse_documents_page.dart';
import 'package:trouvemoi/features/documents/presentation/pages/document_details_page.dart';
import 'package:trouvemoi/features/documents/presentation/pages/search_document_page.dart';
import 'package:trouvemoi/features/home/presentation/pages/home_page.dart';
import 'package:trouvemoi/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trouvemoi/features/profile/presentation/pages/profile_page.dart';
import 'package:trouvemoi/features/splash/presentation/pages/splash_page.dart';

/// Pompe l'application avec des durées fixes au lieu de `pumpAndSettle`.
///
/// `pumpAndSettle` ne se termine jamais avec des animations infinies
/// (ex: `CircularProgressIndicator` des images en chargement), ce helper
/// laisse donc les blocs et les transitions se stabiliser frame par frame.
Future<void> settleWithPumps(
  WidgetTester tester, {
  int pumps = 6,
  Duration step = const Duration(milliseconds: 200),
}) async {
  for (var i = 0; i < pumps; i++) {
    await tester.pump(step);
  }
}

/// Construit l'application de test complète avec les trois blocs et le
/// routeur, permettant de tester les pages et la navigation de bout en bout.
///
/// Le routeur écoute les changements du [AuthBloc] (via un `refreshListenable`)
/// et réévalue ses redirects, imitant ainsi le comportement d'une vraie app
/// où la déconnexion ramène automatiquement sur la page de connexion.
Widget buildTestApp({
  required AuthBloc authBloc,
  required DocumentBloc documentBloc,
  required ProfileBloc profileBloc,
  String initialLocation = '/splash',
}) {
  return _TestApp(
    authBloc: authBloc,
    documentBloc: documentBloc,
    profileBloc: profileBloc,
    initialLocation: initialLocation,
  );
}

class _TestApp extends StatefulWidget {
  final AuthBloc authBloc;
  final DocumentBloc documentBloc;
  final ProfileBloc profileBloc;
  final String initialLocation;

  const _TestApp({
    required this.authBloc,
    required this.documentBloc,
    required this.profileBloc,
    required this.initialLocation,
  });

  @override
  State<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<_TestApp> {
  final _authRefresh = ChangeNotifier();
  late final GoRouter _router;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: widget.initialLocation,
      refreshListenable: _authRefresh,
      routes: [
        GoRoute(
            path: '/splash', builder: (context, state) => const SplashPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/browse',
          builder: (context, state) => const BrowseDocumentsPage(),
        ),
        GoRoute(
          path: '/search-document',
          builder: (context, state) => const SearchDocumentsPage(),
        ),
        GoRoute(
          path: '/add-document',
          builder: (context, state) => const AddDocumentPage(),
        ),
        GoRoute(
          path: '/document/:id',
          builder: (context, state) =>
              DocumentDetailsPage(docId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
      redirect: (context, state) {
        final status = widget.authBloc.state.status;
        final isOnSplash = state.matchedLocation == '/splash';
        final isOnLogin = state.matchedLocation == '/login';

        if (isOnSplash) return null;
        if (status != AuthStatus.authenticated && !isOnLogin) return '/login';
        if (status == AuthStatus.authenticated && isOnLogin) return '/home';
        return null;
      },
    );
    _authSubscription = widget.authBloc.stream.listen(
      (_) => _authRefresh.notifyListeners(),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _authRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authBloc),
        BlocProvider.value(value: widget.documentBloc),
        BlocProvider.value(value: widget.profileBloc),
      ],
      child: MaterialApp.router(
        title: 'Trouve Moi',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
