# 📐 System Blueprint — Tuwaiq App
**Version:** 1.4.1 | **Status:** Active | **Last Updated:** 2026-06-25

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
9. [Event Management Feature & Engineering Decisions](#9-event-management-feature--engineering-decisions)
10. [Content Sharing & Interaction Feature & Engineering Decisions](#10-content-sharing--interaction-feature--engineering-decisions)
11. [Password Recovery & Reset Flow & Engineering Decisions](#11-password-recovery--reset-flow--engineering-decisions)
12. [Change Log](#12-change-log)

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
    ├── events/                  # Event management feature module
    │   ├── data/
    │   │   ├── datasources/     # EventRemoteDataSource
    │   │   ├── models/          # EventModel
    │   │   └── repositories/    # EventRepositoryImpl
    │   ├── domain/
    │   │   ├── entities/        # EventEntity (Composite with UserProfile)
    │   │   ├── repositories/    # EventRepository interface
    │   │   └── usecases/        # CreateEventUseCase, GetEventUseCase, GetAllEventsUseCase
    │   └── presentation/
    │       ├── cubit/           # CreateEventCubit, EventDetailsCubit
    │       ├── screens/         # CreateEventScreen, EventDetailsScreen
    │       └── widgets/         # EventCardWidget (Reusable)
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
    ├── posts/                   # Content sharing & posts interaction feature
    │   ├── data/
    │   │   ├── datasources/     # PostRemoteDataSource
    │   │   ├── models/          # PostModel, CommentModel
    │   │   └── repositories/    # PostRepositoryImpl
    │   ├── domain/
    │   │   ├── entities/        # PostEntity, CommentEntity
    │   │   ├── repositories/    # PostRepository interface
    │   │   └── usecases/        # GetPostsFeedUseCase, CreatePostUseCase, ToggleLikeUseCase, etc.
    │   └── presentation/
    │       ├── cubits/          # CreatePostCubit, PostFeedCubit, PostCommentsCubit
    │       ├── screens/         # CreatePostScreen, PostDetailsScreen
    │       └── widgets/         # PostCard, CommentCard
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

#### `events`
Stores all user-created events.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | Unique event ID |
| `creator_id` | `uuid` | FK → `profiles.id` | Reference to the event creator profile |
| `title` | `text` | NOT NULL | Title of the event |
| `description` | `text` | NOT NULL | Multi-line description of the event |
| `cover_url` | `text` | NULLABLE | URL path to the cover image in storage |
| `category` | `text` | NOT NULL | Category name |
| `region` | `text` | NOT NULL | Saudi Arabia Region |
| `city` | `text` | NOT NULL | Saudi Arabia City |
| `location_name` | `text` | NOT NULL | Venue or location name |
| `google_maps_url` | `text` | NULLABLE | Google Maps location URL link |
| `start_date` | `timestamptz` | NOT NULL | Event start date and time |
| `end_date` | `timestamptz` | NOT NULL | Event end date and time |
| `status` | `text` | DEFAULT 'published' | Event publication status |
| `created_at` | `timestamptz` | DEFAULT now() | Event row creation timestamp |
| `updated_at` | `timestamptz` | DEFAULT now() | Event row last update timestamp |

**Relationship:** `events.creator_id` → `profiles.id` (Many-to-One, Foreign Key)

#### `posts`
Stores all user-created content (text and optional image).

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | Unique post ID |
| `creator_id` | `uuid` | FK → `profiles.id` | Reference to the post creator profile |
| `content` | `text` | CHECK (char_length(content) <= 2000), NOT NULL | Post body text |
| `image_url` | `text` | CHECK prefix, NULLABLE | Path to post image in storage |
| `created_at` | `timestamptz` | DEFAULT now() | Post row creation timestamp |
| `updated_at` | `timestamptz` | DEFAULT now() | Post row last update timestamp |

**Relationship:** `posts.creator_id` → `profiles.id` (Many-to-One, Foreign Key, `posts_creator_id_fkey`)

#### `post_likes`
Stores likes for posts (M:N relationship join table).

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `post_id` | `uuid` | PK, FK → `posts.id` ON DELETE CASCADE | Post referenced |
| `user_id` | `uuid` | PK, FK → `profiles.id` ON DELETE CASCADE | User who liked the post |
| `created_at` | `timestamptz` | DEFAULT now() | Timestamp when liked |

**Relationships:**
* `post_likes.post_id` → `posts.id` (Many-to-One, Foreign Key)
* `post_likes.user_id` → `profiles.id` (Many-to-One, Foreign Key)

#### `post_comments`
Stores flat comments on user posts.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | Unique comment ID |
| `post_id` | `uuid` | FK → `posts.id` ON DELETE CASCADE | Reference to the commented post |
| `creator_id` | `uuid` | FK → `profiles.id` ON DELETE CASCADE | Reference to the comment creator |
| `content` | `text` | CHECK (char_length(content) <= 500), NOT NULL | Comment body text |
| `created_at` | `timestamptz` | DEFAULT now() | Comment row creation timestamp |
| `updated_at` | `timestamptz` | DEFAULT now() | Comment row last update timestamp |

**Relationships:**
* `post_comments.post_id` → `posts.id` (Many-to-One, Foreign Key)
* `post_comments.creator_id` → `profiles.id` (Many-to-One, Foreign Key)

### 5.2 ERD — Complete Database Schema Scope (Sprint 2)

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
  - interests
    │
    ├─ 1:N ────────┐
    │              │
    ▼              ▼
events          posts
  - id (PK)       - id (PK)
  - creator_id    - creator_id (FK → profiles.id)
  - ...           - content (CHECK <= 2000)
                  - image_url
                  - created_at
                  - updated_at
                    │
                    ├─ 1:N ────────┐
                    │              │
                    ▼              ▼
                post_likes      post_comments
                  - post_id       - id (PK)
                  - user_id       - post_id (FK → posts.id)
                  - created_at    - creator_id (FK → profiles.id)
                                  - content (CHECK <= 500)
                                  - created_at
```

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

```sql
-- Enable RLS on events
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- SELECT: authenticated users can read all events
CREATE POLICY "authenticated users can read events"
ON events FOR SELECT
TO authenticated
USING (true);

-- INSERT: users can only create their own events
CREATE POLICY "users can insert own events"
ON events FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = creator_id);

-- UPDATE: users can only update their own events
CREATE POLICY "users can update own events"
ON events FOR UPDATE
TO authenticated
USING (auth.uid() = creator_id);

-- DELETE: users can only delete their own events
CREATE POLICY "users can delete own events"
ON events FOR DELETE
TO authenticated
USING (auth.uid() = creator_id);

-- Storage Policies for 'events' Bucket (storage.objects table)
-- SELECT: allow public read access
CREATE POLICY "Allow public read access to events"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'events'::text);

-- INSERT: allow authenticated users to upload covers
CREATE POLICY "Allow authenticated users to upload events"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'events'::text);

-- UPDATE: allow authenticated users to update covers
CREATE POLICY "Allow authenticated users to update their own events"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'events'::text);

