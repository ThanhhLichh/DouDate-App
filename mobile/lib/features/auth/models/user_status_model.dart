class UserStatusResponse {
  final bool isDating;
  final String? partnerId;
  final String? partnerName;

  UserStatusResponse({
    required this.isDating,
    this.partnerId,
    this.partnerName,
  });

  factory UserStatusResponse.fromJson(Map<String, dynamic> json) {
    return UserStatusResponse(
      isDating: json['isDating'] ?? false,
      partnerId: json['partnerId'],
      partnerName: json['partnerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDating': isDating,
      'partnerId': partnerId,
      'partnerName': partnerName,
    };
  }
}
