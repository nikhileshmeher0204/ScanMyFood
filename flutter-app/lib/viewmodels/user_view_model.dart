import 'package:read_the_label/viewmodels/base_view_model.dart';

class UserViewModel extends BaseViewModel {
  // Authentication state
  bool _isAuthenticated = false;
  String _userId = '';

  bool get isAuthenticated => _isAuthenticated;
  String get userId => _userId;

  // Authentication methods
  void setAuthenticated(bool isAuthenticated, String userId) {
    _isAuthenticated = isAuthenticated;
    _userId = userId;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _userId = '';
    notifyListeners();
  }
}
