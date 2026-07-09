<img width="1536" height="1024" alt="ChatGPT Image Jul 9, 2026, 02_51_26 PM" src="https://github.com/user-attachments/assets/68b27df3-dac4-4a01-93ea-1a959a0e56bd" />

# 🧑‍🍳 Recipely Studio

### Modern Flutter Admin Panel for Recipe Management

Recipely Studio is a **Flutter-powered administration platform** built to manage the complete Recipely ecosystem. It enables administrators to create recipes, organize categories and tags, manage media assets, curate featured content, monitor analytics, and publish content through a clean, responsive dashboard.

> **Flutter • Clean Architecture • BLoC • Supabase • PostgreSQL**

---

# ✨ Highlights

- 🏗 Feature-First Clean Architecture
- 🧩 BLoC State Management
- ☁️ Supabase Backend & Storage
- 📊 Analytics Dashboard
- 📂 Media Library
- ⭐ Featured & Trending Management
- 🏷 Categories & Tags
- 📱 Responsive Desktop UI

---

# 🚀 Features

## 📖 Recipe Management

- Create, edit, publish, and delete recipes
- Multi-step recipe creation wizard
- Ingredient and instruction management
- Difficulty, cuisine, nutrition, and metadata support
- CSV recipe import & export

---

## 🏷 Category & Tag Management

- Create and organize recipe categories
- Manage cuisines, dietary tags, meal types, and ingredients
- Dynamic filtering and searching
- Responsive card-based layouts

---

## ⭐ Content Curation

- Manage Featured recipes
- Control Trending recipes
- Configure homepage content
- Organize recipe visibility

---

## 🖼 Media Library

- Upload images directly to Supabase Storage
- Copy public URLs
- Delete unused assets
- Search uploaded media
- Image preview support

---

## 📊 Dashboard & Analytics

- Recipe statistics
- Category overview
- User metrics
- Interactive charts
- Content performance dashboard

---

## ⚡ Performance

- Optimized widget rebuilds
- Cached network images
- Fast table rendering
- Responsive layouts
- Smooth animations
- Efficient filtering & searching

---

# 🛠 Technology Stack

| Category | Technology |
|-----------|------------|
| **Framework** | Flutter & Dart |
| **Architecture** | Feature-First Clean Architecture |
| **State Management** | flutter_bloc |
| **Backend** | Supabase |
| **Database** | PostgreSQL |
| **Storage** | Supabase Storage |
| **Routing** | GoRouter |
| **Charts** | fl_chart |
| **Dependency Injection** | get_it |
| **Image Loading** | CachedNetworkImage |
| **Utilities** | CSV Import/Export |

---

# 📸 Screenshots

| Dashboard | Recipes | Featured |
|-----------|----------|-----------|
| Screenshot | Screenshot | Screenshot |

| Trending | Categories | Analytics |
|-----------|------------|-----------|
| Screenshot | Screenshot | Screenshot |

---

# 🏗 Architecture

Recipely Studio follows a **Feature-First Clean Architecture**, separating the application into **Presentation**, **Domain**, and **Data** layers.

Business logic is managed using **BLoC**, while repositories abstract communication with Supabase. Dependency Injection is handled through **GetIt**, allowing every feature to remain modular, testable, and independently scalable.

---

# ⚙ Engineering Highlights

- Feature-first modular architecture
- Clean Architecture implementation
- Repository Pattern
- BLoC & Cubit state management
- GoRouter navigation
- Dependency Injection with GetIt
- Supabase Authentication & Database
- Supabase Storage integration
- Custom CSV parser for recipe import
- Responsive admin dashboard
- Interactive analytics using FL Chart
- Cached image optimization

---

# 📂 Project Structure

```text
lib/
├── core/
│   ├── router/
│   ├── services/
│   ├── theme/
│   └── utils/
│
├── modules/
│   ├── authentication/
│   ├── dashboard/
│   ├── recipes/
│   ├── featured/
│   ├── trending/
│   ├── categories/
│   ├── tags/
│   ├── media/
│   ├── analytics/
│   └── settings/
│
├── shared/
│   ├── widgets/
│   ├── models/
│   ├── repositories/
│   └── services/
│
└── main.dart
```

---

# 🚀 Getting Started

## Prerequisites

- Flutter SDK (Latest Stable)
- Dart SDK
- Supabase Project

---

## Installation

Clone the repository

```bash
git clone https://github.com/yourusername/recipely-studio.git
```

Install dependencies

```bash
flutter pub get
```

Generate code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Configure your Supabase credentials.

Run the project

```bash
flutter run
```

---

# 💡 Key Engineering Decisions

- Feature-first folder organization
- Repository Pattern for data abstraction
- Scalable BLoC architecture
- Responsive desktop-first layouts
- Modular reusable widgets
- Optimized image loading
- Clean separation of concerns

---



## ⭐ Support

If you found this project useful, consider giving it a **⭐**.

Contributions, feedback, and suggestions are always welcome.