-- -----------------------------------------------------
-- Posts & Interactions RLS Policies (Sprint 2)
-- -----------------------------------------------------

-- SELECT: authenticated users can read all posts
CREATE POLICY "Anyone can view posts" ON public.posts
    FOR SELECT TO authenticated USING (true);

-- INSERT: users can only create posts for themselves
CREATE POLICY "Users can create posts" ON public.posts
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = creator_id);

-- UPDATE: users can only edit their own posts
CREATE POLICY "Users can update own posts" ON public.posts
    FOR UPDATE TO authenticated 
    USING (auth.uid() = creator_id)
    WITH CHECK (auth.uid() = creator_id); -- Prevent creator_id spoofing

-- DELETE: users can only delete their own posts
CREATE POLICY "Users can delete own posts" ON public.posts
    FOR DELETE TO authenticated USING (auth.uid() = creator_id);

-- SELECT: authenticated users can read all likes
CREATE POLICY "Anyone can view likes" ON public.post_likes
    FOR SELECT TO authenticated USING (true);

-- INSERT: users can only like posts for themselves
CREATE POLICY "Users can toggle own likes" ON public.post_likes
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- DELETE: users can only remove their own likes
CREATE POLICY "Users can delete own likes" ON public.post_likes
    FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- SELECT: authenticated users can read all comments
