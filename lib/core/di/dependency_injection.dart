import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Services
import '../services/storage_service.dart';
import '../services/dialog_service.dart';
import '../services/snackbar_service.dart';
import '../services/permission_service.dart';
import '../services/file_upload_service.dart';

// Authentication Feature
import '../../../modules/authentication/data/datasources/auth_remote_datasource.dart';
import '../../../modules/authentication/data/repositories/auth_repository_impl.dart';
import '../../../modules/authentication/domain/repositories/auth_repository.dart';
import '../../../modules/authentication/presentation/bloc/auth_bloc.dart';

// Dashboard Feature
import '../../../modules/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../../modules/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../../modules/dashboard/domain/repositories/dashboard_repository.dart';
import '../../../modules/dashboard/presentation/bloc/dashboard_bloc.dart';

// Categories Feature
import '../../../modules/categories/data/datasources/category_remote_datasource.dart';
import '../../../modules/categories/data/repositories/category_repository_impl.dart';
import '../../../modules/categories/domain/repositories/category_repository.dart';
import '../../../modules/categories/presentation/bloc/category_bloc.dart';

// Tags Feature
import '../../../modules/tags/data/datasources/tag_remote_datasource.dart';
import '../../../modules/tags/data/repositories/tag_repository_impl.dart';
import '../../../modules/tags/domain/repositories/tag_repository.dart';
import '../../../modules/tags/presentation/bloc/tag_bloc.dart';

// Users Feature
import '../../../modules/users/data/datasources/user_remote_datasource.dart';
import '../../../modules/users/data/repositories/user_repository_impl.dart';
import '../../../modules/users/domain/repositories/user_repository.dart';
import '../../../modules/users/presentation/bloc/user_bloc.dart';

// Recipes Feature
import '../../../modules/recipes/data/datasources/recipes_remote_datasource.dart';
import '../../../modules/recipes/data/repositories/recipe_repository_impl.dart';
import '../../../modules/recipes/domain/repositories/recipe_repository.dart';
import '../../../modules/recipes/presentation/bloc/recipe_bloc.dart';
import '../../../modules/recipes/presentation/bloc/recipe_list_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core client ────────────────────────────────────────────────────
  final supabaseClient = Supabase.instance.client;
  sl.registerSingleton<SupabaseClient>(supabaseClient);

  // ── Services ───────────────────────────────────────────────────────
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<DialogService>(() => DialogService());
  sl.registerLazySingleton<SnackbarService>(() => SnackbarService());
  sl.registerLazySingleton<PermissionService>(() => PermissionService(sl<SupabaseClient>()));
  sl.registerLazySingleton<FileUploadService>(() => FileUploadService(sl<SupabaseClient>()));

  // ── Authentication Feature ─────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));

  // ── Dashboard Feature ──────────────────────────────────────────────
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl<DashboardRemoteDataSource>()),
  );
  sl.registerFactory<DashboardBloc>(() => DashboardBloc(sl<DashboardRepository>()));

  // ── Categories Feature ──────────────────────────────────────────────
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSource(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<CategoryRemoteDataSource>()),
  );
  sl.registerFactory<CategoryBloc>(() => CategoryBloc(sl<CategoryRepository>()));

  // ── Tags Feature ───────────────────────────────────────────────────
  sl.registerLazySingleton<TagRemoteDataSource>(
    () => TagRemoteDataSource(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<TagRepository>(
    () => TagRepositoryImpl(sl<TagRemoteDataSource>()),
  );
  sl.registerFactory<TagBloc>(() => TagBloc(sl<TagRepository>()));

  // ── Users Feature ──────────────────────────────────────────────────
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl<UserRemoteDataSource>()),
  );
  sl.registerFactory<UserBloc>(() => UserBloc(sl<UserRepository>()));

  // ── Recipes Feature ────────────────────────────────────────────────
  sl.registerLazySingleton<RecipesRemoteDataSource>(
    () => RecipesRemoteDataSource(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(sl<RecipesRemoteDataSource>()),
  );
  sl.registerFactory<RecipeListBloc>(() => RecipeListBloc(sl<RecipeRepository>()));
  sl.registerFactory<RecipeEditorBloc>(() => RecipeEditorBloc(sl<RecipeRepository>()));
}
