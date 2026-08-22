import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/constants/congo_cities.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../domain/entities/document_entity.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';
import '../widgets/document_form_widgets.dart';

class AddDocumentPage extends StatefulWidget {
  const AddDocumentPage({super.key});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  CongoCity? _selectedCity;
  String? _selectedArrondissement;
  String _selectedType = AppConstants.documentTypes.first;
  File? _selectedImage;
  DocumentStatus _status = DocumentStatus.found;
  bool _isSubmitting = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection: $e')),
        );
      }
    }
  }

  Future<void> _pickCity() async {
    final selected = await showCityPicker(context);
    if (selected != null) {
      setState(() {
        _selectedCity = selected;
        _selectedArrondissement = null;
        _cityController.text = selected.name;
      });
    }
  }

  void _submitForm() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une image')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState.status != AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<DocumentBloc>().add(
          AddDocumentEvent(
            imageFile: _selectedImage!,
            type: _selectedType,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            finderId: authState.user!.uid,
            finderName: authState.user!.displayName,
            finderPhone: _phoneController.text.trim(),
            location: _selectedCity!.name,
            arrondissement: _selectedArrondissement ?? '',
            status: _status,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document publié avec succès !'),
                backgroundColor: AppColors.success,
              ),
            );
            // Publicité interstitielle après une publication réussie
            AdService.instance.showInterstitial();
            context.go('/home');
          }
          if (state is DocumentError) {
            if (_isSubmitting) setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is DocumentLoading;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                leading: const AppBackButton(),
                title: const Text('Publier un document'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImagePicker(isLoading),
                        const SizedBox(height: 24),

                        // Status Selection
                        SectionHeader(
                          icon: Icons.flag_outlined,
                          title: 'Statut du document',
                          subtitle:
                              'Indiquez si le document est trouvé ou perdu',
                        ),
                        const SizedBox(height: 12),
                        DocumentStatusSelector(
                          value: _status,
                          enabled: !isLoading,
                          onChanged: (status) =>
                              setState(() => _status = status),
                        ),
                        const SizedBox(height: 24),

                        // Informations
                        SectionHeader(
                          icon: Icons.title,
                          title: 'Informations',
                          subtitle: 'Détails du document',
                        ),
                        const SizedBox(height: 12),

                        // Type
                        DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Type de document',
                            hintText: 'Que cherchez-vous ?',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: AppConstants.documentTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => _selectedType = value);
                                  }
                                },
                        ),
                        const SizedBox(height: 16),

                        // Title
                        TextFormField(
                          controller: _titleController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Titre',
                            hintText: 'Ex: Carte d\'identité, Passeport...',
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer un titre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          enabled: !isLoading,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Décrivez le document trouvé/perdu...',
                            prefixIcon: Icon(Icons.description),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer une description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // City
                        TextFormField(
                          controller: _cityController,
                          enabled: !isLoading,
                          readOnly: true,
                          onTap: isLoading ? null : _pickCity,
                          decoration: const InputDecoration(
                            labelText: 'Ville',
                            hintText: 'Choisir une ville du Congo',
                            prefixIcon: Icon(Icons.location_city),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          validator: (value) {
                            if (_selectedCity == null) {
                              return 'Veuillez choisir une ville';
                            }
                            return null;
                          },
                        ),
                        if (_selectedCity != null) ...[
                          const SizedBox(height: 8),
                          ArrondissementDropdown(
                            city: _selectedCity!,
                            value: _selectedArrondissement,
                            enabled: !isLoading,
                            onChanged: (arrondissement) => setState(
                              () => _selectedArrondissement = arrondissement,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                            hintText: '06 635 24 55',
                            prefixIcon: Icon(Icons.phone),
                            helperText:
                                '9 chiffres commençant par 04, 05 ou 06',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer votre numéro';
                            }
                            final cleaned =
                                value.trim().replaceAll(RegExp(r'[\s.-]'), '');
                            final local = RegExp(r'^0[4-6]\d{7}$');
                            if (!local.hasMatch(cleaned)) {
                              return 'Numéro invalide (9 chiffres, 04/05/06)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton.icon(
                            onPressed: (isLoading || _isSubmitting)
                                ? null
                                : _submitForm,
                            icon: isLoading || _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.publish),
                            label: Text(
                              isLoading || _isSubmitting
                                  ? 'Publication...'
                                  : 'Publier',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePicker(bool isLoading) {
    return InkWell(
      onTap: isLoading ? null : _pickImage,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ImageActionBadge(
                        icon: Icons.edit,
                        label: 'Changer',
                        onTap: isLoading ? null : _pickImage,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ajouter une photo',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PNG, JPG — Taille max 80%',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
      ),
    );
  }
}