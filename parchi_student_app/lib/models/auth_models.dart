// Auth Models for API responses

class User {
  final String id;
  final String email;
  final String role;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'is_active': isActive,
    };
  }
}

class Session {
  final String accessToken;
  final String refreshToken;
  final int expiresAt;
  final int expiresIn;
  final String tokenType;
  final User? user;

  Session({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.expiresIn,
    required this.tokenType,
    this.user,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] as int,
      expiresIn: json['expires_in'] as int,
      tokenType: json['token_type'] as String? ?? 'bearer',
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt,
      'expires_in': expiresIn,
      'token_type': tokenType,
      if (user != null) 'user': user!.toJson(),
    };
  }
}

class AuthResponse {
  final User user;
  final Session session;
  final int status;
  final String message;

  AuthResponse({
    required this.user,
    required this.session,
    required this.status,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponse(
      user: User.fromJson(data['user'] as Map<String, dynamic>),
      session: Session.fromJson(data['session'] as Map<String, dynamic>),
      status: json['status'] as int? ?? 200,
      message: json['message'] as String? ?? '',
    );
  }
}

class ProfileResponse {
  final User user;
  final int status;
  final String message;

  ProfileResponse({
    required this.user,
    required this.status,
    required this.message,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      user: User.fromJson(json['data'] as Map<String, dynamic>),
      status: json['status'] as int? ?? 200,
      message: json['message'] as String? ?? '',
    );
  }
}

class ApiError {
  final int statusCode;
  final String message;
  final String error;

  ApiError({
    required this.statusCode,
    required this.message,
    required this.error,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      statusCode: json['statusCode'] as int? ?? 500,
      message: json['message'] as String? ?? 'An error occurred',
      error: json['error'] as String? ?? 'Internal Server Error',
    );
  }
}

