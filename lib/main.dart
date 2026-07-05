import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';
import 'core/di/dependency_injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/snackbar_service.dart';

// Import Blocs
import 'modules/authentication/presentation/bloc/auth_bloc.dart';
import 'modules/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'modules/categories/presentation/bloc/category_bloc.dart';
import 'modules/tags/presentation/bloc/tag_bloc.dart';
import 'modules/users/presentation/bloc/user_bloc.dart';
import 'modules/recipes/presentation/bloc/recipe_list_bloc.dart';
import 'modules/recipes/presentation/bloc/recipe_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // 2. Initialize Dependency Injection
  await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => sl<DashboardBloc>(),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => sl<CategoryBloc>(),
        ),
        BlocProvider<TagBloc>(
          create: (context) => sl<TagBloc>(),
        ),
        BlocProvider<UserBloc>(
          create: (context) => sl<UserBloc>(),
        ),
        BlocProvider<RecipeListBloc>(
          create: (context) => sl<RecipeListBloc>(),
        ),
        BlocProvider<RecipeEditorBloc>(
          create: (context) => sl<RecipeEditorBloc>(),
        ),
        BlocProvider<RecipeImageCubit>(
          create: (context) => RecipeImageCubit(sl()),
        ),
        BlocProvider<IngredientCubit>(
          create: (context) => IngredientCubit(),
        ),
        BlocProvider<InstructionCubit>(
          create: (context) => InstructionCubit(),
        ),
        BlocProvider<PublishCubit>(
          create: (context) => PublishCubit(sl()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Recipely Studio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system, // Responsive theme matching system settings
        routerConfig: AppRouter.router,
        scaffoldMessengerKey: SnackbarService.messengerKey,
      ),
    );
  }
}
