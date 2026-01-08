class UserProfile {
  final String id;
  final String name;
  final String? birthday;
  final String? gender;
  final String? avatarUrl;
  final String? partnerName;
  final String? email;

  UserProfile({
    required this.id,
    required this.name,
    this.birthday,
    this.gender,
    this.avatarUrl,
    this.partnerName,
    this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
      birthday: json['birth_date'] ?? json['birthday'],
      gender: json['gender'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      // isConnected:
      //     json['partner_name'] != null &&
      //     (json['partner_name'] as String).isNotEmpty,
      partnerName: json['partner_name'] ?? json['partnerName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': name,
      'birth_date': birthday,
      'gender': gender,
      'avatar_url': avatarUrl,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? birthday,
    String? gender,
    String? avatarUrl,
    String? partnerName,
    String? email,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      partnerName: partnerName ?? this.partnerName,
      email: email ?? this.email,
    );
  }
}
