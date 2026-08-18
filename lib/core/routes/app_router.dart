import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/documents/presentation/pages/add_document_page.dart';
import '../../features/documents/presentation/pages/browse_documents_page.dart';
import '../../features/documents/presentation/pages/document_details_page.dart';
import '../../features/documents/presentation/pages/edit_document_page.dart';
import '../../features/documents/presentation/pages/my_publications_page.dart';
import '../../features/documents/presentation/pages/search_document_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/support/presentation/pages/about_page.dart';
import '../../features/support/presentation/pages/support_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    // Login
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    // Home (protégé)
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    // Documents
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
      builder: (context, state) {
        final docId = state.pathParameters['id']!;
        return DocumentDetailsPage(docId: docId);
      },
    ),
    GoRoute(
      path: '/my-publications',
      builder: (context, state) => const MyPublicationsPage(),
    ),
    GoRoute(
      path: '/edit-document/:id',
      builder: (context, state) {
        final docId = state.pathParameters['id']!;
        return EditDocumentPage(docId: docId);
      },
    ),
    // Profile
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    // Support
    GoRoute(
      path: '/support',
      builder: (context, state) => const SupportPage(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
  ],
  // Guard pour protéger les routes
  redirect: (context, state) {
    final authBloc = context.read<AuthBloc>();
    final isAuthenticated = authBloc.state.status == AuthStatus.authenticated;
    final isOnSplash = state.matchedLocation == '/splash';
    final isOnLogin = state.matchedLocation == '/login';

    // Si on est sur splash, on laisse faire (le splash gère la redirection)
    if (isOnSplash) return null;

    // Si pas authentifié et pas sur login -> rediriger vers login
    if (!isAuthenticated && !isOnLogin) {
      return '/login';
    }

    // Si authentifié et sur login -> rediriger vers home
    if (isAuthenticated && isOnLogin) {
      return '/home';
    }

    return null;
  },
);
