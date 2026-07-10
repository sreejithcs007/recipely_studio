# Recipely Studio - Master Technical Documentation

Welcome to the Master Technical Documentation for **Recipely Studio**. This document serves as a comprehensive, production-grade reference manual for developers, architects, and mobile engineering leads. It reverse-engineers the entire codebase, explaining its architecture, components, data flows, Supabase integration, state management cycles, and deployment pipelines.

---

# SECTION 1: PROJECT OVERVIEW

## What This Project Does
Recipely Studio is a multi-platform administrative dashboard and editor application built using Flutter. It is designed to manage recipes, meal categories, tags, user profiles, and media library assets. The project integrates with Supabase for data hosting, user authentication, and storage operations.

## Purpose of the Application
The purpose is to provide administrators, chefs, and editors with a secure portal to:
1.  **Monitor Engagement Metrics**: Check user registrations, recipe metrics, popular categories, and system health charts.
2.  **Author Content (Recipes & Metadata)**: Manage recipe creations, edit ingredients, step instructions, rating, cost, and difficulty fields.
3.  **Perform Bulk Imports**: Parse Excel-generated CSV templates containing complex descriptions, comma listings, and inline newlines using an RFC-4180 state-machine parser.
4.  **Manage Media Library**: Upload photos directly to Supabase Storage, retrieve public URLs, copy asset links, and delete unused media files.

## Target Users
*   **System Administrators**: Monitor user profiles, engagement metrics, and clean up media storage.
*   **Chefs and Content Creators**: Write, edit, and organize recipe collections and categorizations.
*   **Data Operators**: Bulk-import recipes from standard spreadsheet exports.

## Main Features
*   **Aesthetic Analytics Dashboard**: View counts, saves, shares, and trends in real time.
*   **Step-by-step Recipe Wizard**: A multi-step form wizard (Details -> Media -> Ingredients -> Instructions -> Categories/Tags -> Review).
*   **Interactive List Items Editing**: Add, edit, delete, and reorder steps and ingredients on the fly.
*   **RFC-4180 State-Machine CSV Parser**: Safe importing of comma-heavy and multiline text.
*   **Media Library Portal**: Supabase storage browser with thumbnail previews, upload triggers, public URL copying, and file deletion.
*   **Categories Split Cards**: Aspect-ratio grids featuring category banners and automatic recipe count badge lookups.

## Architecture Style: Feature-First Clean Architecture
Recipely Studio is built using **Clean Architecture** organized by **features (modules)**. This combines:
*   **Clean Architecture Separation**: Isolating code into Presentation (UI, Blocs), Domain (Entities, Use Cases, Repositories), and Data (Models, Data Sources, Repositories Implementation) layers.
*   **Feature-First Structure**: Grouping code by business features (e.g. `recipes`, `categories`, `media`, `dashboard`, `authentication`) rather than generic technical layers, making navigation and domain updates easy.

```mermaid
graph TD
    UI[Presentation Layer: Widgets & UI] -->|User Interaction| BLoC[State Management: Blocs & Cubits]
    BLoC -->|Call Repositories| DomainRepo[Domain Layer: Abstract Repository Interfaces]
    DomainRepo -->|Data Mappings| DataRepoImpl[Data Layer: Repository Implementations]
    DataRepoImpl -->|CRUD Requests| RemoteDataSource[Data Layer: Supabase Remote Datasources]
    RemoteDataSource -->|HTTP Client / Websockets| Supabase[(Supabase Backend)]
```

## Why This Architecture Was Chosen
This structure is preferred for enterprise-grade Flutter applications due to its strict separation of business rules (Domain) from frameworks (Supabase, UI widgets, package dependencies). If the backend is migrated from Supabase to a custom REST API, only the Data source files change; the Domain and UI layers remain unaffected.

### Advantages
*   **Predictable Scalability**: New features can be created as independent directories without disturbing other modules.
*   **Exceptional Testability**: Business logic is decoupled from widgets, allowing easy unit testing of Cubits and Repositories.
*   **Modular Collaboration**: Developers can work on separate modules (e.g. `media` vs `users`) with minimal merge conflicts.

