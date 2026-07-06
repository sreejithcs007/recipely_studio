import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/services/file_upload_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/loading/shimmers.dart';

class MediaLibraryPage extends StatefulWidget {
  const MediaLibraryPage({super.key});

  @override
  State<MediaLibraryPage> createState() => _MediaLibraryPageState();
}

class _MediaLibraryPageState extends State<MediaLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<FileObject> _files = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMediaFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMediaFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      // List all objects from the recipe-images bucket
      final List<FileObject> response = await client.storage
          .from('recipe-images')
          .list(
            searchOptions: const SearchOptions(
              limit: 100,
              sortBy: SortBy(column: 'created_at', order: 'desc'),
            ),
          );

      // Filter out folder placeholders (typically named '.emptyFolderPlaceholder')
      final filteredFiles = response.where((file) {
        return file.name != '.emptyFolderPlaceholder' && !file.name.startsWith('.');
      }).toList();

      setState(() {
        _files = filteredFiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load media files: $e';
      });
    }
  }

  Future<void> _uploadNewMedia() async {
    setState(() => _isUploading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isUploading = false);
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        throw Exception('Could not read selected file bytes.');
      }

      // Upload to bucket
      final fileName = 'media_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      await GetIt.I<FileUploadService>().uploadFile(
        bucket: 'recipe-images',
        fileName: fileName,
        fileBytes: bytes,
        contentType: _getMimeType(file.extension),
      );

      GetIt.I<SnackbarService>().showSuccess('Image uploaded successfully!');
      _loadMediaFiles();
    } catch (e) {
      GetIt.I<SnackbarService>().showError('Upload failed: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteMediaFile(String path) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Image', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to permanently delete this image from your storage? This action cannot be undone.', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await GetIt.I<FileUploadService>().deleteFile(
          bucket: 'recipe-images',
          path: path,
        );
        GetIt.I<SnackbarService>().showSuccess('Image deleted successfully!');
        _loadMediaFiles();
      } catch (e) {
        GetIt.I<SnackbarService>().showError('Delete failed: $e');
      }
    }
  }

  String _getMimeType(String? ext) {
    if (ext == null) return 'image/jpeg';
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg';
    }
  }

  List<FileObject> _getFilteredFiles() {
    if (_searchQuery.isEmpty) return _files;
    return _files.where((file) {
      return file.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final filtered = _getFilteredFiles();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page Header ──────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MANAGEMENT',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Media Library',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F0F0F),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_files.length} uploaded files in recipe-images bucket · Copy URLs to use in recipes/categories.',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: const Color(0xFF8E8E8E),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CircularProgressIndicator(),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _uploadNewMedia,
                    icon: const Icon(Icons.upload_rounded, size: 16, color: Colors.white),
                    label: Text('Upload Image', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Search & Filter bar ──────────────────────────────────────────
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
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: GoogleFonts.inter(fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: 'Search by file name...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: const Color(0xFFADB5BD),
                          ),
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
                    onTap: _loadMediaFiles,
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
            const SizedBox(height: 16),

            // ── Table / Grid Listing ─────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!, style: GoogleFonts.inter(color: Colors.red)))
                      : filtered.isEmpty
                          ? const EmptyState(
                              icon: Icons.image_not_supported_outlined,
                              title: 'No Images Found',
                              description: 'There are no image files uploaded matching your criteria.',
                            )
                          : _MediaTable(
                              files: filtered,
                              onDelete: _deleteMediaFile,
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        6,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ShimmerLoader(width: double.infinity, height: 56, borderRadius: 8),
        ),
      ),
    );
  }
}

// ── Media Data Table ──────────────────────────────────────────────────────────
class _MediaTable extends StatelessWidget {
  final List<FileObject> files;
  final ValueChanged<String> onDelete;

  const _MediaTable({required this.files, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table header
          _TableHeader(),
          // Divider
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Rows
          Expanded(
            child: ListView.separated(
              itemCount: files.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF5F6F8)),
              itemBuilder: (context, index) {
                final file = files[index];
                return _MediaRow(
                  file: file,
                  onDelete: () => onDelete(file.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Color(0xFFADB5BD),
    );
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: const [
          SizedBox(width: 48, child: Text('PREVIEW', style: labelStyle)),
          SizedBox(width: 16),
          Expanded(flex: 4, child: Text('FILE NAME & SIZE', style: labelStyle)),
          Expanded(flex: 5, child: Text('PUBLIC URL', style: labelStyle)),
          Expanded(flex: 2, child: Text('UPLOADED DATE', style: labelStyle)),
          SizedBox(width: 60, child: Align(alignment: Alignment.center, child: Text('ACTIONS', style: labelStyle))),
        ],
      ),
    );
  }
}

class _MediaRow extends StatefulWidget {
  final FileObject file;
  final VoidCallback onDelete;

  const _MediaRow({required this.file, required this.onDelete});

  @override
  State<_MediaRow> createState() => _MediaRowState();
}

class _MediaRowState extends State<_MediaRow> {
  bool _hovered = false;

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    final size = file.metadata?['size'] as int? ?? 0;
    
    // Retrieve public URL from Supabase Storage client
    final publicUrl = Supabase.instance.client.storage
        .from('recipe-images')
        .getPublicUrl(file.name);

    String dateString;
    if (file.createdAt != null) {
      try {
        final parsed = DateTime.parse(file.createdAt!);
        dateString = DateFormat('MMM dd, yyyy').format(parsed);
      } catch (_) {
        dateString = 'Unknown';
      }
    } else {
      dateString = 'Unknown';
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hovered ? const Color(0xFFFFF8F5) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Image Preview thumbnail
            SizedBox(
              width: 48,
              height: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: publicUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // File Name & Size
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F0F0F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatSize(size),
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF8E8E8E),
                    ),
                  ),
                ],
              ),
            ),

            // Public URL copying bar
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SelectableText(
                          publicUrl,
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: publicUrl));
                      GetIt.I<SnackbarService>().showSuccess('URL copied to clipboard!');
                    },
                    icon: const Icon(Icons.copy_rounded, size: 12),
                    label: Text('Copy', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            ),

            // Date uploaded
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  dateString,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFF8E8E8E),
                  ),
                ),
              ),
            ),

            // Delete action button
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete Image',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