CREATE POLICY "Anyone can view comments" ON public.post_comments
    FOR SELECT TO authenticated USING (true);

-- INSERT: users can only comment under their own identity
CREATE POLICY "Users can add comments" ON public.post_comments
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = creator_id);

-- DELETE: users can only delete their own comments
CREATE POLICY "Users can delete own comments" ON public.post_comments
    FOR DELETE TO authenticated USING (auth.uid() = creator_id);

-- Storage Policies for 'posts' Bucket (MIME-Type & size-limit config on Bucket level)
CREATE POLICY "Allow public read access to posts storage"
ON storage.objects FOR SELECT TO public USING (bucket_id = 'posts'::text);

CREATE POLICY "Allow authenticated users to upload posts images to own folder"
ON storage.objects FOR INSERT TO authenticated 
WITH CHECK (
    bucket_id = 'posts'::text AND 
    (storage.foldername(name))[1] = auth.uid()::text -- Path ownership verification
);

CREATE POLICY "Allow authenticated users to delete own posts images"
ON storage.objects FOR DELETE TO authenticated 
USING (
    bucket_id = 'posts'::text AND 
    owner = auth.uid()
);
```

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

### 6.4 Key Query Patterns
1. **Avoiding N+1 Queries (FK Joins):**
   When fetching events, the creator's profile information must be fetched in the same query using PostgREST foreign key joins:
   ```dart
   final response = await client
       .from('events')
       .select('*, profiles(*)')
       .order('start_date', ascending: true);
   ```
2. **Separated Storage & Database Upload Flow:**
   To handle errors gracefully, cover images are uploaded to storage first. The generated public URL is then supplied to the database insert statement. If the database insert fails, the image URL remains cached in the presentation state to avoid redundant uploads.

### 6.5 Localizations
The application uses `flutter_localizations` configured in `main.dart` with support for `ar` (Arabic) and `en` (English) locales, defaulting to `ar` (Arabic) to support standard RTL layout and system widgets (like pickers and calendar dialogs) natively.

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

## 9. Event Management Feature & Engineering Decisions
### 9.1 Feature Overview
The **Event Management** module (`features/events`) allows authenticated users to create, search, and view detailed information for events within Saudi Arabia. Key pages include:
- **`CreateEventScreen`**: A multi-step form to input event title, description, category, region, city, location name, Google Maps link, and date/time range, along with an optional cover image.
- **`EventDetailsScreen`**: A screen displaying full details about the event, its creator (user profile), timings, location, and description, including action buttons to navigate via Google Maps.
- **`EventCardWidget`**: A reusable card conforming to the "Light Industrial Tech" design style to display event previews across different features (e.g., Home, Explore).

### 9.2 Engineering Decisions
1. **N+1 Query Prevention (Composite Entities)**:
   Instead of fetching events and then executing a separate database query for each creator's profile (which causes a performance bottleneck), a composite `EventEntity` was designed to include a nested `UserProfile` object. The remote data source queries the database using PostgREST foreign key joins:
   ```dart
   final response = await client
       .from('events')
       .select('*, profiles(*)')
       .order('start_date', ascending: true);
   ```
   This ensures that all event and creator details are retrieved in a single network round-trip.

2. **Decoupled File Storage & Database Insertion**:
   In `CreateEventCubit`, the process of uploading the cover image to Supabase Storage and inserting the event metadata into the database are separated into two distinct stages:
   - **Image Upload**: The image is uploaded to the `events` storage bucket first. The returned public URL is cached within the cubit state.
   - **Metadata Database Insert**: The event metadata row (including the uploaded `cover_url`) is inserted into the `events` table.
   - **Error Recovery State-Caching**: If the database insertion fails (e.g., network timeout, database validation error), the uploaded image URL remains stored in the Cubit's state (`coverUrl` parameter). When the user clicks the save button again to retry, the cubit skips the image upload step and proceeds directly to the database insertion, saving bandwidth and preventing duplicate files in storage.

3. **Locale-Aware RTL Calendar Dialogs**:
   Operating in an Arabic context, native widgets like `showDatePicker` and `showTimePicker` crashed because the application was missing required locale configuration delegates. This was resolved by adding `flutter_localizations` from the Flutter SDK to `pubspec.yaml` and registering the delegates inside `MaterialApp.router` in `main.dart` with a default locale of `Locale('ar')`.

4. **Nested Shell Router Safety Checks**:
   Because `CreateEventScreen` resides on a persistent branch of a `StatefulShellRoute` (tab 2), calling a standard `Navigator.pop(context)` caused a black screen or navigation crash. The navigation flow was hardened to:
   ```dart
   if (Navigator.of(context).canPop()) {
     Navigator.of(context).pop();
   } else {
     context.go(AppRoutes.home);
   }
   ```
   This safely pops context-bound dialogs or sub-routes, while correctly resetting the active tab branch to the home route when attempting to pop the root page of the tab.

5. **Ancestor Widget Lookup Guarding (`mounted` checks)**:
   To prevent the animation exception `Looking up a deactivated widget's ancestor is unsafe`, safety guards were implemented in components that handle navigation or state checks after asynchronous calls (e.g., `PrimaryButton` and the screens' submit functions). We check `if (!mounted) return;` or `if (context.mounted)` before executing any context-dependent actions (like `Navigator.pop` or `context.read`).

