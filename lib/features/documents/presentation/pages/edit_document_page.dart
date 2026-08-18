import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/congo_cities.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../domain/entities/document_entity.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';
import '../widgets/document_form_widgets.dart';

class EditDocumentPage extends StatefulWidget {
  final String docId;

  const EditDocumentPage({super.key, required this.docId});

  @override
  State<EditDocumentPage> createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  DocumentEntity? _document;
  CongoCity? _selectedCity;
  String _selectedType = AppConstants.documentTypes.first;
  File? _selectedImage;
  DocumentStatus _status = DocumentStatus.found;
  bool _prefilled = false;
  bool _isSubmitting = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<DocumentBloc>().add(LoadDocumentByIdEvent(widget.docId));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  CongoCity _cityFromName(String name) {
    for (final city in CongoCities.all) {
      if (city.name == name) return city;
    }
    return CongoCities.all.last;
  }

  void _prefill(DocumentEntity doc) {
    if (_prefilled) return;
    _prefilled = true;

    _document = doc;
    _selectedType = doc.type.isEmpty ? AppConstants.documentTypes.first : doc.type;
    _selectedCity = _cityFromName(doc.location);
    _status = doc.status;

    _titleController.text = doc.title;
    _descriptionController.text = doc.description;
    _cityController.text = _selectedCity!.name;
    _phoneController.text = doc.finderPhone;
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
        _cityController.text = selected.name;
      });
    }
  }

  void _submitForm() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    final doc = _document;
    if (doc == null) return;

    setState(() => _isSubmitting = true);

    context.read<DocumentBloc>().add(
          UpdateDocumentEvent(
            id: doc.id,
            type: _selectedType,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            imageUrl: doc.imageUrl,
            imageFile: _selectedImage,
            finderId: doc.finderId,
            finderName: doc.finderName,
            finderPhone: _phoneController.text.trim(),
            location: _selectedCity!.name,
            date: doc.date,
            status: _status,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Modifier la publication'),
      ),
      body: BlocConsumer<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentDetailLoaded) {
            _prefill(state.document);
          }
          if (state is DocumentUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Publication mise à jour'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/my-publications');
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
          final doc = _document;
          if (doc == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isSaving = state is DocumentLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePicker(isSaving, doc),
                  const SizedBox(height: 24),

                  SectionHeader(
                    icon: Icons.flag_outlined,
                    title: 'Statut du document',
                    subtitle: 'Indiquez si le document est trouvé ou perdu',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<DocumentStatus>(
                      segments: const [
                        ButtonSegment(
                          value: DocumentStatus.found,
                          label: Text('Trouvé'),
                          icon: Icon(Icons.check_circle),
                        ),
                        ButtonSegment(
                          value: DocumentStatus.lost,
                          label: Text('Perdu'),
                          icon: Icon(Icons.search),
                        ),
                      ],
                      selected: {_status},
                      showSelectedIcon: false,
                      onSelectionChanged: isSaving
                          ? null
                          : (selection) {
                              setState(() {
                                _status = selection.first;
                              });
                            },
                    ),
                  ),
                  const SizedBox(height: 24),

                  SectionHeader(
                    icon: Icons.title,
                    title: 'Informations',
                    subtitle: 'Détails du document',
                  ),
                  const SizedBox(height: 12),

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
                    onChanged: isSaving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                            }
                          },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _titleController,
                    enabled: !isSaving,
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

                  TextFormField(
                    controller: _descriptionController,
                    enabled: !isSaving,
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

                  TextFormField(
                    controller: _cityController,
                    enabled: !isSaving,
                    readOnly: true,
                    onTap: isSaving ? null : _pickCity,
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
                    Text(
                      'Département : ${_selectedCity!.department}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    enabled: !isSaving,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      hintText: '06 635 24 55',
                      prefixIcon: Icon(Icons.phone),
                      helperText: '9 chiffres commençant par 04, 05 ou 06',
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

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: (isSaving || _isSubmitting)
                          ? null
                          : _submitForm,
                      icon: isSaving || _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        isSaving || _isSubmitting
                            ? 'Enregistrement...'
                            : 'Enregistrer',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePicker(bool isSaving, DocumentEntity doc) {
    final imageUrl = doc.imageUrl;
    final showImage = _selectedImage != null;

    return InkWell(
      onTap: isSaving ? null : _pickImage,
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
        child: showImage || imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (showImage)
                      Image.file(_selectedImage!, fit: BoxFit.cover)
                    else
                      Image.network(imageUrl, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ImageActionBadge(
                        icon: Icons.edit,
                        label: 'Changer',
                        onTap: isSaving ? null : _pickImage,
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
                ],
              ),
      ),
    );
  }
}