### Disadvantages
*   **Boilerplate Complexity**: Even simple features require creating Entities, Models, Repositories, Blocs, and Pages, increasing file count.
*   **Learning Curve**: Requires understanding clean separation rules and dependency injection configurations.

---

# SECTION 2: PROJECT STRUCTURE

The directory hierarchy follows a feature-first clean architecture:

```text
lib/
├── core/                       # App-wide routing, theme tokens, and global DI services
│   ├── di/                     # Dependency Injection setup (GetIt)
│   ├── router/                 # Central GoRouter configuration and route redirects
│   ├── services/               # Common abstractions (dialogs, snackbars, permissions)
│   └── theme/                  # Theme colors and typography
├── modules/                    # Feature directories (domain boundaries)
│   ├── authentication/         # Login interfaces, RLS provisioning, and sessions
│   ├── categories/             # CURD operations on meal categories and split cards
│   ├── dashboard/              # Metrics, analytic charts, and welcome widgets
│   ├── media/                  # Storage assets, upload portals, and link copies
│   ├── recipes/                # Recipe lists, details, wizard creator, and CSV parser
│   ├── settings/               # System theme and configuration settings
│   ├── tags/                   # Metadata tags grids and RLS management
│   └── users/                  # User accounts tracking and role colors
└── shared/                     # Global reusable UI widgets
    └── widgets/                # Common badges, forms, shimmers, and sidebars
```

## Folder Specifications

### `lib/core`
*   **Purpose**: Contains core framework settings, themes, route declarations, and global dependency registrations.
*   **Communication**: Imported by presentation pages and data source files to access global dependencies (`GetIt.I`), routing links, and common services (like `SnackbarService`).
*   **Contents**: `dependency_injection.dart`, `app_router.dart`, theme tokens, and dialog services.

### `lib/modules/[feature]`
*   **Purpose**: Contains isolated logical sections representing app features.
*   **Communication**: Internally structured into Data, Domain, and Presentation subdirectories. Cross-feature communication is handled using dependency injection interfaces.
*   **Structure**:
    *   `data/datasources`: Communicates directly with Supabase via `SupabaseClient`.
    *   `data/models`: Extends domain entities, implementing JSON serialization.
    *   `data/repositories`: Implements repository contracts, mapping models to entities.
    *   `domain/entities`: Plain Dart objects containing core fields.
    *   `domain/repositories`: Abstract interfaces defining repository functions.
    *   `presentation/bloc`: BLoC and Cubit state controllers.
    *   `presentation/pages`: Page views and layouts.

### `lib/shared`
*   **Purpose**: Contains reusable UI widgets (buttons, text fields, cards, loading indicators).
*   **Communication**: Imported by presentation pages across all features to enforce visual consistency.
*   **Contents**: Shimmer boxes, stats cards, custom badges, form textfields, and the `AdminLayout` navigation drawer.

---

# SECTION 3: FILE EXPLANATION

Here is the technical specification of the critical files in the codebase:

```mermaid
graph TD
    Main[main.dart] -->|Init dependencies| DI[dependency_injection.dart]
    Main -->|Load configuration| Router[app_router.dart]
    Router -->|Shell navigation layout| AdminLayout[admin_layout.dart]
    AdminLayout -->|Feature views| Dashboard[dashboard_page.dart]
    AdminLayout -->|Feature views| Recipes[recipe_list_page.dart]
    Recipes -->|Import spreadsheet data| ImportCsv[CSV State-Machine Parser]
    Recipes -->|Create/Edit recipe| Wizard[recipe_wizard_page.dart]
```

## `lib/main.dart`
*   **Purpose**: App entry point.
*   **Responsibility**: Initializes Flutter bindings, starts Supabase client, invokes Dependency Injection bindings, and boots the `MaterialApp.router` using BLoC state providers.
*   **Key Classes**: `MyApp` (StatelessWidget).
*   **Dependencies**: `supabase_flutter`, `flutter_bloc`, `app_router.dart`.
*   **Flow**: Runs `main()` -> waits for `Supabase.initialize` -> runs `initDependencies()` -> starts `runApp(const MyApp())`.

## `lib/env.dart`
*   **Purpose**: Environment configurations.
*   **Responsibility**: Declares constants for Supabase API URL and anonymous token.
*   **Key Classes**: `Env` (Utility class containing `supabaseUrl` and `supabaseAnonKey`).

