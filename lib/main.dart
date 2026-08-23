import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routes/app_router.dart';
import 'core/services/ad_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_update_notifier.dart';
import 'core/widgets/connectivity_status.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/services/user_firebase_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/documents/data/repositories/document_repository_impl.dart';
import 'features/documents/data/services/document_firebase_service.dart';
import 'features/documents/presentation/bloc/document_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Mode hors ligne : cache local pour consulter les données sans connexion
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  // Publicités AdMob (bannière, interstitielle, app open, récompensée)
  await AdService.instance.init();
  // Notifications push
  final notificationService = NotificationService();
  await notificationService.initialize();
  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth Bloc
        BlocProvider(
          create: (_) => AuthBloc(
            AuthRepositoryImpl(UserFirebaseService()),
          ),
        ),
        // Document Bloc
        BlocProvider(
          create: (_) => DocumentBloc(
            DocumentRepositoryImpl(
              DocumentFirebaseService(notificationService: notificationService),
            ),
          ),
        ),
        // Profile Bloc
        BlocProvider(
          create: (context) => ProfileBloc(
            AuthRepositoryImpl(UserFirebaseService()),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Trouve Moi',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => AppUpdateNotifier(
          child: ConnectivityStatus(child: child!),
        ),
      ),
    );
  }
}
