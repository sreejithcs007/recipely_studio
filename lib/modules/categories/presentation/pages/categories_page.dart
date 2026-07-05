import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/error_states/error_state.dart';
import '../../../../shared/widgets/forms/custom_form_fields.dart';
import '../../../../shared/widgets/loading/shimmers.dart';
import '../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryDialog([Category? category]) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _CategoryFormDialog(
          category: category,
          onSave: () {
            context.read<CategoryBloc>().add(LoadCategories());
          },
        );
      },
    );
  }

  void _onDeleteCategory(Category category) async {
    if (category.recipeCount > 0) {
      GetIt.I<SnackbarService>().showWarning(
        'Cannot delete "${category.name}" because it is linked to ${category.recipeCount} recipes.',
      );
      return;
    }

    final confirmed = await GetIt.I<DialogService>().showConfirmDialog(
      context: context,
      title: 'Delete Category',
      message: 'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      context.read<CategoryBloc>().add(DeleteCategoryRequested(category.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryOperationSuccess) {
            GetIt.I<SnackbarService>().showSuccess(state.message);
          } else if (state is CategoryFailure) {
            GetIt.I<SnackbarService>().showError(state.error);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories Directory',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Organize recipes into categories and upload classification graphics.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  PrimaryButton(
                    label: 'Create Category',
                    icon: Icons.add,
                    onPressed: () => _showCategoryDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search Filter Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 400,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim().toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search categories...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Table List
              Expanded(
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return _buildShimmerTable();
                    } else if (state is CategoryFailure && state is! CategoryOperationSuccess) {
                      return ErrorState(
                        message: state.error,
                        onRetry: () => context.read<CategoryBloc>().add(LoadCategories()),
                      );
                    } else if (state is CategoryLoaded || state is CategoryOperationSuccess) {
                      final categories = state is CategoryLoaded
                          ? state.categories
                          : (context.read<CategoryBloc>().state as CategoryLoaded).categories;

                      final filteredCategories = categories.where((cat) {
                        return cat.name.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (filteredCategories.isEmpty) {
                        return const EmptyState(
                          icon: Icons.category_outlined,
                          title: 'No Categories Found',
                          description: 'Try modifying your search filter or create a new category.',
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                isDark ? const Color(0xFF09090B) : const Color(0xFFF8FAFC),
                              ),
                              columns: [
                                DataColumn(
                                  label: Text(
                                    'Image',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Category Name',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Recipes Count',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Actions',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                              rows: filteredCategories.map((cat) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: cat.imageUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: cat.imageUrl,
                                                width: 36,
                                                height: 36,
                                                fit: BoxFit.cover,
                                                errorWidget: (c, u, e) => Container(
                                                  width: 36,
                                                  height: 36,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.image_not_supported, size: 16),
                                                ),
                                              )
                                            : Container(
                                                width: 36,
                                                height: 36,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.category, size: 16),
                                              ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        cat.name,
                                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                        child: Text(
                                          '${cat.recipeCount} recipes',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                            tooltip: 'Edit Category',
                                            onPressed: () => _showCategoryDialog(cat),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            tooltip: 'Delete Category',
                                            onPressed: () => _onDeleteCategory(cat),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerTable() {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ShimmerLoader(width: double.infinity, height: 50, borderRadius: 6),
        ),
      ),
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final Category? category;
  final VoidCallback onSave;

  const _CategoryFormDialog({this.category, required this.onSave});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _imageUrlController = TextEditingController(text: widget.category?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.first.bytes != null) {
      final file = result.files.first;
      setState(() => _isUploading = true);
      try {
        final service = GetIt.I<FileUploadService>();
        final url = await service.uploadFile(
          bucket: 'recipe-images',
          fileName: 'category_${DateTime.now().millisecondsSinceEpoch}_${file.name}',
          fileBytes: file.bytes!,
        );
        setState(() {
          _imageUrlController.text = url;
          _isUploading = false;
        });
      } catch (e) {
        setState(() => _isUploading = false);
        GetIt.I<SnackbarService>().showError('Image upload failed: $e');
      }
    }
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      if (widget.category == null) {
        context.read<CategoryBloc>().add(
              CreateCategoryRequested(
                name: _nameController.text.trim(),
                imageUrl: _imageUrlController.text.trim(),
              ),
            );
      } else {
        context.read<CategoryBloc>().add(
              UpdateCategoryRequested(
                widget.category!.copyWith(
                  name: _nameController.text.trim(),
                  imageUrl: _imageUrlController.text.trim(),
                ),
              ),
            );
      }
      widget.onSave();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.category == null;

    return AlertDialog(
      title: Text(isNew ? 'Create New Category' : 'Edit Category'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Category Name',
                hintText: 'e.g. Italian, Desserts, Keto',
                controller: _nameController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Image URL',
                hintText: 'Paste image link or upload one',
                controller: _imageUrlController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please provide a category image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload graphics:',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                  ),
                  _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : OutlineBtn(
                          label: 'Pick File',
                          icon: Icons.upload_file,
                          onPressed: _pickImage,
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSavePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(isNew ? 'Create' : 'Save Changes'),
        ),
      ],
    );
  }
}
