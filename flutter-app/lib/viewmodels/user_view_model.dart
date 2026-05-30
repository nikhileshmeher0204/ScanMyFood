import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/user_profile.dart';
import 'package:read_the_label/repositories/user_repository_interface.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';

class UserViewModel extends BaseViewModel {
  // Authentication state
  bool _isAuthenticated = false;
  String _userId = '';
  UserProfile? _userProfile;
  bool _isLoadingProfile = false;

  bool get isAuthenticated => _isAuthenticated;
  String get userId => _userId;
  UserProfile? get userProfile => _userProfile;
  bool get isLoadingProfile => _isLoadingProfile;

  // Authentication methods
  void setAuthenticated(bool isAuthenticated, String userId) {
    _isAuthenticated = isAuthenticated;
    _userId = userId;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _userId = '';
    _userProfile = null;
    notifyListeners();
  }

  Future<void> fetchUserProfile(UserRepositoryInterface userRepository) async {
    logger.d('UserViewModel: Fetching user profile...');
    _isLoadingProfile = true;
    notifyListeners();
    try {
      _userProfile = await userRepository.getUserProfile();
      logger.i('UserViewModel: User profile successfully loaded and cached.');
    } catch (e) {
      logger.e('UserViewModel: Failed to fetch user profile', e);
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }
}

