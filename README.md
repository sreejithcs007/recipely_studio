# Recipely

### Your Culinary Journey, Simplified.

Recipely is a smart recipe companion designed to bridge the gap between inspiration and the kitchen. It empowers home cooks to discover curated meals, manage custom recipes, and execute step-by-step cooking instructions with absolute focus.

---

## Why Recipely?

*   **Interactive Guided Cooking:** Keeps your screen active and guides you through cooking processes without distractions.
*   **Intuitive & Fluid Interface:** Designed with micro-interactions and polished layouts that prioritize readability in active kitchen environments.
*   **Feature-First Scalability:** Built upon clean code principles that make adding features or refactoring modules predictable and seamless.
*   **Optimized Asset Delivery:** Handles network-heavy images and rich UI states efficiently, ensuring smooth operation even on lower-end devices.

---

## Features

### 🍽 Discovery
Browse curated recipe listings categorized by cuisines, difficulty levels, and spice intensity with smart text search.

### 👨‍🍳 Cooking Experience
Follow structured, step-by-step instruction lists with clean checklist views to track your active preparation step.

### ❤️ Personalization
Create, edit, and organize your own custom recipes using an intuitive multi-step builder wizard.

### ⚡ Performance
Navigate instantly between feeds with cached content, optimized lazy loading, and quick-loading list layouts.

### ♿ Accessibility
Enjoy comfortable legibility with clear contrast layouts, high-contrast badges, and support for screen scaling.

---

## Tech Stack

| Category | Technology / Library |
| :--- | :--- |
| **Frontend** | Flutter (Dart SDK) |
| **Architecture** | Feature-First Clean Architecture |
| **State Management** | BLoC / Cubit |
| **Backend** | Supabase Backend-as-a-Service |
| **Database** | PostgreSQL (Supabase) |
| **Routing** | GoRouter |
| **Local Storage** | Hydrated BLoC / Shared Preferences |
| **Utilities** | GetIt (DI), CachedNetworkImage, CSV Parser |
| **Testing** | Bloc Test, Mockito |

---

## Screenshots

| Feed Dashboard | Recipe Preview | Wizard Builder |
| :---: | :---: | :---: |
| ![Dashboard Placeholder](https://via.placeholder.com/280x600?text=Dashboard+Feed) | ![Preview Placeholder](https://via.placeholder.com/280x600?text=Recipe+Details) | ![Wizard Placeholder](https://via.placeholder.com/280x600?text=Creation+Wizard) |

---

## Architecture

This project is built using **Clean Architecture** principles structured in a **feature-first organization**. Each feature folder isolates its own data, domain, and presentation layers.
We decouple code layers using the **Repository Pattern** and implement **Dependency Injection** via GetIt to keep classes testable and mockable. Presentation views are assembled from highly reusable, modular widgets to keep layouts consistent and clean.

---

## Performance

✔ **Smooth scrolling** through long list feeds and complex nested grids.

✔ **Optimized rebuilds** preventing unnecessary widget tree refreshes.

✔ **Cached images** loaded from memory for instant visual feedback.

✔ **Lazy loading** of recipes to reduce initial network payloads.

✔ **60 FPS animations** for page transitions, sliders, and selection states.

✔ **Responsive layouts** scaling seamlessly across various mobile and web viewport sizes.

---

## Engineering Highlights

*   **State Management (BLoC/Cubit):** Utilizes unidirectional data flow to completely decouple business logic from the user interface.
*   **Fine-Grained Rebuilds (BlocSelector):** Limits widget updates to specific fields, preventing entire list cards from rebuilding when unrelated properties change.
*   **Render Performance (RepaintBoundary):** Isolates complex visual layers (like custom loading shimmers and sliders) into independent layers to minimize GPU paint costs.
*   **Media Caching & Sizing:** Optimizes image memory footprints by specifying cache size constraints, avoiding device memory bloat from large source URLs.
*   **Keep-Screen-On (Wake Lock):** Integration options to prevent display timeouts while users are executing guided step instructions.
*   **Staggered Entrance Animations:** Implements clean, staggered item fades and slide-ins to make transitions feel organic.
*   **Robust CSV Importer:** Built a custom RFC-4180 state-machine parser to process nested newlines and commas within spreadsheet cells without alignment shifting.

---

## Folder Structure

```text
lib/
├── core/                       # App-wide routing, theme tokens, and global DI services
│   ├── router/                 # Central GoRouter configuration and route registries
│   └── services/               # Common abstractions (dialogs, snackbars, permissions)
├── modules/                    # Isolated feature domains
│   ├── authentication/         # Sign-in workflows and admin user session blocks
│   ├── dashboard/              # Metrics overview, recent updates, and user insights
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