## `lib/core/router/app_router.dart`
*   **Purpose**: App routing system.
*   **Responsibility**: Houses the `GoRouter` configuration, defining login route, navigation shells, page pathways, and session redirect guards.
*   **Key Classes**: `AppRouter`.
*   **Core Logic**: Checks if the user session is active. If `session == null`, redirects all traffic to `/login`.

## `lib/core/di/dependency_injection.dart`
*   **Purpose**: Dependency Injection (DI).
*   **Responsibility**: Registers singletons and factories for repositories, BLoCs, and data sources via `GetIt`.
*   **Key Functions**: `initDependencies()`.

## `lib/core/services/dialog_service.dart`
*   **Purpose**: Handles confirmation modals.
*   **Responsibility**: Displays dialogs for delete confirmations or data losses.
*   **Key Classes**: `DialogService`.

## `lib/core/services/snackbar_service.dart`
*   **Purpose**: User alerts.
*   **Responsibility**: Displays success, warning, or error snackbars across pages.
*   **Key Classes**: `SnackbarService`.

## `lib/core/services/file_upload_service.dart`
*   **Purpose**: File picker and storage interactions.
*   **Responsibility**: Picks local images and uploads them to Supabase Storage.
*   **Key Classes**: `FileUploadService`.

## `lib/modules/recipes/presentation/pages/recipe_list_page.dart`
*   **Purpose**: Displays the recipes dataset.
*   **Responsibility**: Displays recipes list and hosts the CSV import tool and download templates.
*   **Critical Logic**: Contains the `_parseCsv` state-machine.
*   **Key Classes**: `RecipesListPage`, `_ImportCsvDialog`.

## `lib/modules/recipes/presentation/pages/recipe_wizard_page.dart`
*   **Purpose**: Recipe creator/editor wizard.
*   **Responsibility**: Guides users through step-by-step recipe editing (details, cover media, inline ingredient/step additions, category linkages).
*   **Key Classes**: `RecipeWizardPage`.

## `lib/modules/categories/presentation/pages/categories_page.dart`
*   **Purpose**: Displays meal categories.
*   **Responsibility**: Renders category grid cards with automatic recipe count overlays.
*   **Key Classes**: `CategoriesPage`, `_CategoryCard`.

---

# SECTION 4: PACKAGE ANALYSIS

Here is a breakdown of the packages declared in `pubspec.yaml`:

| Package | Purpose | Why Added / Problem Solved |
| :--- | :--- | :--- |
| **`flutter_bloc`** | State Management | Enforces unidirectional data flow and clean separation of concerns. Decouples business logic from presentation widgets. |
| **`supabase_flutter`** | Database & Auth API | Directly handles connections to PostgreSQL tables, RLS authentication sessions, and Storage asset management. |
| **`go_router`** | Routing & Navigation | Native declarative routing. Handles nested shell paths, deep links, and login redirect guards. |
| **`get_it`** | Dependency Injection | Acts as a service locator. Decouples dependencies and makes class instances easily mockable in unit tests. |
| **`fl_chart`** | Analytics Visualization | Renders performant charts (line and bar charts) for user trends, save histories, and popular recipe distributions. |
| **`cached_network_image`** | Image Cache Management | Automatically caches downloaded images locally. Prevents redundant network downloads when scrolling. |
| **`file_picker` & `image_picker`** | Local Media Selection | Cross-platform utilities for selecting local recipe assets or spreadsheets for upload. |
| **`csv`** | Parsing backup support | Provides standard parsing functions, used as an entry point for CSV headers validation. |
| **`equatable`** | Value Equality | Implements `==` and `hashCode` comparison overrides for clean state changes and comparison checks. |

---

# SECTION 5: STATE MANAGEMENT

Recipely Studio uses **Flutter BLoC (and Cubit)** for state management. This separates UI rendering from data processing using events and states:

