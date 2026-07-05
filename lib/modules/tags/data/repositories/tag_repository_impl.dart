import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_remote_datasource.dart';
import '../models/tag_model.dart';

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource _remoteDataSource;

  TagRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Tag>> getTags() async {
    final models = await _remoteDataSource.getTags();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Tag> createTag(Tag tag) async {
    final model = TagModel(
      id: tag.id,
      name: tag.name,
      type: tag.type,
    );
    final result = await _remoteDataSource.createTag(model);
    return result.toEntity();
  }

  @override
  Future<Tag> updateTag(Tag tag) async {
    final model = TagModel(
      id: tag.id,
      name: tag.name,
      type: tag.type,
    );
    final result = await _remoteDataSource.updateTag(model);
    return result.toEntity();
  }

  @override
  Future<void> deleteTag(String id) async {
    await _remoteDataSource.deleteTag(id);
  }
}
