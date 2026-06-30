import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/documents/presentation/pages/add_document_page.dart';
import '../features/documents/presentation/pages/search_document_page.dart';
import '../features/documents/presentation/pages/document_list_page.dart';
import '../features/documents/presentation/pages/document_details_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/add-document',
        name: 'addDocument',
        builder: (context, state) => const AddDocumentPage(),
      ),
      GoRoute(
        path: '/search-document',
        name: 'searchDocument',
        builder: (context, state) => const SearchDocumentPage(),
      ),
      GoRoute(
        path: '/document-list',
        name: 'documentList',
        builder: (context, state) {
          final type = state.extra as String?;
          return DocumentListPage(documentType: type);
        },
      ),
      GoRoute(
        path: '/document-details/:id',
        name: 'documentDetails',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DocumentDetailsPage(documentId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
