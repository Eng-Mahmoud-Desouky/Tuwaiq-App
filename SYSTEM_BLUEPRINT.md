# 📐 System Blueprint — Tuwaiq App
**Version:** 1.0.0 | **Status:** Active | **Last Updated:** 2026-05-20

---

## 📋 Table of Contents
1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [User Roles](#3-user-roles)
4. [Project Architecture](#4-project-architecture)
5. [Database Design](#5-database-design)
6. [Flutter ↔ Supabase Connection](#6-flutter--supabase-connection)
7. [Theming System](#7-theming-system)
8. [Core & Shared Structure](#8-core--shared-structure)
9. [Change Log](#9-change-log)

---

## 1. Project Overview

**Tuwaiq** is a social and events mobile application targeting the Saudi Arabian market. The platform allows users to discover, create, and interact with local events, follow other users, and engage with community-driven content.

**Core Goals:**
- Stable, secure, and performant system from day one.
- Clean architecture that scales without rewrites.
- Fast delivery to market without accumulating technical debt.

**Current Phase:** MVP — Sprint 1

---

## 2. Tech Stack

| Layer | Technology | Justification |
| :--- | :--- | :--- |
| **Mobile** | Flutter | Cross-platform (iOS + Android), single codebase, familiar stack |
| **Backend / BaaS** | Supabase | PostgreSQL foundation, built-in Auth & RLS, clean exit strategy to custom backend if needed |
| **Database** | PostgreSQL (via Supabase) | Relational structure, SQL familiarity, strong ecosystem |
| **State Management** | flutter_bloc (Cubit) | Selected for reactive flow and strict state representation |
| **Routing** | GoRouter | Declarative routing, deep linking support, and nested shell routes (`StatefulShellRoute`) for persistent bottom navigation |
| **Version Control** | Git / GitHub | Industry standard, supports CI/CD pipelines |

> **Exit Strategy Note:** Supabase is built on top of standard PostgreSQL. If scaling requirements demand a custom backend in the future, migration is straightforward — no vendor lock-in on the data layer.

---

## 3. User Roles

The MVP operates with two roles only. No guest or admin roles in this phase.

| Role | Description | Access |
| :--- | :--- | :--- |
| `anon` | Unauthenticated state (before login) | No access to app features |
| `authenticated` | Logged-in user | Full access to all MVP features |

> **Note on `anon` key:** The Flutter app always uses the Supabase `anon` key to connect to the API. This is not a user role — it's a connection credential. The actual user role is determined by the JWT token after login.

**Guest Mode:** Deferred post-MVP.

---

## 4. Project Architecture

### 4.1 Clean Architecture — 3 Layers

```
┌─────────────────────────────┐
│      Presentation Layer      │  UI, Screens, Widgets, State Management
├─────────────────────────────┤
│        Domain Layer          │  Use Cases, Entities, Repository Interfaces
├─────────────────────────────┤
│         Data Layer           │  Repository Implementations, Remote, Local
└─────────────────────────────┘
```

**Dependency Rule:** Dependencies flow inward only.
`Presentation → Domain ← Data`

The Domain layer has **zero knowledge** of Flutter, Supabase, or any external framework. It is pure Dart.

### 4.2 Folder Structure

```
lib/
├── core/                        # Shared utilities, constants, errors
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── router/                  # Centralized app routing (GoRouter)
│   │   └── app_router.dart
│   └── utils/
├── shared/                      # Reusable widgets, theming, extensions
│   ├── theme/
│   ├── widgets/
│   └── extensions/
└── features/                    # One folder per feature
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── screens/
    │       ├── widgets/
    │       └── bloc/ (or cubit/)
    ├── main/                    # Persistent bottom navigation shell
    │   └── presentation/
    │       └── screens/
    │           └── main_screen.dart
    ├── home/                    # Home page feature (Presentation only)
    │   └── presentation/
    │       └── screens/
    │           └── home_screen.dart
    ├── explore/                 # Explore page stub
    │   └── presentation/
    │       └── screens/
    │           └── explore_screen.dart
    ├── create_content/          # Content creation stub
    │   └── presentation/
    │       └── screens/
    │           └── create_content_screen.dart
    ├── alerts/                  # Notifications & Alerts stub
    │   └── presentation/
    │       └── screens/
    │           └── alerts_screen.dart
    └── profile/                 # Profile management and social connections
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/
            ├── screens/
            ├── widgets/
            └── cubit/
```

### 4.3 Routing & Navigation (GoRouter)

The application uses **GoRouter** for declarative routing, nested navigation, and authentication-based redirection.

- **Centralized Router:** Defined in [app_router.dart](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/core/router/app_router.dart).
- **Stateful Bottom Navigation:** Implemented using `StatefulShellRoute.indexedStack`. This allows each navigation branch (Home, Explore, Create Content, Alerts, Profile) to maintain its own navigation stack and state when switching between tabs.
- **Auth Guard & Redirection:** The router is configured with a `redirect` handler that listens to the `AuthCubit` stream (via `AppRouterRefreshStream`). It dynamically redirects users:
  - If unauthenticated: redirects to the Sign-In screen.
  - If authenticated but has selected fewer than 3 interests: redirects to the Interests Selection screen.
  - If authenticated with complete interests and attempts to access authentication screens (like Sign-In/Sign-Up): redirects to the Home screen.
- **Manual Dependency Injection:** Since there is no service locator (like `GetIt`) in Sprint 1, dependency injection is performed manually in `main.dart` and the required use cases are passed down to `AppRouter.router()`.

---

## 5. Database Design

### 5.1 Core Tables (Sprint 1)

#### `auth.users` *(Managed by Supabase)*
Handles all authentication credentials — email, password hash, email confirmation status. **Do not modify directly.**

#### `profiles`
Stores all additional user data beyond authentication.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK, FK → `auth.users.id` | Matches Supabase auth user ID |
| `username` | `text` | UNIQUE, NOT NULL | Public display name |
| `full_name` | `text` | NULLABLE | Optional full name |
| `avatar_url` | `text` | NULLABLE | Profile picture URL |
| `bio` | `text` | NULLABLE | Short user biography |
| `created_at` | `timestamptz` | DEFAULT now() | Account creation timestamp |
| `updated_at` | `timestamptz` | DEFAULT now() | Last profile update |
| `interests` | `text[]` | NULLABLE | User-selected event and cultural interests |

**Relationship:** `profiles.id` → `auth.users.id` (1-to-1, Foreign Key)

### 5.2 ERD — Sprint 1 Scope

```
auth.users (Supabase Managed)
    │
    │ 1:1
    ▼
profiles
  - id (FK → auth.users.id)
  - username
  - full_name
  - avatar_url
  - bio
  - created_at
  - updated_at
```

> **Note:** Full ERD including `events`, `posts`, `follows`, `notifications` will be added incrementally before each feature sprint.

### 5.3 RLS Policies — Sprint 1

```sql
-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- SELECT: users can only read their own profile
CREATE POLICY "users can read own profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- INSERT: users can only create their own profile
CREATE POLICY "users can insert own profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- UPDATE: users can only update their own profile
CREATE POLICY "users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id);
```

> **Note:** Public profile READ policy (for viewing other users' profiles) will be added in the Profile feature sprint.

---

## 6. Flutter ↔ Supabase Connection

**Library:** [`supabase_flutter`](https://pub.dev/packages/supabase_flutter)

### 6.1 Initialization

```dart
// main.dart
await Supabase.initialize(
  url: Env.supabaseUrl,       // From environment variables — never hardcode
  anonKey: Env.supabaseAnonKey,
);
```

> **Security Rule:** Supabase URL and Anon Key must be stored in environment variables or a `.env` file. Never commit secrets to Git.

### 6.2 Accessing the Client

```dart
final supabase = Supabase.instance.client;
```

### 6.3 Data Flow

```
Flutter UI (Presentation)
    ↓ triggers
Use Case (Domain)
    ↓ calls
Repository Interface (Domain)
    ↓ implemented by
Repository Impl (Data)
    ↓ calls
Supabase Datasource (Data/Remote)
    ↓ HTTP / Realtime
Supabase Backend
```

---

## 7. Theming System

### 7.1 Decisions

- **Mode:** Light Mode only. Dark Mode deferred post-MVP.
- **Approach:** Centralized `AppTheme` class — no hardcoded colors or styles in widgets.

### 7.2 Structure

```dart
// lib/shared/theme/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    colorScheme: AppColors.lightColorScheme,
    textTheme: AppTextStyles.textTheme,
    // ...
  );
}

// lib/shared/theme/app_colors.dart
class AppColors {
  static const primary = Color(0xFF...);
  static const secondary = Color(0xFF...);
  // ...
}

// lib/shared/theme/app_text_styles.dart
class AppTextStyles {
  // Font sizes, weights, families
}
```

> **Note:** Actual color values and typography to be finalized during UI Design sprint (Sprint 1).

---

## 8. Core & Shared Structure

### 8.1 `core/` — System-Wide Utilities

| Folder | Responsibility |
| :--- | :--- |
| `core/constants/` | App-wide constants (routes, keys, timeouts) |
| `core/errors/` | Failure classes, Exception handling |
| `core/network/` | Network info, connectivity checks |
| `core/router/` | Centralized router setup ([app_router.dart](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/core/router/app_router.dart)) using GoRouter and navigation state management |
| `core/utils/` | Pure utility functions (formatters, validators) |

### 8.2 `shared/` — Reusable UI Components

| Folder | Responsibility |
| :--- | :--- |
| `shared/theme/` | AppTheme, AppColors, AppTextStyles |
| `shared/widgets/` | Reusable widgets (buttons, inputs, loaders) |
| `shared/extensions/` | Dart extensions (String, DateTime, etc.) |

**Rule:** `core/` has zero Flutter dependency where possible. `shared/` is Flutter-only.

---

## 9. Change Log

| Version | Date | Author | Changes |
| :--- | :--- | :--- | :--- |
| `1.2.0` | 2026-06-19 | Antigravity AI | Migrated application routing to `go_router` with declarative routing and nested branch navigation (`StatefulShellRoute`). Moved `HomeScreen` to `features/home` and created main navigation bar shell (`MainScreen`). Created stub features (`explore`, `create_content`, `alerts`) and set up centralized redirection gates for authentication status and user interests checklist. |
| `1.1.0` | 2026-05-31 | Mahmoud Desouky | Implemented Auth & Onboarding feature. Added `interests` text[] to `profiles`, RLS security triggers, deep linking, bloc/Cubit state management, and 6 premium RTL UI screens. |
| `1.0.0` | 2026-05-20 | Mahmoud Desouky | Initial Blueprint — Tech Stack, User Roles, DB Core (profiles), Clean Architecture, Theming System |

---

*This document is the Single Source of Truth for all engineering decisions on the Tuwaiq project. All future architectural decisions must be reflected here before implementation.*
