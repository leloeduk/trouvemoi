import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../documents/document_entity.dart';
import '../../../documents/presentation/widgets/document_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon profil')),
        body: const Center(child: Text('Utilisateur non connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.instance.firestore
            .collection(AppConstants.collectionDocuments)
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          return ResponsiveLayout(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileHeader(context, user.uid),
                const SizedBox(height: 24),
                Text(
                  'Mes publications',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (snapshot.hasError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Erreur: ${snapshot.error}'),
                    ),
                  )
                else if (!snapshot.hasData)
                  const Center(child: CircularProgressIndicator())
                else if (snapshot.data!.docs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 48),
                          SizedBox(height: 16),
                          Text("Vous n'avez pas encore publié de pièce"),
                        ],
                      ),
                    ),
                  )
                else
                  ...snapshot.data!.docs.map((doc) {
                    final document = DocumentEntity.fromFirestore(doc);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DocumentCard(
                        document: document,
                        onTap: () =>
                            context.push('/document-details/${doc.id}'),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirestoreService.instance.firestore
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final name = data?['displayName'] as String? ?? 'Utilisateur';
        final email = data?['email'] as String? ?? '';
        final photoUrl = data?['photoUrl'] as String?;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Text(name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 28))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
