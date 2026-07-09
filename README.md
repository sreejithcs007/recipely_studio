# Recipely Studio

### Your Culinary Journey, Simplified.

Recipely Studio is a smart recipe companion designed to bridge the gap between inspiration and the kitchen. It empowers home cooks to discover curated meals, manage custom recipes, and execute step-by-step cooking instructions with absolute focus.

---

## Why Recipely?

*   **Interactive Guided Checklist:** Seamlessly track preparation lists and step instructions with checklist states to keep users organized in the kitchen.
*   **Media Library Management:** Upload images directly to Supabase storage buckets, retrieve public URLs, copy asset links, and delete unneeded files.
*   **Feature-First Scalability:** Built upon clean code principles that make adding features or refactoring modules predictable and modular.
*   **Aesthetic Analytics Dashboard:** Render beautiful data charts on user sessions, cooks, and saves to gauge application engagement.

---

## Features

### 🍽 Discovery
Browse recipe listings categorized by cuisines, difficulty levels, and spice intensity with text query filtering.

### 👨‍🍳 Cooking Experience
Follow structured, step-by-step instruction lists with clean check-off indicators to monitor progress.

### ❤️ Personalization
Create and update your own custom recipes using a multi-step builder wizard.

### ⚡ Performance
Navigate instantly between feeds with cached network image views and clean state caching.

---

## Tech Stack

| Category | Technology / Library |
| :--- | :--- |
| **Frontend** | Flutter (Dart SDK) |
| **Architecture** | Feature-First Clean Architecture |
| **State Management** | BLoC / Cubit (flutter_bloc) |
| **Backend & Database**| Supabase, PostgreSQL |
| **Routing** | GoRouter (go_router) |
| **Data Analytics** | FL Chart (fl_chart) |
| **Utilities** | GetIt (DI), CachedNetworkImage, CSV Parser |
| **Testing** | Flutter Test |

---

## Screenshots

| Feed Dashboard | Recipe Preview | Wizard Builder |
| :---: | :---: | :---: |
| ![Dashboard Placeholder](https://via.placeholder.com/280x600?text=Dashboard+Feed) | ![Recipe Preview Placeholder](https://via.placeholder.com/280x600?text=Recipe+Details) | ![Wizard Placeholder](https://via.placeholder.com/280x600?text=Creation+Wizard) |

---

## Architecture

This project is built using **Clean Architecture** principles structured in a **feature-first organization**. Each feature folder isolates its own data, domain, and presentation layers.
We decouple code layers using the **Repository Pattern** and implement **Dependency Injection** via GetIt to keep classes testable and mockable. Presentation views are assembled from reusable, modular widgets to keep layouts consistent and clean.

---

## Performance

✔ **Smooth scrolling** through long list feeds and complex nested grids.

✔ **Cached images** loaded from memory for instant visual feedback.

✔ **60 FPS animations** for page transitions, sliders, and selection states.

---

## Engineering Highlights

*   **State Management (BLoC/Cubit):** Utilizes unidirectional data flow to completely decouple business logic from the user interface.
*   **Media Upload & Storage:** Interacts directly with Supabase Storage buckets for uploading assets, handling public link resolution, and storage cleanup.
*   **Robust CSV Importer:** Built a custom RFC-4180 state-machine parser to process nested newlines and commas within spreadsheet cells without alignment shifting.
*   **Step Form Wizard:** Implemented inline list item modification widgets with stateful controllers to add, edit, and reorder steps and ingredients inside a unified multi-page form.

---

## Folder Structure

```text
lib/
├── core/                       # App-wide routing, theme tokens, and global DI services
│   ├── router/                 # Central GoRouter configuration and route registries
│   └── services/               # Common abstractions (dialogs, snackbars, permissions)
├── modules/                    # Isolated feature domains
│   ├── authentication/         # Sign-in workflows and admin user session blocks
│   ├── categories/             # Curated meal category grids and split aspect-ratio cards
│   ├── dashboard/              # Metrics overview, FL Chart widgets, and user insights
│   ├── media/                  # Media library asset manager and image copy/delete
│   └── recipes/                # Recipe lists, details, CSV parser, and wizard builder
│       ├── data/               # Models, repositories, and remote Supabase datasources
│       ├── domain/             # Business rules, use cases, and abstract repositories
│       └── presentation/       # Page views, nested widget components, and BLoC states
└── shared/                     # Global reusable UI widgets (badges, shimmers, layouts)
```

---

## Getting Started

### Prerequisites

*   Flutter SDK (v3.19+ recommended)
*   Dart SDK (v3.3+ recommended)
*   A Supabase database project with standard table schemas

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/recipely.git
    cd recipely
    ```

2.  Install dependencies:
    ```bash
    flutter pub get
    ```

3.  Configure database credentials:
    Create/update [lib/env.dart](file:///d:/New%20folder/recipely_studio/lib/env.dart) with your credentials:
    ```dart
    class Env {
      static const String supabaseUrl = 'YOUR_SUPABASE_URL';
      static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
    }
    ```

4.  Run the application:
    ```bash
    flutter run -d chrome  # Or your mobile emulator/device
    ```

---

## Future Improvements

*   **Offline Cache Synchronization:** Auto-sync offline edits to Supabase once an active connection is restored.
*   **Ingredient Unit Scaling:** Scale recipe ingredient quantities dynamically based on selected serving counts.
*   **Voice Control Integration:** Support hand-free step navigation via local text-to-speech commands.

---

## About the Developer

I design clean, scalable mobile architectures with an emphasis on performance and maintainability.

*   **Portfolio:** [yourportfolio.com](https://yourportfolio.com)
*   **LinkedIn:** [linkedin.com/in/yourprofile](https://linkedin.com/in/yourprofile)
*   **GitHub:** [github.com/yourusername](https://github.com/yourusername)
*   **Email:** [yourname@email.com](mailto:yourname@email.com)
