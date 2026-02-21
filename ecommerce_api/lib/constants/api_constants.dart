class ApiConstants {
  // Base URL for the API
  static const String apiBaseUrl = 'https://urban-store-6gj1.onrender.com/api/v1';

  static const String register = '$apiBaseUrl/auth/register';
  static const String login = '$apiBaseUrl/auth/login';
  static const String forgotPassword = '$apiBaseUrl/auth/forgot-password';
  static const String verifyOtp = '$apiBaseUrl/auth/verify-otp';
  // Some backends may have a typo in the route (verity-otp). Keep alternative constant.
  static const String verityOtp = '$apiBaseUrl/auth/verity-otp';
  static const String resetPassword = '$apiBaseUrl/auth/reset-password';
}