```mermaid
sequenceDiagram
    participant UI as User Interface
    participant BLoC as Bloc/Cubit Controller
    participant Repo as Recipe Repository
    participant Supabase as Supabase Database

    UI->>BLoC: Dispatch Event / Call Cubit Method
    activate BLoC
    BLoC->>UI: Emit State (e.g. LoadingState)
    BLoC->>Repo: Fetch / Save Data request
    activate Repo
    Repo->>Supabase: Execute CRUD query
    Supabase-->>Repo: Return data payload
    deactivate Repo
    BLoC-->>UI: Emit State (e.g. LoadedState / SuccessState)
    deactivate BLoC
    Note over UI: UI Rebuilds with new state details
```

## How It Works
1.  **State**: Immutable classes defining what is shown on screen (e.g., `RecipeListLoading`, `RecipeListLoaded`, `RecipeListError`).
2.  **Events**: Dispatched by the UI to request changes (e.g., `LoadRecipes`, `SearchRecipes`).
3.  **Blocs**: Listen to incoming events, fetch data from Repositories, and emit updated states.
4.  **Cubits**: Simplified BLoCs for structured features (like ingredients checklists), executing direct methods instead of processing events.

## Application Blocs/Cubits Specification

### `AuthBloc`
*   **States**: `AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`.
*   **Events**: `AuthCheckRequested`, `SignInRequested`, `SignOutRequested`.
*   **Role**: Handles admin credentials validation, session persistence, and logout requests.

### `RecipeListBloc`
*   **States**: `RecipeListInitial`, `RecipeListLoading`, `RecipeListLoaded`, `RecipeListError`.
*   **Events**: `LoadRecipes`, `DeleteRecipe`.
*   **Role**: Manages the main recipe grid view, filtering, and searches.

### `IngredientCubit` (Cubit)
*   **State**: `List<Ingredient>` (raw state array).
*   **Methods**: `addIngredient()`, `removeIngredient()`, `editIngredient()`, `reorderIngredients()`.
*   **Role**: Manages the checklist wizard data array.

---

# SECTION 6: APPLICATION FLOW

This flowchart shows the execution sequence when the application starts:

```mermaid
graph TD
    Start([1. Application Launch]) --> Bindings[2. WidgetsFlutterBinding.ensureInitialized]
    Bindings --> SupabaseInit[3. Initialize Supabase Client]
    SupabaseInit --> DIInit[4. Run initDependencies via GetIt]
    DIInit --> RunApp[5. Invoke runApp with MultiBlocProviders]
    RunApp --> RouterInit[6. Initialize GoRouter config]
    RouterInit --> AuthCheck[7. Execute AuthCheckRequested event]
    
    AuthCheck -->|No Active Session| LoginPage[8. Redirect to /login screen]
    AuthCheck -->|Valid Session Found| DashboardPage[9. Redirect to /dashboard page]
    
    LoginPage -->|Admin Logs In| DashboardPage
    DashboardPage -->|Navigate to Recipes| RecipeListPage[10. Show Recipes Grid]
```

## Execution Sequence
1.  **System Boot**: `main()` runs.
2.  **Supabase Initialized**: Fetches URL and Key configurations from `Env`.
3.  **DI Setup**: GetIt registers remote data sources, repositories, and BLoC managers.
4.  **UI Mount**: `MaterialApp.router` launches with configured light/dark theme models.
5.  **Auth Guard Evaluation**: GoRouter checks authentication status. If no user is logged in, it redirects to `/login`.
6.  **Admin Provisioning**: If logging in with the developer email `sreejithcs365@gmail.com`, the system automatically inserts/ensures an `'admin'` role record exists in the database `user_roles` table to prevent database RLS violations.

---

# SECTION 7: SCREEN FLOW

Below is the layout specification for each screen:

### Dashboard Page
*   **Purpose**: Displays system statistics, charts, and quick action shortcuts.
*   **UI Components**: Summary cards (recipes, categories, active users), dynamic bar charts (views, shares, saves), and a recent activity log.
*   **Navigation**: Default landing page. Links directly to the Media Library, Users profile list, and Recipe wizard editor.

### Recipe Creator Wizard
*   **Purpose**: A multi-step form for creating or editing recipes.
*   **UI Components**: Step indicators, text inputs, cover photo uploads, and dynamic ingredient/step modification tables.
*   **Editing Logic**: Clicking edit on a step or ingredient populates the form input fields and changes the action button to **Save**, allowing changes to be written to the checklist state.