6. **System Back Dispatcher Integration**:
   To resolve the Android log warning `OnBackInvokedCallback is not enabled for the application`, the app manifest `android/app/src/main/AndroidManifest.xml` was updated to enable the new back gesture API via `android:enableOnBackInvokedCallback="true"`.

---

## 10. Content Sharing & Interaction Feature & Engineering Decisions

### 10.1 Feature Overview
The **Content Sharing & Interaction** module (`features/posts`) allows users to write thoughts, upload images, like posts, and leave flat comment replies. Major user-facing elements:
* **`HomeScreen`**: Feed list presenting posts with user profile overlays, cover images, like hearts, and comment counts. Supports swipe-to-refresh.
* **`CreatePostScreen`**: A publishing screen with character count trackers (max 2000), media attachments via gallery, and upload loaders.
* **`PostDetailsScreen`**: Details viewer combining the single post with a chronological listing of flat comments, and a bottom text input bar.

### 10.2 Engineering Decisions
1. **PostgREST Relationship Disambiguation (fkey joins)**:
   When requesting profiles from posts (`posts -> profiles`), both `posts.creator_id` and the `post_likes` join table construct relationships to profiles. To prevent PostgREST ambiguity crash (PGRST201), the select syntax was explicitly configured to use the constraint identifier:
   `profiles:profiles!posts_creator_id_fkey(*)`
2. **Transaction Image Rollbacks & Leakage Prevention**:
   * **Insert Rollback**: If an image is successfully uploaded to the storage bucket but the metadata database row fails to save (e.g. constraints violation), the client triggers an automatic rollback call to delete the orphaned object from the `posts` bucket.
   * **Delete Rollback**: Deleting a post automatically triggers database cascading rules (for likes and comments), while the remote data source extracts the relative storage path from the deleted row's `image_url` and dispatches a storage deletion call to prevent storage leaks.
3. **Optimistic Likes with 500ms Throttle Debouncing**:
   To ensure smooth UX, liking a post updates UI elements and counts instantly in memory. To protect database resources from rapid double-tapping spam, a 500ms Timer maps requests. If a user toggles like status back-and-forth under 500ms, the previous timer cancels, sending zero requests if the state returns to default.
4. **OOM Memory Optimization (Cache constraints)**:
   Raw image rendering in list layouts leads to RAM exhaustion. The feed consumes `CachedNetworkImage` wrappers specifying strict `memCacheWidth: 400` and `memCacheHeight: 400` bounds to downscale large files in memory during rendering.
5. **Database-Level Data & Timestamp Security**:
   * Character constraints (`CHECK` constraints) limit input lengths (2000 for posts, 500 for comments) to prevent server-side buffer exhaustion.
   * Triggers (`set_created_at_protection`) enforce `created_at` values to `now()` on inserts and prevent modifications during updates, overriding client parameters.
   * RLS `WITH CHECK` clauses on update queries block ownership transfer attempts.
6. **Cursor-Based Pagination Consistency**:
   To prevent feed shifts (skipped or duplicated items) when new posts are created while browsing, queries utilize cursor pagination on `(created_at DESC, id DESC)` instead of offsets.
