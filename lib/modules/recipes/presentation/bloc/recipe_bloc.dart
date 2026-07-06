import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../../../core/services/file_upload_service.dart';

// ── Recipe Editor BLoC ────────────────────────────────────────────────
abstract class RecipeEditorEvent extends Equatable {
  const RecipeEditorEvent();
  @override
  List<Object?> get props => [];
}

class SaveRecipeRequested extends RecipeEditorEvent {
  final Recipe recipe;
  final List<String> categoryIds;
  final List<String> tagIds;

  const SaveRecipeRequested({
    required this.recipe,
    required this.categoryIds,
    required this.tagIds,
  });

  @override
  List<Object?> get props => [recipe, categoryIds, tagIds];
}

abstract class RecipeEditorState extends Equatable {
  const RecipeEditorState();
  @override
  List<Object?> get props => [];
}

class RecipeEditorInitial extends RecipeEditorState {}
class RecipeEditorSaving extends RecipeEditorState {}
class RecipeEditorSaveSuccess extends RecipeEditorState {
  final Recipe recipe;
  const RecipeEditorSaveSuccess(this.recipe);
  @override
  List<Object?> get props => [recipe];
}
class RecipeEditorSaveFailure extends RecipeEditorState {
  final String error;
  const RecipeEditorSaveFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class RecipeEditorBloc extends Bloc<RecipeEditorEvent, RecipeEditorState> {
  final RecipeRepository _recipeRepository;

  RecipeEditorBloc(this._recipeRepository) : super(RecipeEditorInitial()) {
    on<SaveRecipeRequested>(_onSaveRecipe);
  }

  Future<void> _onSaveRecipe(SaveRecipeRequested event, Emitter<RecipeEditorState> emit) async {
    emit(RecipeEditorSaving());
    try {
      final savedRecipe = await _recipeRepository.saveRecipe(
        event.recipe,
        event.categoryIds,
        event.tagIds,
      );
      emit(RecipeEditorSaveSuccess(savedRecipe));
    } catch (e) {
      emit(RecipeEditorSaveFailure(e.toString()));
    }
  }
}

// ── Recipe Image Cubit ────────────────────────────────────────────────
class RecipeImageState extends Equatable {
  final String imageUrl;
  final double progress;
  final bool isUploading;
  final String? error;

  const RecipeImageState({
    required this.imageUrl,
    required this.progress,
    required this.isUploading,
    this.error,
  });

  factory RecipeImageState.initial() {
    return const RecipeImageState(imageUrl: '', progress: 0, isUploading: false);
  }

