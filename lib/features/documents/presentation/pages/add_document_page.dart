import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../document_entity.dart';

class AddDocumentPage extends StatefulWidget {
  const AddDocumentPage({super.key});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _numeroController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _lieuController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedType;
  String? _selectedVille;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _numeroController.dispose();
    _telephoneController.dispose();
    _lieuController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = '${const Uuid().v4()}.jpg';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      context.showSnackBar('Veuillez sélectionner un type', isError: true);
      return;
    }
    if (_selectedVille == null) {
      context.showSnackBar('Veuillez sélectionner une ville', isError: true);
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) {
      context.showSnackBar('Vous devez être connecté', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl;
      if (_imageBytes != null && _imageName != null) {
        photoUrl = await StorageService.instance.uploadImage(
          path: 'documents',
          fileName: _imageName!,
          bytes: _imageBytes!,
        );
      }

      final doc = DocumentEntity(
        id: const Uuid().v4(),
        nom: _nomController.text.trim().toUpperCase(),
        prenom: _prenomController.text.trim().toUpperCase(),
        numero: _numeroController.text.trim().toUpperCase(),
        type: _selectedType!,
        ville: _selectedVille!,
        lieu: _lieuController.text.trim(),
        telephone: _telephoneController.text.trim(),
        photo: photoUrl,
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        status: 'trouvee',
        userId: user.uid,
      );

      await FirestoreService.instance.setDocument(
        collection: AppConstants.collectionDocuments,
        id: doc.id,
        data: doc.toJson(),
      );

      if (mounted) {
        context.showSnackBar('Pièce publiée avec succès !');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Erreur: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier une pièce')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ResponsiveLayout(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Photo',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3)),
                    ),
                    child: _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(_imageBytes!,
                                fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text('Ajouter une photo',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Informations du propriétaire',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(
                      labelText: 'Nom', prefixIcon: Icon(Icons.person)),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => Validators.required(v, 'Le nom'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prenomController,
                  decoration: const InputDecoration(
                      labelText: 'Prénom', prefixIcon: Icon(Icons.person)),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => Validators.required(v, 'Le prénom'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _numeroController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de la pièce',
                    prefixIcon: Icon(Icons.badge),
                    hintText: 'Ex: AB123456',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => Validators.required(v, 'Le numéro'),
                ),
                const SizedBox(height: 24),
                Text('Détails',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type de pièce',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: AppConstants.documentTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedType = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedVille,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: AppConstants.congoCities
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedVille = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lieuController,
                  decoration: const InputDecoration(
                    labelText: 'Lieu trouvé',
                    prefixIcon: Icon(Icons.place),
                    hintText: 'Ex: Rue de la Liberté, près de la mosquée',
                  ),
                  validator: (v) => Validators.required(v, 'Le lieu'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone de contact',
                    prefixIcon: Icon(Icons.phone),
                    hintText: 'Ex: 06 123 45 67',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnelle)',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Publier la pièce'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
