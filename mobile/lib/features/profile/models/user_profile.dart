class UserProfile {
  final int id;
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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['full_name'] ?? json['name'] ?? '',
      birthday: json['birth_date'] ?? json['birthday'],
      gender: json['gender'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      partnerName: json['partner_name'] ?? json['partnerName'],
      email: json['email'],
    );
  }

  UserProfile copyWith({
    int? id,
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
