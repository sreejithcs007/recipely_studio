import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/error_states/error_state.dart';
import '../../../../shared/widgets/forms/custom_form_fields.dart';
import '../../../../shared/widgets/loading/shimmers.dart';
import '../../domain/entities/tag.dart';
import '../bloc/tag_bloc.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<TagBloc>().add(LoadTags());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTagDialog([Tag? tag]) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _TagFormDialog(
          tag: tag,
          onSave: () {
            context.read<TagBloc>().add(LoadTags());
          },
        );
      },
    );
  }

  void _onDeleteTag(Tag tag) async {
    if (tag.recipeCount > 0) {
      GetIt.I<SnackbarService>().showWarning(
        'Cannot delete "${tag.name}" because it is linked to ${tag.recipeCount} recipes.',
      );
      return;
    }

    final confirmed = await GetIt.I<DialogService>().showConfirmDialog(
      context: context,
      title: 'Delete Tag',
      message: 'Are you sure you want to delete "${tag.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      context.read<TagBloc>().add(DeleteTagRequested(tag.id));
    }
  }

  Color _getTagTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'dietary':
        return Colors.green;
      case 'cuisine':
        return Colors.orange;
      case 'meal_type':
        return Colors.blue;
      case 'nutrition':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      body: BlocListener<TagBloc, TagState>(
        listener: (context, state) {
          if (state is TagOperationSuccess) {
            GetIt.I<SnackbarService>().showSuccess(state.message);
          } else if (state is TagFailure) {
            GetIt.I<SnackbarService>().showError(state.error);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tags Manager',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add cuisine labels, dietary filters, and nutritional attributes to recipes.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  PrimaryButton(
                    label: 'Create Tag',
                    icon: Icons.add,
                    onPressed: () => _showTagDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search Bar
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
                          hintText: 'Search tags...',
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
              // List Grid / Table
              Expanded(
                child: BlocBuilder<TagBloc, TagState>(
                  builder: (context, state) {
                    if (state is TagLoading) {
                      return _buildShimmerTable();
                    } else if (state is TagFailure && state is! TagOperationSuccess) {
                      return ErrorState(
                        message: state.error,
                        onRetry: () => context.read<TagBloc>().add(LoadTags()),
                      );
                    } else if (state is TagLoaded || state is TagOperationSuccess) {
                      final tags = state is TagLoaded
                          ? state.tags
                          : (context.read<TagBloc>().state as TagLoaded).tags;

                      final filteredTags = tags.where((tag) {
                        return tag.name.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (filteredTags.isEmpty) {
                        return const EmptyState(
                          icon: Icons.tag_outlined,
                          title: 'No Tags Found',
                          description: 'Modify your search criteria or add a new classification tag.',
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
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                isDark ? const Color(0xFF09090B) : const Color(0xFFF8FAFC),
                              ),
                              columns: [
                                DataColumn(
                                  label: Text(
                                    'Tag Name',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Category / Type',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Mapped Recipes',
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
                              rows: filteredTags.map((tag) {
                                final color = _getTagTypeColor(tag.type);
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        tag.name,
                                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: color.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          tag.type.toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${tag.recipeCount} recipes',
                                        style: GoogleFonts.inter(color: Colors.grey),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                            tooltip: 'Edit Tag',
                                            onPressed: () => _showTagDialog(tag),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            tooltip: 'Delete Tag',
                                            onPressed: () => _onDeleteTag(tag),
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
        6,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ShimmerLoader(width: double.infinity, height: 50, borderRadius: 6),
        ),
      ),
    );
  }
}

class _TagFormDialog extends StatefulWidget {
  final Tag? tag;
  final VoidCallback onSave;

  const _TagFormDialog({this.tag, required this.onSave});

  @override
  State<_TagFormDialog> createState() => _TagFormDialogState();
}

class _TagFormDialogState extends State<_TagFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _selectedType = 'dietary';

  final List<String> _tagTypes = ['dietary', 'cuisine', 'meal_type', 'nutrition'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name ?? '');
    _selectedType = widget.tag?.type ?? 'dietary';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      if (widget.tag == null) {
        context.read<TagBloc>().add(
              CreateTagRequested(
                name: _nameController.text.trim(),
                type: _selectedType,
              ),
            );
      } else {
        context.read<TagBloc>().add(
              UpdateTagRequested(
                widget.tag!.copyWith(
                  name: _nameController.text.trim(),
                  type: _selectedType,
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
    final isNew = widget.tag == null;

    return AlertDialog(
      title: Text(isNew ? 'Create Tag' : 'Edit Tag'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Tag Name',
                hintText: 'e.g. Vegan, Keto, Spicy, Dessert',
                controller: _nameController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter tag name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomDropdown<String>(
                label: 'Tag Type Classification',
                value: _selectedType,
                items: _tagTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
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
