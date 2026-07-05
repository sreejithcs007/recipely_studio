import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

// ── Events ───────────────────────────────────────────────────────────
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class CreateCategoryRequested extends CategoryEvent {
  final String name;
  final String imageUrl;

  const CreateCategoryRequested({required this.name, required this.imageUrl});

  @override
  List<Object?> get props => [name, imageUrl];
}

class UpdateCategoryRequested extends CategoryEvent {
  final Category category;

  const UpdateCategoryRequested(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategoryRequested extends CategoryEvent {
  final String id;

  const DeleteCategoryRequested(this.id);

  @override
  List<Object?> get props => [id];
}

// ── States ───────────────────────────────────────────────────────────
abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;

  const CategoryLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoryOperationSuccess extends CategoryState {
  final String message;

  const CategoryOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryFailure extends CategoryState {
  final String error;

  const CategoryFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// ── BLoC ─────────────────────────────────────────────────────────────
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc(this._categoryRepository) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategoryRequested>(_onCreateCategory);
    on<UpdateCategoryRequested>(_onUpdateCategory);
    on<DeleteCategoryRequested>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final list = await _categoryRepository.getCategories();
      emit(CategoryLoaded(list));
    } catch (e) {
      emit(CategoryFailure(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await _categoryRepository.createCategory(
        Category(id: '', name: event.name, imageUrl: event.imageUrl),
      );
      emit(const CategoryOperationSuccess('Category created successfully!'));
      add(LoadCategories());
    } catch (e) {
      emit(CategoryFailure(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await _categoryRepository.updateCategory(event.category);
      emit(const CategoryOperationSuccess('Category updated successfully!'));
      add(LoadCategories());
    } catch (e) {
      emit(CategoryFailure(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await _categoryRepository.deleteCategory(event.id);
      emit(const CategoryOperationSuccess('Category deleted successfully!'));
      add(LoadCategories());
    } catch (e) {
      emit(CategoryFailure(e.toString()));
    }
  }
}
