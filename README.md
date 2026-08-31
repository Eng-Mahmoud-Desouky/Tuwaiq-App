# Tuwaiq App

## Project Overview
Tuwaiq App is a scalable, enterprise-grade mobile application built to provide exceptional user experiences and robust functionality. Designed with future growth in mind, it leverages a modernized technology stack to deliver high performance, seamless connectivity, and maintainability. This application is engineered to solve complex business challenges through an intuitive interface and reliable backend infrastructure.

## Tech Stack
- **Frontend Framework:** Flutter & Dart (SDK ^3.10.8)
- **State Management:** BLoC (`flutter_bloc`) for predictable, scalable, and testable state handling.
- **Backend & Database:** Supabase (`supabase_flutter`) for authentication, database, and real-time capabilities.
- **Cloud Services:** Firebase (Core & Messaging) for reliable push notifications.
- **Routing:** GoRouter for declarative, deep-link ready navigation.
- **Caching & Media:** `flutter_cache_manager` and `cached_network_image` for optimized media delivery.

## Architecture: Clean Architecture
This project strictly adheres to **Clean Architecture** principles, organized in a feature-first directory structure (e.g., `lib/features/auth`). This approach ensures maximum scalability, zero technical debt, and extreme maintainability by decoupling the core logic from external frameworks.

Each feature encapsulates three distinct layers:
- **Presentation Layer:** Contains UI components (Pages, Widgets) and State Management (BLoCs/Cubits). It handles user interactions and renders states without coupling to business logic.
- **Domain Layer:** The core of the application. It houses Entities, Repository Interfaces, and Use Cases. This layer is completely independent of external dependencies, ensuring business rules remain pure.
- **Data Layer:** Responsible for external data interactions. It includes Models (DTOs), Data Sources (Remote APIs/Local DBs), and Repository implementations.

This strict separation of concerns guarantees that UI changes do not affect business logic, and backend integrations can be modified or swapped without impacting the core application.

## Key Features
- **Secure Authentication:** Robust user identity management and role-based access via Supabase.
- **Real-time Data Sync:** Seamless, real-time synchronization with the Supabase backend.
- **Push Notifications:** Integrated Firebase Messaging to keep users engaged and informed.
- **Deep Linking:** Configured URL handling for direct in-app navigation and sharing.
- **Optimized Media Handling:** Efficient image and video loading with advanced caching mechanisms.

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.10.8 or higher)
- Dart SDK
- IDE (VS Code or Android Studio)

### Installation
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tuwaiq_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   Copy `.env.example` to `.env` and provide the required API keys (e.g., Supabase URL and Anon Key):
   ```bash
   cp .env.example .env
   ```

4. **Run the App**
   ```bash
   flutter run
   ```
