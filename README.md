# Food Scan AI

A Flutter application that helps users track their nutritional intake by analyzing food product labels and meals using AI, built with clean MVVM architecture.

## Features

- 📸 Scan product labels and food items using your device's camera
- 🔍 AI-powered nutrition analysis using Google's Gemini API
- 📊 Track daily nutrient intake with detailed breakdowns
- 📅 View historical food consumption data
- 📈 Visual representations of macronutrient distribution
- ⚡ Real-time nutritional insights and recommendations
- 🧩 Built with MVVM architecture for clean, maintainable code
- 🔄 Provider for robust state management

## Screenshots

https://github.com/user-attachments/assets/82553c7d-5d61-4d22-9d99-2c2e15fa215b

| <img src="https://github.com/user-attachments/assets/a0a85d4f-26b6-44ea-a4f4-46f80bae9907" width="300" alt="Screenshot 1" /> | <img src="https://github.com/user-attachments/assets/a76ef71a-ce2f-402e-863d-baa435ddb938" width="300" alt="Screenshot 2" /> | <img src="https://github.com/user-attachments/assets/2b758598-71ae-4d8b-9406-73b2b52a8019" width="300" alt="Screenshot 3" /> |
|:---------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------:|
| <img src="https://github.com/user-attachments/assets/be941868-2eb8-4785-8a9e-d0d91bce66b3" width="300" alt="Screenshot 4" /> | <img src="https://github.com/user-attachments/assets/c0067fb8-136b-400e-b97e-f3e2c1a44c40" width="300" alt="Screenshot 5" /> | <img src="https://github.com/user-attachments/assets/a2387fc5-d440-4c82-9b79-da18c1723247" width="300" alt="Screenshot 6" /> |

## Architecture

Food Scan AI follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures and business logic
- **Views**: UI components (screens and widgets)
- **ViewModels**: Intermediaries that handle UI logic and data operations
- **Repositories**: Abstractions for data sources (AI API, local storage)

### Project Structure

```
lib/
├── core/
│   └── constants/         # App-wide constants
├── config/
│   └── env_config.dart    # Environment configuration
├── models/                # Data models
├── repositories/          # Data access layer with interfaces
├── theme/                 # App theme definitions  
├── viewmodels/            # ViewModels for business logic
├── views/                 # UI components
│   ├── screens/           # Full page views
│   └── widgets/           # Reusable UI components
└── main.dart              # Application entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.4.3)
- Dart SDK
- Google Gemini API key

### Installation

1. Clone the repository
```bash
git clone https://github.com/nikhileshmeher0204/read_the_label.git
```

2. Navigate to the project directory
```bash
cd read_the_label
```

3. Create a .env file in the root directory and add your Gemini API key:
```bash
GEMINI_API_KEY=your_api_key_here
```

4. Install dependencies
```bash
flutter pub get
```

5. Run the app
```bash
flutter run
```

## State Management

This application uses Provider for state management:

- **BaseViewModel**: Foundation class for all ViewModels
- **ViewModels**:
  - **UiViewModel**: Handles UI state and navigation
  - **ProductAnalysisViewModel**: Manages product scanning and analysis
  - **MealAnalysisViewModel**: Handles food image analysis
  - **DailyIntakeViewModel**: Controls daily consumption tracking

## Technologies Used

- **Flutter SDK** (>=3.4.3)
- **Dart SDK**
- **Google Generative AI (Gemini)** for AI-powered analysis
- **Provider** for state management
- **SharedPreferences** for local storage
- **Material Design 3** with custom theme
- **Various Flutter packages**:
  - `image_picker` for camera integration
  - `flutter_dotenv` for environment variables
  - `fl_chart` for data visualization
  - `rive` for animations

## Future Enhancements

- Spring Boot backend integration for cross-device synchronization
- User authentication and profiles
- Enhanced nutritional insights with AI recommendations
- Social sharing features

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Google Generative AI for the Gemini API
- Flutter team for the amazing framework
