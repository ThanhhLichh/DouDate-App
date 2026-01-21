// Login Request
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

// Register Request
class RegisterRequest {
  final String email;
  final String password;
  final String fullName;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'full_name': fullName,
  };
}

// Forgot Password Request
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

// Forgot Password Response
class ForgotPasswordResponse {
  final String otpToken;
  final String message;

  ForgotPasswordResponse({required this.otpToken, required this.message});

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      otpToken: json['otp_token'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

// Verify OTP Request
class VerifyOtpRequest {
  final String email;
  final String otp;
  final String token;

  VerifyOtpRequest({
    required this.email,
    required this.otp,
    required this.token,
  });

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp, 'token': token};
}

// Verify OTP Response
class VerifyOtpResponse {
  final String resetToken;

  VerifyOtpResponse({required this.resetToken});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(resetToken: json['reset_token'] ?? '');
  }
}

// Reset Password Request
class ResetPasswordRequest {
  final String resetToken;
  final String newPassword;

  ResetPasswordRequest({required this.resetToken, required this.newPassword});

  Map<String, dynamic> toJson() => {
    'reset_token': resetToken,
    'new_password': newPassword,
  };
}

// Reset Password Response
class ResetPasswordResponse {
  final String message;

  ResetPasswordResponse({required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(message: json['message'] ?? '');
  }
}

// Auth Response
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }
}

// User Model
class User {
  final int id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? birthDate;
  final String? bio;
  final String role;
  final bool isActive;
  final String createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.birthDate,
    this.bio,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'],
      birthDate: json['birth_date'],
      bio: json['bio'],
      role: json['role'] ?? 'user',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'birth_date': birthDate,
    'bio': bio,
    'role': role,
    'is_active': isActive,
    'created_at': createdAt,
  };

  // Getter for backward compatibility
  String get name => fullName;
}

// Register Response
class RegisterResponse {
  final User user;

  RegisterResponse({required this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(user: User.fromJson(json));
  }
}

// Couple Model
class CoupleCheckResponse {
  final bool hasCouple;
  final Couple? couple;

  CoupleCheckResponse({required this.hasCouple, this.couple});

  factory CoupleCheckResponse.fromJson(Map<String, dynamic> json) {
    return CoupleCheckResponse(
      hasCouple: json['has_couple'] ?? false,
      couple: json['couple'] != null ? Couple.fromJson(json['couple']) : null,
    );
  }
}

class Couple {
  final int id;
  final int user1Id;
  final int user2Id;
  final String startDate;

  Couple({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.startDate,
  });

  factory Couple.fromJson(Map<String, dynamic> json) {
    return Couple(
      id: json['id'] ?? 0,
      user1Id: json['user1_id'] ?? 0,
      user2Id: json['user2_id'] ?? 0,
      startDate: json['start_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user1_id': user1Id,
    'user2_id': user2Id,
    'start_date': startDate,
  };
}
