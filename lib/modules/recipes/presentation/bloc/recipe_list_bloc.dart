import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

// ── Events ───────────────────────────────────────────────────────────
abstract class RecipeListEvent extends Equatable {
  const RecipeListEvent();
  @override
  List<Object?> get props => [];
}

class LoadRecipes extends RecipeListEvent {
  final String? query;
  final String? categoryId;
  final String? cuisine;
  final String? difficulty;
  final String? status;
  final bool? isFeatured;
  final bool? isTrending;
  final String sortBy;
  final bool ascending;
  final int limit;
  final int offset;

  const LoadRecipes({
    this.query,
    this.categoryId,
    this.cuisine,
    this.difficulty,
    this.status,
    this.isFeatured,
    this.isTrending,
    this.sortBy = 'created_at',
    this.ascending = false,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [
        query,
        categoryId,
        cuisine,
        difficulty,
        status,
        isFeatured,
        isTrending,
        sortBy,
        ascending,
        limit,
        offset,
      ];
}

class DeleteRecipeRequested extends RecipeListEvent {
  final String id;
  const DeleteRecipeRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// ── States ───────────────────────────────────────────────────────────
abstract class RecipeListState extends Equatable {
  const RecipeListState();
  @override
  List<Object?> get props => [];
}

class RecipeListInitial extends RecipeListState {}

class RecipeListLoading extends RecipeListState {}

class RecipeListLoaded extends RecipeListState {
  final List<Recipe> recipes;
  const RecipeListLoaded(this.recipes);
  @override
  List<Object?> get props => [recipes];
}

class RecipeListFailure extends RecipeListState {
  final String error;
  const RecipeListFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// ── BLoC ─────────────────────────────────────────────────────────────
class RecipeListBloc extends Bloc<RecipeListEvent, RecipeListState> {
  final RecipeRepository _recipeRepository;

  RecipeListBloc(this._recipeRepository) : super(RecipeListInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<DeleteRecipeRequested>(_onDeleteRecipe);
  }

  Future<void> _onLoadRecipes(LoadRecipes event, Emitter<RecipeListState> emit) async {
    emit(RecipeListLoading());
    try {
      final list = await _recipeRepository.getRecipes(
        query: event.query,
        categoryId: event.categoryId,
        cuisine: event.cuisine,
        difficulty: event.difficulty,
        status: event.status,
        isFeatured: event.isFeatured,
        isTrending: event.isTrending,
        sortBy: event.sortBy,
        ascending: event.ascending,
        limit: event.limit,
        offset: event.offset,
      );
      emit(RecipeListLoaded(list));
    } catch (e) {
      emit(RecipeListFailure(e.toString()));
    }
  }

  Future<void> _onDeleteRecipe(DeleteRecipeRequested event, Emitter<RecipeListState> emit) async {
    try {
      await _recipeRepository.deleteRecipe(event.id);
      add(const LoadRecipes());
    } catch (e) {
      emit(RecipeListFailure(e.toString()));
    }
  }
}
