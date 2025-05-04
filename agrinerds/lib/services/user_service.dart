class UserService {
  static final UserService _instance = UserService._internal();
  static String _currentUserId = 'user1'; // Default user ID

  factory UserService() => _instance;

  UserService._internal();

  String get currentUserId => _currentUserId;

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }
} 