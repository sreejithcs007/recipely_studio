import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/snackbar_service.dart';
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
  String? _selectedType; // null = All

  final _tabs = [
    {'label': 'All', 'value': null},
    {'label': 'Dietary', 'value': 'dietary'},
    {'label': 'Cuisine', 'value': 'cuisine'},
    {'label': 'Meal Type', 'value': 'meal_type'},
    {'label': 'Nutrition', 'value': 'nutrition'},
  ];

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
      builder: (_) => _TagFormDialog(
        tag: tag,
        onSave: () => context.read<TagBloc>().add(LoadTags()),
      ),
    );
  }

  void _onDeleteTag(Tag tag) async {
    if (tag.recipeCount > 0) {
      GetIt.I<SnackbarService>().showWarning(
        'Cannot delete "${tag.name}" — linked to ${tag.recipeCount} recipes.',
      );
      return;
    }
    final confirmed = await GetIt.I<DialogService>().showConfirmDialog(
      context: context,
      title: 'Delete Tag',
      message: 'Delete "${tag.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      context.read<TagBloc>().add(DeleteTagRequested(tag.id));
    }
  }

  static Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'dietary':   return const Color(0xFF3B9E74);
      case 'cuisine':   return const Color(0xFFFF6430);
      case 'meal_type': return const Color(0xFF3B82F6);
      case 'nutrition': return const Color(0xFFA855F7);
      default:          return const Color(0xFF8E8E8E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: BlocListener<TagBloc, TagState>(
        listener: (context, state) {
          if (state is TagOperationSuccess) {
            GetIt.I<SnackbarService>().showSuccess(state.message);
          } else if (state is TagFailure) {
            GetIt.I<SnackbarService>().showError(state.error);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
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
                          'Tags',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F0F0F),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        BlocBuilder<TagBloc, TagState>(
                          builder: (context, state) {
                            if (state is TagLoaded) {
                              final total = state.tags.length;
                              return Text(
                                '$total tags · Add cuisine labels, dietary filters, and nutritional attributes.',
                                style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF8E8E8E)),
                              );
                            }
                            return Text(
                              'Add cuisine labels, dietary filters, and nutritional attributes.',
                              style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF8E8E8E)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _showTagDialog(),
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
                            'New Tag',
                            style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Search / Sort bar ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                          style: GoogleFonts.inter(fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: 'Search tags...',
                            hintStyle: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFFADB5BD)),
                            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFFADB5BD)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => context.read<TagBloc>().add(LoadTags()),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF8E8E8E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Type tabs ─────────────────────────────────────────────────────
              Row(
                children: _tabs.map((tab) {
                  final isActive = _selectedType == tab['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = tab['value'] as String?),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF0F0F0F) : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          tab['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? Colors.white : const Color(0xFF6C757D),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // ── Table ─────────────────────────────────────────────────────────
              Expanded(
                child: BlocBuilder<TagBloc, TagState>(
                  builder: (context, state) {
                    if (state is TagLoading) {
                      return Column(
                        children: List.generate(6, (_) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ShimmerLoader(width: double.infinity, height: 56, borderRadius: 8),
                        )),
                      );
                    }
                    if (state is TagFailure && state is! TagOperationSuccess) {
                      return ErrorState(
                        message: state.error,
                        onRetry: () => context.read<TagBloc>().add(LoadTags()),
                      );
                    }
                    if (state is TagLoaded || state is TagOperationSuccess) {
                      final tags = state is TagLoaded
                          ? state.tags
                          : (context.read<TagBloc>().state as TagLoaded).tags;

                      final filtered = tags.where((t) {
                        final matchesSearch = t.name.toLowerCase().contains(_searchQuery);
                        final matchesType = _selectedType == null || t.type == _selectedType;
                        return matchesSearch && matchesType;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const EmptyState(
                          icon: Icons.tag_outlined,
                          title: 'No Tags Found',
                          description: 'Modify your search or create a new tag.',
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            // Header row
                            Container(
                              color: const Color(0xFFFAFAFA),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: const [
                                  Expanded(flex: 4, child: _ColLabel('TAG NAME')),
                                  Expanded(flex: 2, child: _ColLabel('TYPE')),
                                  Expanded(flex: 2, child: _ColLabel('RECIPES')),
                                  SizedBox(width: 80, child: _ColLabel('ACTIONS')),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            // Rows
                            Expanded(
                              child: ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF5F6F8)),
                                itemBuilder: (context, index) {
                                  final tag = filtered[index];
                                  return _TagRow(
                                    tag: tag,
                                    onEdit: () => _showTagDialog(tag),
                                    onDelete: () => _onDeleteTag(tag),
                                  );
                                },
                              ),
                            ),
                          ],
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
}

// ── Table header label ─────────────────────────────────────────────────────────
class _ColLabel extends StatelessWidget {
  final String text;
  const _ColLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: const Color(0xFFADB5BD),
      ),
    );
  }
}

// ── Tag Row ────────────────────────────────────────────────────────────────────
class _TagRow extends StatefulWidget {
  final Tag tag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TagRow({required this.tag, required this.onEdit, required this.onDelete});

  @override
  State<_TagRow> createState() => _TagRowState();
}

class _TagRowState extends State<_TagRow> {
  bool _hovered = false;

  static Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'dietary':   return const Color(0xFF3B9E74);
      case 'cuisine':   return const Color(0xFFFF6430);
      case 'meal_type': return const Color(0xFF3B82F6);
      case 'nutrition': return const Color(0xFFA855F7);
      default:          return const Color(0xFF8E8E8E);
    }
  }

  static String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'dietary':   return 'Dietary';
      case 'cuisine':   return 'Cuisine';
      case 'meal_type': return 'Meal Type';
      case 'nutrition': return 'Nutrition';
      default:          return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tag = widget.tag;
    final primaryColor = Theme.of(context).primaryColor;
    final typeColor = _typeColor(tag.type);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hovered ? const Color(0xFFFFF8F5) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Tag name with pill
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.label_outline_rounded, size: 13, color: Color(0xFF8E8E8E)),
                        const SizedBox(width: 5),
                        Text(
                          tag.name,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F0F0F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Type badge
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _typeLabel(tag.type),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Recipe count
            Expanded(
              flex: 2,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${tag.recipeCount} ',
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
                        color: const Color(0xFF8E8E8E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  _ActionIcon(
                    icon: Icons.edit_outlined,
                    color: const Color(0xFF3B82F6),
                    tooltip: 'Edit',
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: 6),
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

  const _ActionIcon({required this.icon, required this.color, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ── Tag Form Dialog (logic unchanged) ────────────────────────────────────────
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

  final _tagTypes = ['dietary', 'cuisine', 'meal_type', 'nutrition'];

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
        context.read<TagBloc>().add(CreateTagRequested(
              name: _nameController.text.trim(),
              type: _selectedType,
            ));
      } else {
        context.read<TagBloc>().add(UpdateTagRequested(
              widget.tag!.copyWith(
                name: _nameController.text.trim(),
                type: _selectedType,
              ),
            ));
      }
      widget.onSave();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.tag == null;
    final primaryColor = Theme.of(context).primaryColor;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isNew ? 'New Tag' : 'Edit Tag',
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
                label: 'Tag Name',
                hintText: 'e.g. Vegan, Keto, Spicy',
                controller: _nameController,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Please enter a tag name' : null,
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                label: 'Tag Type',
                value: _selectedType,
                items: _tagTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
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
          child: Text(
            isNew ? 'Create' : 'Save Changes',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
