import 'package:read_the_label/viewmodels/base_view_model.dart';

enum DietaryPreference { vegetarian, nonVegetarian, vegan, none }

enum FitnessGoal { balancedDiet, muscleGain, weightLoss, none }

class OnboardingViewModel extends BaseViewModel {
  // Food preference data
  String _selectedCountry = "United States";
  DietaryPreference _dietaryPreference = DietaryPreference.none;

  // Health metrics data
  int _selectedHeightFeet = 5;
  int _selectedHeightInches = 8;
  int _selectedWeight = 65;
  FitnessGoal _fitnessGoal = FitnessGoal.none;

  // Getters
  String get selectedCountry => _selectedCountry;
  DietaryPreference get dietaryPreference => _dietaryPreference;
  int get selectedHeightFeet => _selectedHeightFeet;
  int get selectedHeightInches => _selectedHeightInches;
  int get selectedWeight => _selectedWeight;
  FitnessGoal get fitnessGoal => _fitnessGoal;

  // Setters with notification
  void setCountry(String country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void setDietaryPreference(DietaryPreference preference) {
    _dietaryPreference = preference;
    notifyListeners();
  }

  void setHeightFeet(int feet) {
    _selectedHeightFeet = feet;
    notifyListeners();
  }

  void setHeightInches(int inches) {
    _selectedHeightInches = inches;
    notifyListeners();
  }

  void setWeight(int weight) {
    _selectedWeight = weight;
    notifyListeners();
  }

  void setFitnessGoal(FitnessGoal goal) {
    _fitnessGoal = goal;
    notifyListeners();
  }

  // Helper methods for backend format
  String getDietaryPreferenceString() {
    switch (_dietaryPreference) {
      case DietaryPreference.vegetarian:
        return "VEG";
      case DietaryPreference.nonVegetarian:
        return "NON_VEG";
      case DietaryPreference.vegan:
        return "VEGAN";
      case DietaryPreference.none:
        return "";
    }
  }

  String getGoalString() {
    switch (_fitnessGoal) {
      case FitnessGoal.balancedDiet:
        return "BALANCED_DIET";
      case FitnessGoal.muscleGain:
        return "MUSCLE_GAIN";
      case FitnessGoal.weightLoss:
        return "WEIGHT_LOSS";
      case FitnessGoal.none:
        return "";
    }
  }

  // Helper method to check if onboarding is complete
  bool isOnboardingDataComplete() {
    return _dietaryPreference != DietaryPreference.none &&
        _fitnessGoal != FitnessGoal.none;
  }

  int getDietaryPreferenceIndex() {
    switch (_dietaryPreference) {
      case DietaryPreference.vegetarian:
        return 0;
      case DietaryPreference.nonVegetarian:
        return 1;
      case DietaryPreference.vegan:
        return 2;
      case DietaryPreference.none:
        return -1;
    }
  }

  int getFitnessGoalIndex() {
    switch (_fitnessGoal) {
      case FitnessGoal.balancedDiet:
        return 0;
      case FitnessGoal.muscleGain:
        return 1;
      case FitnessGoal.weightLoss:
        return 2;
      case FitnessGoal.none:
        return -1;
    }
  }
}