7. **Global State Provider Registration**:
   To prevent Routing scoping errors (`ProviderNotFoundException`) during pop redirects or cross-screen comment counts updating, `PostFeedCubit` is registered in `main.dart` at the global `MultiBlocProvider` level.

### 10.3 Stabilization & Refinement Fixes (Session Updates)
During the stabilization and testing phase of the Content Sharing & Interaction feature, several key issues were identified and resolved to ensure production readiness:
1. **PostgREST Relationship Ambiguity (PGRST201)**:
   - **Problem**: When fetching posts with profiles `posts.select('*, profiles(*)')`, Supabase returned a PostgREST error because both `posts.creator_id` and the `post_likes` table have relationships to the `profiles` table, making `profiles` ambiguous.
   - **Solution**: Updated the query in [post_remote_data_source.dart](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/features/posts/data/datasources/post_remote_data_source.dart) to explicitly use the foreign key constraint: `profiles:profiles!posts_creator_id_fkey(*)`.
2. **Comment Creation UUID Mismatch (22P02)**:
   - **Problem**: Adding a comment threw a Database Exception `invalid input syntax for type uuid: ""` because the client-side ID or user ID was not set, passing empty strings to the database instead of a valid UUID.
   - **Solution**: Updated [post_repository_impl.dart](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/features/posts/data/repositories/post_repository_impl.dart) to generate a new comment UUID on the fly using `Uuid().v4()` and retrieve the correct authenticated user ID directly from the active Supabase session.
3. **Double Spacing & Layout Keyboard Insets**:
   - **Problem**: In [post_details_screen.dart](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/features/posts/presentation/screens/post_details_screen.dart), opening the keyboard caused a massive empty space at the bottom because the view padding used `MediaQuery.of(context).viewInsets.bottom` while `resizeToAvoidBottomInset` was enabled, causing double padding.
   - **Solution**: Removed the manual view insets padding calculation and relied on Flutter's automatic keyboard resizing mechanism.
4. **Create Post UI Lifecycle and Flow UX**:
   - **Problem**: Upon successfully creating a post, the `CreatePostScreen` remained open, causing users to tap publish multiple times and create duplicate posts.
   - **Solution**: Registered custom listener triggers in [create_post_screen.dart](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/features/posts/presentation/screens/create_post_screen.dart) to pop the screen safely on success using `Navigator.of(context).pop()` (with fallback to `context.go(AppRoutes.home)`), returning the user to the refreshed feed.

---

## 11. Password Recovery & Reset Flow & Engineering Decisions

### 11.1 Feature Overview
The **Password Recovery / Reset** flow allows users who forgot their password to safely request a reset link to their email, open the link on Android or iOS, and securely update their password inside a dedicated screen in the application.

### 11.2 Engineering Decisions
1. **Custom URL Scheme vs. Universal Links**:
   Due to Supabase's default API domain restrictions (`zrgtnzmvqtdvaragqgoj.supabase.co`), hosting standard `.well-known/assetlinks.json` or `.well-known/apple-app-site-association` verification files is not feasible. The architecture was pivoted to utilize a Custom URL Scheme: `cratch://reset-callback`.
2. **PKCE Code Exchange Race Condition Resolution**:
   When the deep link is clicked, GoRouter parses the URL concurrently with Supabase's asynchronous PKCE authentication code exchange. To prevent a race condition where the screen loads before the session is established (throwing false *Verification session expired* errors):
   - A fallback loading screen is registered under the route path `/reset-callback`.
   - The manual deep-link stream parser ignores the recovery URLs to prevent premature data querying.
   - `AuthCubit` monitors `Supabase.instance.client.auth.onAuthStateChange` natively. 
   - Once the PKCE code exchange successfully completes in the background, Supabase triggers the `AuthChangeEvent.passwordRecovery` event.
   - `AuthCubit` transitions to the `AuthPasswordRecovery` state.
   - GoRouter (subscribing to the cubit stream) intercepts the state change and redirects the user to the `UpdatePasswordScreen`.
