import '../entities/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTags();
  Future<Tag> createTag(Tag tag);
  Future<Tag> updateTag(Tag tag);
  Future<void> deleteTag(String id);
}
