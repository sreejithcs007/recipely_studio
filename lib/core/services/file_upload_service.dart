import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileUploadService {
  final SupabaseClient _supabaseClient;

  FileUploadService(this._supabaseClient);

  Future<String> uploadFile({
    required String bucket,
    required String fileName,
    required Uint8List fileBytes,
    String contentType = 'image/jpeg',
  }) async {
    // 1. Upload the file to Supabase Storage
    await _supabaseClient.storage.from(bucket).uploadBinary(
          fileName,
          fileBytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );

    // 2. Fetch and return the public URL
    final String publicUrl =
        _supabaseClient.storage.from(bucket).getPublicUrl(fileName);

    return publicUrl;
  }

  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _supabaseClient.storage.from(bucket).remove([path]);
  }
}