3. **Redirect Loop Prevention & Session Lifecycle Management**:
   The router prevents users with an active `AuthPasswordRecovery` state from being redirected to `/home` before submitting their password. However, to prevent users from being trapped on the reset screen indefinitely, both back arrow navigation and password update success trigger `AuthCubit.signOut()`. This terminates the recovery session, resets the cubit state back to `AuthInitial`, and allows clean routing to `/sign-in`.
4. **Dedicated Update Password Cubit**:
   To comply with Clean Architecture and separation of concerns, a dedicated `UpdatePasswordCubit` is introduced with states representing the transaction lifecycle: `UpdatePasswordInitial`, `UpdatePasswordLoading`, `UpdatePasswordSuccess`, and `UpdatePasswordError`. This cubit invokes the pure Dart `UpdatePasswordUseCase` to securely dispatch password updates to Supabase's authentication client.
5. **Auth Feature Routing Migration**:
   We migrated all authentication flow screens (`SignInScreen`, `SignUpScreen`, `ForgotPasswordScreen`, `EmailConfirmationScreen`, `InterestsScreen`, `UpdatePasswordScreen`) to use standard GoRouter routing APIs (`context.go`, `context.push`, `context.pop`, `context.pushReplacement`) instead of the legacy `Navigator` class, establishing a consistent routing standard across the entire module.

---

## 12. Change Log

| `1.5.0` | 2026-06-28 | Mahmoud Desouky | Implemented Password Recovery / Reset Flow. Built dedicated `UpdatePasswordCubit` and states. Reconfigured deep linking from HTTPS App/Universal links to Custom URL Scheme (`cratch://reset-callback`) for compatibility. Resolved PKCE code exchange race condition by handling `onAuthStateChange` natively inside `AuthCubit` and rendering a fallback loading screen at `/reset-callback`. Prevented infinite redirection loop by calling `signOut()` on back navigation and password update success. Migrated all Auth screens to GoRouter. |
| `1.4.1` | 2026-06-26 | Mahmoud Desouky | Stabilization and bug fixes for Content Sharing feature: resolved PostgREST PGRST201 ambiguous relationship error by specifying fkey constraint; resolved comment insertion UUID mismatch; fixed double-padding UI keyboard issue; fixed Bloc scoping crash by registering PostFeedCubit globally; fixed CreatePostScreen navigation pop on success. |
| `1.4.0` | 2026-06-25 | Mahmoud Desouky | Implemented Content Sharing & Posts Interaction feature (`features/posts`). Created SQL schema for `posts`, `post_likes`, and `post_comments` with triggers protecting timestamps and check constraints limiting length/MIME sizes. Designed image rollbacks on DB failures, leak cleanups on delete, optimistic debounced liking, memory-capped cached network image loaders, global state provider management, and cursor pagination. |
| `1.3.0` | 2026-06-20 | Mahmoud Desouky | Implemented Event Management Feature (`features/events`). Designed database schema, storage bucket, and RLS policies for `events`. Created composite `EventEntity` (embedding `UserProfile`) to resolve creator profile data in a single request. Developed `CreateEventCubit` with strictly defined states (Initial, UploadingImage, SavingData, Success, Error) separating storage upload from database insert. Added `CreateEventScreen` and `EventDetailsScreen` with Arabic RTL localizations support (`flutter_localizations`), form validation, maps redirection, and `mounted` guards for transitions. |
| `1.2.0` | 2026-06-19 | Mahmoud Desouky | Migrated application routing to `go_router` with declarative routing and nested branch navigation (`StatefulShellRoute`). Moved `HomeScreen` to `features/home` and created main navigation bar shell (`MainScreen`). Created stub features (`explore`, `create_content`, `alerts`) and set up centralized redirection gates for authentication status and user interests checklist. |
| `1.1.0` | 2026-05-31 | Mahmoud Desouky | Implemented Auth & Onboarding feature. Added `interests` text[] to `profiles`, RLS security triggers, deep linking, bloc/Cubit state management, and 6 premium RTL UI screens. |
| `1.0.0` | 2026-05-20 | Mahmoud Desouky | Initial Blueprint — Tech Stack, User Roles, DB Core (profiles), Clean Architecture, Theming System |

---

*This document is the Single Source of Truth for all engineering decisions on the Tuwaiq project. All future architectural decisions must be reflected here before implementation.*
