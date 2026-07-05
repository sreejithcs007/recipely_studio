import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

// ── Events ───────────────────────────────────────────────────────────
abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {
  final String? query;
  final int limit;
  final int offset;

  const LoadUsers({this.query, this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [query, limit, offset];
}

// ── States ───────────────────────────────────────────────────────────
abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserProfile> users;

  const UserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserFailure extends UserState {
  final String error;

  const UserFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// ── BLoC ─────────────────────────────────────────────────────────────
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final list = await _userRepository.getUsers(
        query: event.query,
        limit: event.limit,
        offset: event.offset,
      );
      emit(UserLoaded(list));
    } catch (e) {
      emit(UserFailure(e.toString()));
    }
  }
}
