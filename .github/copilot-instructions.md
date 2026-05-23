# AI Coding Agent Instructions for Food Scan AI

## Project Overview

Food Scan AI is a nutrition analysis platform with a **Flutter mobile app** (`flutter-app/`) and **Spring Boot backend** (`spring-backend/`). The app scans food product labels and meals using device cameras, leverages Google Cloud Vertex AI (Gemini 2.0 Flash) for intelligent analysis, and tracks daily nutritional intake. Firebase handles authentication, PostgreSQL stores persistent data, and both components communicate via REST APIs.

## Architecture & Key Patterns

### Flutter App Structure (MVVM Pattern)

- **`lib/viewmodels/`**: All ViewModels extend `BaseViewModel` (ChangeNotifier) for state management via Provider
  - Pattern: `ProductAnalysisViewModel`, `MealAnalysisViewModel`, `DailyIntakeViewModel`, etc.
  - Injected with repositories in [main.dart](flutter-app/lib/main.dart) using `ChangeNotifierProvider` and `ChangeNotifierProxyProvider`

- **`lib/repositories/`**: Repository pattern with interfaces
  - All data access abstracted behind interfaces (e.g., `AiRepositoryInterface`, `UserRepositoryInterface`)
  - Implementations: `SpringBackendRepository` for AI analysis, `IntakeRepository`, `UserRepository`
  - `ApiClient` handles HTTP requests with Firebase auth tokens

- **`lib/views/screens/`** and **`lib/views/widgets/`**: UI layer consumes ViewModels using `Consumer<ViewModel>`

- **State Management**: Provider exclusively - all providers registered in [main.dart](flutter-app/lib/main.dart) `_registerProviders()`

### Spring Boot Backend Structure

- **`controllers/`**: REST endpoints return `ApiResponse<T>` wrapper with `status`, `message`, `data` fields
  - Pattern: `@PostMapping` endpoints accept `MultipartFile` for image uploads
  - Example: [AiAnalysisController.java](spring-backend/src/main/java/com/scanmyfood/backend/controllers/AiAnalysisController.java) `/api/ai/analyze/product` and `/api/ai/analyze/image`

- **`services/`**: Business logic layer with interface-implementation pattern
  - `VertexAiServiceImpl` implements `AiService`, uses Google Cloud Vertex AI SDK
  - `AiResponseProcessingService` transforms raw AI JSON responses into typed POJOs

- **`models/`**: JPA entities (User, DailyIntake, ScanHistory) with Lombok annotations
  - Use `@Entity`, `@Table`, `@OneToOne`, `@ManyToOne` relationships
  - All entities have `createdAt`/`updatedAt` with `@PrePersist`/`@PreUpdate`
  - Firebase UID is used as user identifier (`firebaseUid` field)

- **`mapper/`**: MyBatis mappers for complex queries
  - Pattern: `@Mapper` interfaces with XML definitions in [src/main/resources/mapper/](spring-backend/src/main/resources/mapper/)
  - Example: [UserIntakeMapper.java](spring-backend/src/main/java/com/scanmyfood/backend/mapper/UserIntakeMapper.java) for daily intake aggregations

- **`configurations/`**: Spring beans for Firebase, Vertex AI, CORS
  - [VertexAIConfig.java](spring-backend/src/main/java/com/scanmyfood/backend/configurations/VertexAIConfig.java) initializes Google Cloud clients

### API Communication Pattern

1. Flutter calls `SpringBackendRepository` methods (e.g., `analyzeProductImages()`)
2. Multipart requests sent to backend `/api/ai/*` endpoints with auth tokens
3. Backend delegates to `VertexAiServiceImpl` → calls Gemini model
4. Response processed by `AiResponseProcessingService` → returns `ApiResponse<ProductAnalysisResponse>`
5. Flutter deserializes JSON using model `fromJson()` factories

### Data Models Synchronization

Keep Flutter and Spring models in sync:
- Flutter: [lib/models/](flutter-app/lib/models/) (Dart classes with `fromJson`/`toJson`)
- Spring: [src/main/java/.../models/](spring-backend/src/main/java/com/scanmyfood/backend/models/) (POJOs with Lombok)
- JSON uses **snake_case** (enforced by `PropertyNamingStrategies.SnakeCaseStrategy` in Spring)

## Critical Configuration Files

