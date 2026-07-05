import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/error_states/error_state.dart';
import '../../../../shared/widgets/forms/custom_form_fields.dart';
import '../../../../shared/widgets/loading/shimmers.dart';
import '../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';

class CategoriesPage extends StatefulWidget {
  final bool openNew;
  const CategoriesPage({super.key, this.openNew = false});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Cycling icon backgrounds per card
  static const _iconBgs = [
    Color(0xFFFFF3DC),
    Color(0xFFE8F5E9),
    Color(0xFFFFE8EC),
    Color(0xFFE8EAF6),
    Color(0xFFE0F7FA),
    Color(0xFFFFEDE0),
    Color(0xFFF3E8FF),
    Color(0xFFE8FFEE),
  ];

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
    if (widget.openNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCategoryDialog();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryDialog([Category? category]) {
    showDialog(
      context: context,
      builder: (dialogContext) => _CategoryFormDialog(
        category: category,
        onSave: () => context.read<CategoryBloc>().add(LoadCategories()),
      ),
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
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryOperationSuccess) {
            GetIt.I<SnackbarService>().showSuccess(state.message);
          } else if (state is CategoryFailure) {
            GetIt.I<SnackbarService>().showError(state.error);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIBRARY',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Categories',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F0F0F),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Group recipes into curated collections that appear across the app.',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: const Color(0xFF8E8E8E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _showCategoryDialog(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'New Category',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Search bar ─────────────────────────────────────────────────
              SizedBox(
                width: 340,
                height: 44,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: GoogleFonts.inter(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    hintStyle: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFFADB5BD)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFFADB5BD)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Grid ───────────────────────────────────────────────────────
              Expanded(
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.25,
                        ),
                        itemCount: 8,
                        itemBuilder: (_, __) => ShimmerLoader(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 14,
                        ),
                      );
                    }

                    if (state is CategoryFailure && state is! CategoryOperationSuccess) {
                      return ErrorState(
                        message: state.error,
                        onRetry: () => context.read<CategoryBloc>().add(LoadCategories()),
                      );
                    }

                    if (state is CategoryLoaded || state is CategoryOperationSuccess) {
                      final categories = state is CategoryLoaded
                          ? state.categories
                          : (context.read<CategoryBloc>().state as CategoryLoaded).categories;

                      final filtered = categories
                          .where((c) => c.name.toLowerCase().contains(_searchQuery))
                          .toList();

                      if (filtered.isEmpty) {
                        return const EmptyState(
                          icon: Icons.category_outlined,
                          title: 'No Categories Found',
                          description: 'Try modifying your search or create a new category.',
                        );
                      }

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.25,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final cat = filtered[index];
                          final bg = _iconBgs[index % _iconBgs.length];
                          return _CategoryCard(
                            category: cat,
                            iconBg: bg,
                            onEdit: () => _showCategoryDialog(cat),
                            onDelete: () => _onDeleteCategory(cat),
                          );
                        },
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
}

// ── Category Card ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final Category category;
  final Color iconBg;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.iconBg,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final primaryColor = Theme.of(context).primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _hovered
            ? (Matrix4.identity()..translate(0.0, -4.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? primaryColor.withOpacity(0.25) : const Color(0xFFE2E8F0),
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: primaryColor.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 6))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
        ),
        child: Stack(
          children: [
            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circle icon with image
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.iconBg,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: cat.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: cat.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: widget.iconBg),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.grid_3x3_rounded,
                              size: 24,
                              color: primaryColor.withOpacity(0.6),
                            ),
                          )
                        : Icon(
                            Icons.grid_3x3_rounded,
                            size: 24,
                            color: primaryColor.withOpacity(0.6),
                          ),
                  ),
                  const Spacer(),
                  // Name
                  Text(
                    cat.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F0F0F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Recipe count
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${cat.recipeCount} ',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: 'recipes',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Hover actions — top right
            if (_hovered)
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    _ActionIcon(
                      icon: Icons.edit_outlined,
                      color: const Color(0xFF3B82F6),
                      tooltip: 'Edit',
                      onTap: widget.onEdit,
                    ),
                    const SizedBox(width: 4),
                    _ActionIcon(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFEF4444),
                      tooltip: 'Delete',
                      onTap: widget.onDelete,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

// ── Category Form Dialog (unchanged logic) ────────────────────────────────────
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
        final url = await GetIt.I<FileUploadService>().uploadFile(
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
        context.read<CategoryBloc>().add(CreateCategoryRequested(
              name: _nameController.text.trim(),
              imageUrl: _imageUrlController.text.trim(),
            ));
      } else {
        context.read<CategoryBloc>().add(UpdateCategoryRequested(
              widget.category!.copyWith(
                name: _nameController.text.trim(),
                imageUrl: _imageUrlController.text.trim(),
              ),
            ));
      }
      widget.onSave();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.category == null;
    final primaryColor = Theme.of(context).primaryColor;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isNew ? 'New Category' : 'Edit Category',
        style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Category Name',
                hintText: 'e.g. Breakfast, Desserts, Vegan',
                controller: _nameController,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Please enter a category name' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Image URL',
                hintText: 'Paste image link or upload below',
                controller: _imageUrlController,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Please provide an image URL' : null,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upload image:', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                  _isUploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload_rounded, size: 14),
                          label: const Text('Pick File'),
                          style: TextButton.styleFrom(foregroundColor: primaryColor),
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
          child: Text('Cancel', style: GoogleFonts.inter()),
        ),
        ElevatedButton(
          onPressed: _onSavePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(isNew ? 'Create' : 'Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
