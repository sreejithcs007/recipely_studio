import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Category>> getCategories() async {
    final models = await _remoteDataSource.getCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Category> createCategory(Category category) async {
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      imageUrl: category.imageUrl,
    );
    final result = await _remoteDataSource.createCategory(model);
    return result.toEntity();
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      imageUrl: category.imageUrl,
    );
    final result = await _remoteDataSource.updateCategory(model);
    return result.toEntity();
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _remoteDataSource.deleteCategory(id);
  }
}