- **Backend**: [application.properties](spring-backend/src/main/resources/application.properties)
  - PostgreSQL: `spring.datasource.url=jdbc:postgresql://localhost:5432/scanmyfood`
  - Google Cloud: `google.cloud.project-id`, `google.cloud.location`
  - Storage: `storage.type=local` (or `s3`/`gcs` for production)
  - Service account key: `firebase-service-account.json` in `src/main/resources/`

- **Flutter**: [pubspec.yaml](flutter-app/pubspec.yaml) and `.env` file
  - `.env` contains `API_BASE_URL=http://localhost:8080/api` (default if not set)
  - Firebase config in [firebase_options.dart](flutter-app/lib/firebase_options.dart)

## Development Workflows

### Running the App

**Backend**:
```bash
cd spring-backend
./mvnw spring-boot:run  # or mvn spring-boot:run
```
Server runs on port 8080. Ensure PostgreSQL is running and database `scanmyfood` exists.

**Flutter**:
```bash
cd flutter-app
flutter pub get
flutter run
```

### Testing & Debugging

- **Flutter**: Use [AppLogger](flutter-app/lib/utils/app_logger.dart) singleton for structured logging
  - Pattern: `final logger = AppLogger(); logger.i("message")` or `logger.e("error")`
  - Avoid `print()` statements - use logger methods (`.i()`, `.d()`, `.e()`)

- **Backend**: SLF4J with Lombok's `@Slf4j` annotation
  - Pattern: `log.info("message")`, `log.error("error", exception)`

### Adding New Features

**New API Endpoint**:
1. Create controller method in `controllers/` returning `ApiResponse<T>`
2. Implement service logic in `services/` with interface
3. Add Flutter repository method in corresponding interface/implementation
4. Update ViewModel to call repository method
5. Sync models if response structure changes

**New UI Screen**:
1. Create screen in `lib/views/screens/` extending `StatelessWidget` or `StatefulWidget`
2. Create ViewModel extending `BaseViewModel` in `lib/viewmodels/`
3. Register ViewModel as `ChangeNotifierProvider` in [main.dart](flutter-app/lib/main.dart)
4. Add route to `MaterialApp.routes` in main.dart
5. Use `Consumer<YourViewModel>` or `context.watch<YourViewModel>()` in UI

## Project-Specific Conventions

- **Flutter Models**: Always implement `fromJson()` and `toJson()` for API serialization
- **Spring Controllers**: Use `@Slf4j` and log entry/exit of all endpoints
- **Error Handling**: ViewModels have `setError(String?)` from BaseViewModel - use for user-facing errors
- **Image Upload**: Backend endpoints use `@RequestParam MultipartFile` for images
- **Authentication**: All API calls include Firebase auth token via `ApiClient.getAuthToken()`
- **Nutrient Analysis**: Centralized in [NutrientConstants.java](spring-backend/src/main/java/com/scanmyfood/backend/constants/NutrientConstants.java) for DV% calculations

## Common Gotchas

1. **Snake_case JSON**: Spring is configured for snake_case serialization - ensure Flutter models match (e.g., `meal_name` not `mealName`)
2. **MyBatis Mappers**: Complex queries go in MyBatis XML, simple CRUD uses JPA repositories
3. **Provider Dependencies**: ViewModels depending on other ViewModels need `ChangeNotifierProxyProvider` in main.dart
4. **Vertex AI Prompts**: AI prompts are hardcoded in [VertexAiServiceImpl.java](spring-backend/src/main/java/com/scanmyfood/backend/services/VertexAiServiceImpl.java) - modify there for analysis changes
5. **Firebase UID**: Always use Firebase UID as primary user identifier, not database auto-incremented IDs

## Key Dependencies

**Flutter**: `provider` (state), `firebase_auth`, `http`, `image_picker`, `logger`, `fl_chart`, `rive`

**Spring Boot**: `spring-boot-starter-data-jpa`, `google-cloud-vertexai`, `firebase-admin`, `mybatis-spring-boot-starter`, `postgresql`

## References

- Full setup: [README.md](README.md)
- Contributing guidelines: [flutter-app/CONTRIBUTING.md](flutter-app/CONTRIBUTING.md)
- Example ViewModel: [ProductAnalysisViewModel](flutter-app/lib/viewmodels/product_analysis_view_model.dart)
- Example Controller: [AiAnalysisController](spring-backend/src/main/java/com/scanmyfood/backend/controllers/AiAnalysisController.java)