### Media Library Portal
*   **Purpose**: Manage image assets in Supabase Storage.
*   **UI Components**: Search bars, thumbnail view grids, upload overlays, URL copy buttons, and file deletion triggers.

---

# SECTION 8: WIDGET TREE

This diagram shows the visual nesting of components for key page screens:

## Recipes List Page Layout Hierarchy

```text
RecipesListPage (Scaffold)
 ├── AppBar (Title, Add Recipe button)
 └── Body (Padding)
      └── Column
           ├── Row (Search Bar, Delimiter detector, Refresh, Import/Download buttons)
           └── Expanded (BlocBuilder<RecipeListBloc>)
                ├── RecipeListLoading -> Shimmer Grid
                ├── RecipeListError -> Error status view
                └── RecipeListLoaded
                     └── GridView.builder
                          └── RecipeCard (MouseRegion)
                               └── Card
                                    └── Column (Cover photo, Cuisine subtext, Title, Metrics, Status badge)
```

## Recipe Wizard Step 3 Hierarchy

```text
IngredientWizardView (BlocBuilder<IngredientCubit>)
 └── Column
      ├── Row (Form fields: Name, Qty, Unit, Optional checkbox, Add/Save button, Cancel button)
      └── Container (ListBorder)
           └── ListView.separated
                └── ListTile
                     ├── Title (Quantity + Name text)
                     └── Trailing (Row: Edit button, Delete button)
```

---

# SECTION 9: NAVIGATION

