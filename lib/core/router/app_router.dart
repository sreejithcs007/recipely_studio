import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Shell Layout
import '../../shared/widgets/navigation/admin_layout.dart';

// Pages
import '../../../modules/authentication/presentation/pages/login_page.dart';
import '../../../modules/dashboard/presentation/pages/dashboard_page.dart';
import '../../../modules/recipes/presentation/pages/recipe_list_page.dart';
import '../../../modules/recipes/presentation/pages/recipe_wizard_page.dart';
import '../../../modules/recipes/presentation/pages/recipe_preview_page.dart';
import '../../../modules/categories/presentation/pages/categories_page.dart';
import '../../../modules/tags/presentation/pages/tags_page.dart';
import '../../../modules/users/presentation/pages/users_page.dart';
import '../../../modules/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> parentNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: parentNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggingIn = state.uri.path == '/login';

      if (session == null) {
        // If not logged in, force navigation to login screen
        return loggingIn ? null : '/login';
      }

      // If logged in, block access to the login screen
      if (loggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: parentNavigatorKey,
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return AdminLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/recipes',
            builder: (context, state) => const RecipesListPage(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: parentNavigatorKey,
                builder: (context, state) => const RecipeWizardPage(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: parentNavigatorKey,
                builder: (context, state) {
                  final recipeId = state.pathParameters['id'];
                  return RecipeWizardPage(recipeId: recipeId);
                },
              ),
              GoRoute(
                path: 'preview/:id',
                parentNavigatorKey: parentNavigatorKey,
                builder: (context, state) {
                  final recipeId = state.pathParameters['id'];
                  return RecipePreviewPage(recipeId: recipeId!);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesPage(),
          ),
          GoRoute(
            path: '/tags',
            builder: (context, state) => const TagsPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
