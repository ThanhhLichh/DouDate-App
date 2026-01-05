class UserProfile {
  final String id;
  final String name;
  final String? birthday;
  final String? gender;
  final String? avatarUrl;
  final bool isConnected;
  final String? partnerName;
  final String? email;

  UserProfile({
    required this.id,
    required this.name,
    this.birthday,
    this.gender,
    this.avatarUrl,
    this.isConnected = false,
    this.partnerName,
    this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      birthday: json['birthday'],
      gender: json['gender'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      isConnected: json['is_connected'] ?? json['isConnected'] ?? false,
      partnerName: json['partner_name'] ?? json['partnerName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthday': birthday,
      'gender': gender,
      'avatar_url': avatarUrl,
      'is_connected': isConnected,
      'partner_name': partnerName,
      'email': email,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? birthday,
    String? gender,
    String? avatarUrl,
    bool? isConnected,
    String? partnerName,
    String? email,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isConnected: isConnected ?? this.isConnected,
      partnerName: partnerName ?? this.partnerName,
      email: email ?? this.email,
    );
  }
}