Navigational routing is configured using **GoRouter** in [app_router.dart](file:///d:/New%20folder/recipely_studio/lib/core/router/app_router.dart). It uses a single central configuration with a login guard:

```mermaid
graph TD
    AppRoute[AppRouter Root Config] --> LoginRoute[/login Route]
    AppRoute --> Shell[ShellRoute Navigation Layout]
    
    Shell --> DashRoute[/dashboard]
    Shell --> RecipesRoute[/recipes]
    Shell --> WizardRoute[/recipes/new OR /recipes/edit/:id]
    Shell --> MediaRoute[/media]
    Shell --> CategoriesRoute[/categories]
    Shell --> TagsRoute[/tags]
    Shell --> UsersRoute[/users]
```

## GoRouter Redirect Guard
```dart
redirect: (context, state) {
  final session = Supabase.instance.client.auth.currentSession;
  final loggingIn = state.uri.path == '/login';

  if (session == null) {
    return loggingIn ? null : '/login';
  }
  if (loggingIn) {
    return '/dashboard';
  }
  return null;
}
```

---

# SECTION 10: SUPABASE INTEGRATION

Supabase serves as the backend database, authentication provider, and asset storage system:

```mermaid
graph TD
    subgraph Client App
        AuthB[AuthBloc]
        DS[Remote Datasources]
        StorageS[FileUploadService]
    end

    subgraph Supabase Cloud
        AuthAPI[Auth Service: auth.users]
        DB[(PostgreSQL Database)]
        Storage[Storage Buckets: recipe-images]
    end

    AuthB -->|Login credentials| AuthAPI
    DS -->|SQL CRUD requests| DB
    StorageS -->|Upload image binary| Storage
```

## SQL CRUD Execution Examples

### Get Active Categories
```dart
final response = await _supabaseClient
    .from('categories')
    .select('*, recipe_categories(count)')
    .isFilter('deleted_at', null)
    .order('name');
```

### Save Recipe Transaction
```dart
// 1. Insert/Update Recipe core record
await _supabaseClient.from('recipes').insert(recipeData);

// 2. Clear old ingredients/steps/tags for update
await _supabaseClient.from('recipe_ingredients').delete().eq('recipe_id', id);

// 3. Re-insert updated ingredient lists
await _supabaseClient.from('recipe_ingredients').insert(ingredientsData);
```

---

# SECTION 11: DATABASE SCHEMA

The PostgreSQL database uses relational schemas configured with **Row-Level Security (RLS)** constraints.

```mermaid
erDiagram
    recipes {
        uuid id PK
        varchar title
        text description
        numeric rating
        integer prep_time_minutes
        integer cook_time_minutes
        numeric estimated_cost
        varchar status
        boolean is_featured
        boolean is_trending
    }
    recipe_ingredients {
        uuid id PK
        uuid recipe_id FK
        varchar name
        varchar quantity
        varchar quantity_unit
        integer index
    }
    recipe_steps {
        uuid id PK
        uuid recipe_id FK
        text step_content
        integer step_number
    }
    categories {
        uuid id PK
        varchar name
        varchar image_url
        timestamp deleted_at
    }
    recipe_categories {
        uuid recipe_id FK
        uuid category_id FK
    }
    tags {
        uuid id PK
        varchar name
        varchar type
    }
    recipe_tags {
        uuid recipe_id FK
        uuid tag_id FK
    }
    user_roles {
        uuid id PK
        uuid user_id FK
        varchar role
    }

    recipes ||--o{ recipe_ingredients : "contains"
    recipes ||--o{ recipe_steps : "contains"
    recipes ||--o{ recipe_categories : "linked"
    categories ||--o{ recipe_categories : "linked"
    recipes ||--o{ recipe_tags : "tagged"
    tags ||--o{ recipe_tags : "tagged"
```

## Database Table Relations
*   **`recipes`**: Stores the recipe metadata (title, description, rating, cost, featured flags).
*   **`recipe_ingredients`**: Linked to `recipes` via `recipe_id` (foreign key) with cascade deletes.
*   **`recipe_steps`**: Relates steps content to recipes.
*   **`recipe_categories`**: A junction table mapping recipes to meal categories.
*   **`recipe_tags`**: A junction table linking recipes to diet/metadata tags.
*   **`user_roles`**: Links UUID user accounts to system authorization levels (e.g. `'admin'`).

---

# SECTION 12: MODELS

Here are the serialization model entities in the project:

## Model: `RecipeModel`
Extends `Recipe` and overrides serialization methods:
```dart
factory RecipeModel.fromJson(Map<String, dynamic> json) {
  return RecipeModel(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    prepTimeMinutes: (json['prep_time_minutes'] ?? 10) as int,
    spiceLevel: (json['spice_level'] ?? 0) as int,
    isFeatured: json['is_featured'] as bool? ?? false,
    imageUrl: json['thumbnail_image_url'] as String? ?? '',
    ingredients: parseIngredients(json['recipe_ingredients']),
    steps: parseSteps(json['recipe_steps']),
    categories: parseCategories(json['recipe_categories']),
    tags: parseTags(json['recipe_tags']),
  );
}

Map<String, dynamic> toJson() {
  return {
    'title': title,
    'description': description,
    'rating': rating,
    'prep_time_minutes': prepTimeMinutes,
    'spice_level': spiceLevel,
    'is_featured': isFeatured,
    'thumbnail_image_url': imageUrl,
  };
}
```

---

# SECTION 13: SERVICES

The core layer exposes services registered via GetIt:

*   **`DialogService`**: Provides standard asynchronous alert boxes.
*   **`SnackbarService`**: Manages snackbar notifications using `scaffoldMessengerKey`.
*   **`FileUploadService`**: Handles picking and uploading files to Supabase Storage.
*   **`PermissionService`**: Reads permissions from the database `user_roles` table.

---

# SECTION 14: REPOSITORIES

The code implements the **Repository Pattern** to separate the presentation layer from backend APIs.

```mermaid
classDiagram
    class RecipeRepository {
        <<interface>>
        +getRecipes() List~Recipe~
        +getRecipeById(id) Recipe
        +saveRecipe(recipe, categoryIds, tagIds) Recipe
        +deleteRecipe(id) void
    }
    class RecipeRepositoryImpl {
        -RecipesRemoteDataSource remoteDataSource
        +getRecipes() List~Recipe~
        +getRecipeById(id) Recipe
        +saveRecipe(recipe, categoryIds, tagIds) Recipe
    }
    class RecipesRemoteDataSource {
        -SupabaseClient supabaseClient
        +getRecipes() List~RecipeModel~
        +saveRecipe(recipe, categoryIds, tagIds) RecipeModel
    }

    RecipeRepository <|-- RecipeRepositoryImpl
    RecipeRepositoryImpl --> RecipesRemoteDataSource
```

---

# SECTION 15: UTILITIES

*   **`AppTheme`**: Defines light and dark modes with secondary amber/orange tones, custom font styles, and rounded border configurations.
*   **Google Fonts**: Uses `GoogleFonts.inter` to ensure clean typography rendering across different platforms.

---

# SECTION 16: ANIMATIONS

*   **Hover Animations**: Navigation items and category cards use animated hover shifts.
*   **Stateful Widget Transitions**: Custom loading shimmers use sliding animation controllers to display state loading placeholders.

---

# SECTION 17: ERROR HANDLING

```mermaid
graph TD
    TryBlock[1. Run Asynchronous Task Try Block]
    TryBlock -->|Error Triggers| CatchBlock[2. Catch Exception]
    CatchBlock -->|Analyze Error Type| MatchError{3. Check Error Info}
    
    MatchError -->|RLS Error 42501| RlsError[4. Show Access Denied Alerts]
    MatchError -->|Constraint Error 23514| ConstraintError[5. Show Validation Constraints dialog]
    MatchError -->|CSV Formatting Error| CsvError[6. Print Steps detail dumps to Snackbar]
```

## Robust Error Handlers
*   **CSV Import Verification**: Displays constraint violations (like short step lengths) with a detailed dump in the error snackbar.
*   **Row-Level Security Guards**: Catches PostgreSQL `42501` errors and guides users on assigning role records.

---

# SECTION 18: DATA FLOW

This diagram shows how data travels through the application layers:

```mermaid
sequenceDiagram
    participant UI as Presentation View
    participant Bloc as RecipeBloc
    participant Repo as RecipeRepositoryImpl
    participant Remote as RecipesRemoteDataSource
    participant DB as Supabase PostgreSQL

    UI->>Bloc: Add(LoadRecipes)
    Bloc->>Repo: getRecipes()
    Repo->>Remote: getRecipes()
    Remote->>DB: SELECT * FROM recipes
    DB-->>Remote: Return JSON List
    Remote-->>Repo: Return List<RecipeModel>
    Repo-->>Bloc: Return List<Recipe>
    Bloc-->>UI: Emit(RecipeListLoaded)
    Note over UI: UI rebuilds, displaying cards
```

---

# SECTION 19: FUNCTION-BY-FUNCTION EXPLANATION

Here is an analysis of critical functions in the project:

## `_parseCsv` in [recipe_list_page.dart](file:///d:/New%20folder/recipely_studio/lib/modules/recipes/presentation/pages/recipe_list_page.dart)

### Implementation
```dart
List<Recipe> _parseCsv(String csvString) {
  // 1. Normalize smart quotes to standard double quotes
  final normalizedString = csvString
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('„', '"');

  // 2. Auto-detect delimiter from the first line
  String delimiter = ',';
  final firstLineEnd = normalizedString.indexOf('\n');
  final firstLine = firstLineEnd != -1 ? normalizedString.substring(0, firstLineEnd) : normalizedString;
  if (firstLine.contains(';')) {
    delimiter = ';';
  } else if (firstLine.contains('\t')) {
    delimiter = '\t';
  }

  // 3. RFC-4180 state-machine parsing loops
  final List<List<String>> csvTable = [];
  List<String> currentRow = [];
  final StringBuffer currentField = StringBuffer();
  bool inQuotes = false;
  
  // ... loop characters ...
  return recipes;
}
```

### Evaluation
*   **Why It Exists**: Handles comma and line break edge cases in CSV cells, which fail in standard split parsers.
*   **Complexity**: $O(N)$ where $N$ is the number of characters in the CSV string.

---

# SECTION 20: CODE REVIEW

## Good Practices
*   **Clear Separations**: Kept all database connections separated from page layouts.
*   **Dependency injection registry**: GetIt registers dependencies in one place, avoiding hardcoded instantiations.

## Areas for Improvement
*   **Cascade Deletes**: Some RLS setups rely on database settings. Re-insert transactions delete existing records first to avoid schema constraint errors, which could cause brief downtime during operations.

---

# SECTION 21: INTERVIEW PREPARATION

Here are key questions and answers based on this project to help you prepare for a technical interview:

### Q1: What architecture is used in Recipely Studio?
**A**: A feature-first clean architecture. Code is organized by feature modules (e.g. `recipes`, `categories`), with each feature containing isolated Presentation, Domain, and Data layers.

### Q2: How does the CSV importer handle commas and newlines inside description cells?
**A**: It uses an RFC-4180 state-machine parser. When it encounters double quotes, it ignores commas and newlines until a matching closing double quote is reached, preventing column shifts.

### Q3: What is RLS error code 42501, and how does the application handle it?
**A**: PostgreSQL error `42501` is a Row-Level Security policy violation. In Recipely Studio, the system resolves this by automatically provisioning an `admin` role row in the `user_roles` table for the developer email when they log in.

---

# SECTION 22: HOW TO MODIFY THIS PROJECT

To add a new feature (e.g., "Reviews" module):

```mermaid
graph TD
    Entity[1. Create Entity in domain/entities] --> RepoInterface[2. Define abstract Repository interface]
    RepoInterface --> Model[3. Create Model in data/models]
    Model --> RemoteDS[4. Create RemoteDataSource in data/datasources]
    RemoteDS --> RepoImpl[5. Implement Repository in data/repositories]
    RepoImpl --> BLoC[6. Create BLoC/Cubit state manager]
    BLoC --> DI[7. Register bindings in dependency_injection.dart]
    DI --> PageView[8. Build presentation page layout UI]
    PageView --> AppRouter[9. Register route path in app_router.dart]
```

---

# SECTION 23: APP EXECUTION WALKTHROUGH

Here is what happens step-by-step when a user opens the app:

```mermaid
sequenceDiagram
    participant OS as Device OS
    participant App as Flutter Engine
    participant Auth as AuthBloc
    participant DB as Supabase DB

    OS->>App: Launch App Binary
    activate App
    App->>App: Initialize bindings, services & DI
    App->>Auth: Dispatch AuthCheckRequested
    activate Auth
    Auth->>DB: Read current authenticated session
    DB-->>Auth: Session returns active user
    deactivate Auth
    App->>App: Load theme & router configuration
    App->>OS: Render Dashboard Page first frame
    deactivate App
```

---

# SECTION 24: SUMMARY

*   **Architecture**: Clean Architecture (Feature-First structure)
*   **State Management**: BLoC & Cubit
*   **Database**: PostgreSQL hosted on Supabase
*   **Production Readiness Rating**: **9.2 / 10**

---

# SECTION 25: BUILD, DEPLOYMENT & DEVOPS

## Flutter Build Process

### Build for Web
```bash
flutter build web --no-wasm-dry-run --release
```
*   **What it does**: Compiles Dart code into highly optimized JavaScript (`main.dart.js`), treeshakes unused fonts, and creates assets under `build/web`.

---

## Deployment Configuration: Netlify

Netlify hosts the compiled Flutter web application. It uses a configuration file to redirect routes to `index.html` so that Flutter's single-page router works correctly.

### `netlify.toml`
```toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```
This rule redirects all sub-paths (e.g., `/recipes`, `/media`) to the main entry point `index.html`, allowing `GoRouter` to handle the routing client-side without returning 404 errors.

---

# SECTION 26: COMPLETE PROJECT KNOWLEDGE CHECK

## Master Revision Cheat Sheet

*   **Clean Architecture**: UI -> BLoC -> Repository Interface -> Repository Implementation -> Data Source.
*   **Relational Schema**: Junction tables (`recipe_categories`, `recipe_tags`) map relationships, and `user_roles` dictates RLS authorization levels.
*   **CSV Import**: The custom state-machine parser reads characters sequentially, handling quote flags to avoid column shifts.

## 5-Minute Elevator Pitch
> *"Recipely Studio is a Flutter-based administrative portal structured on Clean Architecture with feature-first organization. It leverages BLoC and Cubit for clean, unidirectional state management and communicates with Supabase for authentication, storage, and PostgreSQL queries. Key highlights include an RFC-4180 state-machine CSV parser for bulk imports, relational database schemas protected by RLS, and a modular media library. The project uses GoRouter navigation redirects to ensure security, and compiles cleanly to Web and mobile platforms."*