  RecipeImageState copyWith({
    String? imageUrl,
    double? progress,
    bool? isUploading,
    String? error,
  }) {
    return RecipeImageState(
      imageUrl: imageUrl ?? this.imageUrl,
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [imageUrl, progress, isUploading, error];
}

class RecipeImageCubit extends Cubit<RecipeImageState> {
  final FileUploadService _fileUploadService;

  RecipeImageCubit(this._fileUploadService) : super(RecipeImageState.initial());

  Future<void> uploadImage(Uint8List bytes, String filename) async {
    emit(state.copyWith(isUploading: true, progress: 0.1, error: null));
    try {
      // Simulate progress indicator tick since web upload is binary direct
      emit(state.copyWith(progress: 0.4));
      
      final publicUrl = await _fileUploadService.uploadFile(
        bucket: 'recipe-images',
        fileName: '${DateTime.now().millisecondsSinceEpoch}_$filename',
        fileBytes: bytes,
      );
      
      emit(state.copyWith(imageUrl: publicUrl, progress: 1.0, isUploading: false));
    } catch (e) {
      emit(state.copyWith(isUploading: false, error: e.toString()));
    }
  }

  void setImageUrl(String url) {
    emit(state.copyWith(imageUrl: url, progress: 1.0, isUploading: false, error: null));
  }

  void clearImage() {
    emit(RecipeImageState.initial());
  }
}

// ── Ingredients Cubit ────────────────────────────────────────────────
class IngredientCubit extends Cubit<List<Ingredient>> {
  IngredientCubit() : super([]);

  void setIngredients(List<Ingredient> list) {
    emit(List<Ingredient>.from(list));
  }

  void addIngredient(Ingredient ing) {
    emit([...state, ing]);
  }

  void removeIngredient(int index) {
    final list = List<Ingredient>.from(state)..removeAt(index);
    emit(list);
  }

  void editIngredient(int index, Ingredient ing) {
    final list = List<Ingredient>.from(state);
    list[index] = ing;
    emit(list);
  }

  void reorderIngredients(int oldIndex, int newIndex) {
    var index = newIndex;
    if (oldIndex < newIndex) {
      index -= 1;
    }
    final list = List<Ingredient>.from(state);
    final item = list.removeAt(oldIndex);
    list.insert(index, item);
    emit(list);
  }

  void clear() {
    emit([]);
  }
}

// ── Instructions Cubit ───────────────────────────────────────────────
class InstructionCubit extends Cubit<List<StepItem>> {
  InstructionCubit() : super([]);

  void setSteps(List<StepItem> list) {
    emit(List<StepItem>.from(list)..sort((a, b) => a.stepNumber.compareTo(b.stepNumber)));
  }

  void addStep(String content) {
    final nextStepNumber = state.length + 1;
    emit([...state, StepItem(content: content, stepNumber: nextStepNumber)]);
  }

  void removeStep(int index) {
    final list = List<StepItem>.from(state)..removeAt(index);
    // Recalculate step numbers
    final updatedList = list.asMap().entries.map((entry) {
      return StepItem(content: entry.value.content, stepNumber: entry.key + 1);
    }).toList();
    emit(updatedList);
  }

  void editStep(int index, String newContent) {
    final list = List<StepItem>.from(state);
    list[index] = StepItem(content: newContent, stepNumber: list[index].stepNumber);
    emit(list);
  }

  void reorderSteps(int oldIndex, int newIndex) {
    var index = newIndex;
    if (oldIndex < newIndex) {
      index -= 1;
    }
    final list = List<StepItem>.from(state);
    final item = list.removeAt(oldIndex);
    list.insert(index, item);
    
    // Recalculate step numbers
    final updatedList = list.asMap().entries.map((entry) {
      return StepItem(content: entry.value.content, stepNumber: entry.key + 1);
    }).toList();
    emit(updatedList);
  }

  void clear() {
    emit([]);
  }
}

// ── Publish Cubit ────────────────────────────────────────────────────
class PublishState extends Equatable {
  final bool isSaving;
  final bool isSuccess;
  final String? error;

  const PublishState({required this.isSaving, required this.isSuccess, this.error});

  @override
  List<Object?> get props => [isSaving, isSuccess, error];
}

class PublishCubit extends Cubit<PublishState> {
  final RecipeRepository _recipeRepository;

  PublishCubit(this._recipeRepository) : super(const PublishState(isSaving: false, isSuccess: false));

  Future<void> updateStatus(Recipe recipe, String newStatus) async {
    emit(const PublishState(isSaving: true, isSuccess: false));
    try {
      final updated = recipe.copyWith(status: newStatus);
      await _recipeRepository.saveRecipe(updated, [], []); // Maintains existing junctions on supabase datasource if empty list passed (or queries them)
      emit(const PublishState(isSaving: false, isSuccess: true));
    } catch (e) {
      emit(PublishState(isSaving: false, isSuccess: false, error: e.toString()));
    }
  }

  Future<void> toggleFeatured(Recipe recipe, bool isFeatured) async {
    emit(const PublishState(isSaving: true, isSuccess: false));
    try {
      final updated = recipe.copyWith(isFeatured: isFeatured);
      await _recipeRepository.saveRecipe(updated, [], []);
      emit(const PublishState(isSaving: false, isSuccess: true));
    } catch (e) {
      emit(PublishState(isSaving: false, isSuccess: false, error: e.toString()));
    }
  }

  Future<void> toggleTrending(Recipe recipe, bool isTrending) async {
    emit(const PublishState(isSaving: true, isSuccess: false));
    try {
      final updated = recipe.copyWith(isTrending: isTrending);
      await _recipeRepository.saveRecipe(updated, [], []);
      emit(const PublishState(isSaving: false, isSuccess: true));
    } catch (e) {
      emit(PublishState(isSaving: false, isSuccess: false, error: e.toString()));
    }
  }
}
