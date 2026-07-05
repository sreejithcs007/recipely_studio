import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';

// ── Events ───────────────────────────────────────────────────────────
abstract class TagEvent extends Equatable {
  const TagEvent();
  @override
  List<Object?> get props => [];
}

class LoadTags extends TagEvent {}

class CreateTagRequested extends TagEvent {
  final String name;
  final String type;

  const CreateTagRequested({required this.name, required this.type});

  @override
  List<Object?> get props => [name, type];
}

class UpdateTagRequested extends TagEvent {
  final Tag tag;

  const UpdateTagRequested(this.tag);

  @override
  List<Object?> get props => [tag];
}

class DeleteTagRequested extends TagEvent {
  final String id;

  const DeleteTagRequested(this.id);

  @override
  List<Object?> get props => [id];
}

// ── States ───────────────────────────────────────────────────────────
abstract class TagState extends Equatable {
  const TagState();
  @override
  List<Object?> get props => [];
}

class TagInitial extends TagState {}

class TagLoading extends TagState {}

class TagLoaded extends TagState {
  final List<Tag> tags;

  const TagLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

class TagOperationSuccess extends TagState {
  final String message;

  const TagOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TagFailure extends TagState {
  final String error;

  const TagFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// ── BLoC ─────────────────────────────────────────────────────────────
class TagBloc extends Bloc<TagEvent, TagState> {
  final TagRepository _tagRepository;

  TagBloc(this._tagRepository) : super(TagInitial()) {
    on<LoadTags>(_onLoadTags);
    on<CreateTagRequested>(_onCreateTag);
    on<UpdateTagRequested>(_onUpdateTag);
    on<DeleteTagRequested>(_onDeleteTag);
  }

  Future<void> _onLoadTags(
    LoadTags event,
    Emitter<TagState> emit,
  ) async {
    emit(TagLoading());
    try {
      final list = await _tagRepository.getTags();
      emit(TagLoaded(list));
    } catch (e) {
      emit(TagFailure(e.toString()));
    }
  }

  Future<void> _onCreateTag(
    CreateTagRequested event,
    Emitter<TagState> emit,
  ) async {
    emit(TagLoading());
    try {
      await _tagRepository.createTag(
        Tag(id: '', name: event.name, type: event.type),
      );
      emit(const TagOperationSuccess('Tag created successfully!'));
      add(LoadTags());
    } catch (e) {
      emit(TagFailure(e.toString()));
    }
  }

  Future<void> _onUpdateTag(
    UpdateTagRequested event,
    Emitter<TagState> emit,
  ) async {
    emit(TagLoading());
    try {
      await _tagRepository.updateTag(event.tag);
      emit(const TagOperationSuccess('Tag updated successfully!'));
      add(LoadTags());
    } catch (e) {
      emit(TagFailure(e.toString()));
    }
  }

  Future<void> _onDeleteTag(
    DeleteTagRequested event,
    Emitter<TagState> emit,
  ) async {
    emit(TagLoading());
    try {
      await _tagRepository.deleteTag(event.id);
      emit(const TagOperationSuccess('Tag deleted successfully!'));
      add(LoadTags());
    } catch (e) {
      emit(TagFailure(e.toString()));
    }
  }
}
