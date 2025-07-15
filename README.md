# Food Scan AI

A comprehensive nutrition analysis platform that helps users track their nutritional intake by analyzing food product labels and meals using AI. Built with a Flutter frontend and Spring Boot backend, leveraging Google Cloud's Vertex AI for intelligent food analysis.

## Features

- 📸 Scan product labels and food items using your device's camera
- 🔍 AI-powered nutrition analysis using Google Cloud Vertex AI
- 📊 Track daily nutrient intake with detailed breakdowns
- 📅 View historical food consumption data
- 📈 Visual representations of macronutrient distribution
- 👤 User profiles with personalized dietary preferences and health metrics
- ⚡ Real-time nutritional insights and recommendations
- 🔐 Secure Firebase authentication integration
- 🌐 Cross-platform support with synchronized data

## Screenshots

https://github.com/user-attachments/assets/82553c7d-5d61-4d22-9d99-2c2e15fa215b

| <img src="https://github.com/user-attachments/assets/a0a85d4f-26b6-44ea-a4f4-46f80bae9907" width="300" alt="Screenshot 1" /> | <img src="https://github.com/user-attachments/assets/a76ef71a-ce2f-402e-863d-baa435ddb938" width="300" alt="Screenshot 2" /> | <img src="https://github.com/user-attachments/assets/2b758598-71ae-4d8b-9406-73b2b52a8019" width="300" alt="Screenshot 3" /> |
|:---------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------:|
| <img src="https://github.com/user-attachments/assets/be941868-2eb8-4785-8a9e-d0d91bce66b3" width="300" alt="Screenshot 4" /> | <img src="https://github.com/user-attachments/assets/c0067fb8-136b-400e-b97e-f3e2c1a44c40" width="300" alt="Screenshot 5" /> | <img src="https://github.com/user-attachments/assets/a2387fc5-d440-4c82-9b79-da18c1723247" width="300" alt="Screenshot 6" /> |

## Architecture

Food Scan AI follows a modern, scalable architecture:

- **Frontend**: Flutter mobile app with MVVM architecture
- **Backend**: Spring Boot RESTful API service
- **Database**: PostgreSQL for persistent storage
- **Authentication**: Firebase Authentication
- **AI Analysis**: Google Cloud Vertex AI (Gemini 2.0 Flash)
- **Cloud Infrastructure**: Google Cloud Platform

### Project Structure

```
/
├── flutter-app/              # Flutter frontend application
│   ├── lib/
│   │   ├── core/             # App-wide constants
│   │   ├── config/           # Environment configuration
│   │   ├── models/           # Data models
│   │   ├── repositories/     # Data access layer with interfaces
│   │   ├── services/         # Business logic services
│   │   ├── theme/            # App theme definitions  
│   │   ├── viewmodels/       # ViewModels for business logic
│   │   ├── views/            # UI components
│   │   │   ├── screens/      # Full page views
│   │   │   └── widgets/      # Reusable UI components
│   │   └── main.dart         # Application entry point
│   └── assets/               # App resources (images, fonts, etc.)
│
└── spring-backend/           # Spring Boot backend service
    ├── src/
    │   ├── main/
    │   │   ├── java/com/scanmyfood/backend/
    │   │   │   ├── configurations/  # App configs
    │   │   │   ├── controllers/     # REST API endpoints
    │   │   │   ├── models/          # Data entities
    │   │   │   ├── repositories/    # Database access
    │   │   │   ├── services/        # Business logic
    │   │   │   └── ScanMyFoodBackendApplication.java
    │   │   └── resources/           # Application properties
    │   └── test/                    # Unit and integration tests
    └── pom.xml                      # Maven dependencies
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.4.3)
- Java JDK 17+
- Maven 3.6+
- PostgreSQL 14+
- Firebase project with Authentication enabled
- Google Cloud project with Vertex AI API enabled

### Frontend Setup

1. Clone the repository
```bash
git clone https://github.com/nikhileshmeher0204/read_the_label.git
cd read_the_label
```

2. Navigate to the Flutter app directory
```bash
cd flutter-app
```

3. Set up Firebase
   - Create a Firebase project at [firebase.google.com](https://firebase.google.com)
   - Add Android and iOS apps to your project
   - Download and add the configuration files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS)
   - Enable Authentication with Email/Password provider

4. Create a `.env` file in the Flutter app directory:
```
# Optional local development URL (if not using default)
API_BASE_URL=http://localhost:8080/api
```

5. Install dependencies
```bash
flutter pub get
```

6. Run the app
```bash
flutter run
```

### Backend Setup

1. Navigate to the Spring Boot backend directory
```bash
cd spring-backend
```

2. Configure Google Cloud credentials
   - Create a service account in your Google Cloud project
   - Grant it access to Vertex AI API
   - Download the service account key file as `firebase-service-account.json` 
   - Place it in `src/main/resources/`

3. Configure PostgreSQL
   - Create a PostgreSQL database named `scanmyfood`
   - Update database connection details in `application.properties` if needed:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/scanmyfood
spring.datasource.username=your_username
spring.datasource.password=your_password
```

4. Build and run the Spring Boot application
```bash
# Using Maven
mvn spring-boot:run

# Or using the Maven wrapper
./mvnw spring-boot:run
```

## State Management

This application uses a combination of state management approaches:

- **Frontend**: Provider for Flutter app state management
  - **ViewModels**: 
    - `UiViewModel`: Handles UI state and navigation
    - `ProductAnalysisViewModel`: Manages product scanning and analysis
    - `MealAnalysisViewModel`: Handles food image analysis
    - `DailyIntakeViewModel`: Controls daily consumption tracking
    - `OnboardingViewModel`: Manages user onboarding flow

- **Backend**: Spring services for business logic
  - `UserService`: User profile and preferences management
  - `VertexAiServiceImpl`: AI analysis implementation
  - Authentication handled via Firebase integration

## Technologies Used

### Frontend
- **Flutter SDK** (>=3.4.3)
- **Dart SDK** 
- **Firebase Authentication** for user management
- **Provider** for state management
- **SharedPreferences** for local storage
- **Material Design 3** with custom theme
- **Key Flutter packages**:
  - `image_picker` for camera integration
  - `flutter_dotenv` for environment variables
  - `fl_chart` for data visualization
  - `rive` for animations
  - `http` for API communication

### Backend
- **Spring Boot 3.4.5** for RESTful API development
- **Spring Data JPA** for database operations
- **PostgreSQL** for data persistence
- **Google Cloud Vertex AI** for AI-powered analysis
- **Firebase Admin SDK** for authentication verification
- **Maven** for dependency management

### Infrastructure
- **Google Cloud Platform**:
  - Vertex AI (Gemini 2.0 Flash model)
  - Firebase Authentication
  - Cloud Storage (optional for production)

## Deployment

### Frontend
- Build the Flutter app for production:
```bash
flutter build apk --release  # for Android
flutter build ios --release  # for iOS
```

### Backend
- Package the Spring Boot application:
```bash
mvn clean package
```
- Deploy the resulting JAR file to your server or cloud provider

## Future Enhancements

- Real-time data synchronization between devices
- Advanced meal planning with AI recommendations
- Barcode scanning for quick product lookup
- Machine learning for personalized nutritional insights
- Dietary goal tracking and achievement rewards
- Social sharing and community features

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Google Cloud Vertex AI for powerful AI capabilities
- Spring Boot team for the excellent backend framework
- Flutter team for the amazing cross-platform UI toolkit
- Firebase for seamless authentication
- PostgreSQL for reliable data storage

