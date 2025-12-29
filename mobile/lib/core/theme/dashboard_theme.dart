import 'package:flutter/material.dart';

class DashboardTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Color accentColor;
  final Color cardBackground;
  final Color heartIconColor;
  final Color partnerBorderColor;
  final Color yourBorderColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final String? coupleBackgroundPath; // Local path to custom image
  final bool isCustom; // true if user has customized this theme

  const DashboardTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    required this.cardBackground,
    required this.heartIconColor,
    required this.partnerBorderColor,
    required this.yourBorderColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    this.coupleBackgroundPath,
    this.isCustom = false,
  });

  // Copy with method for customization
  DashboardTheme copyWith({
    String? id,
    String? name,
    Color? primaryColor,
    Color? accentColor,
    Color? cardBackground,
    Color? heartIconColor,
    Color? partnerBorderColor,
    Color? yourBorderColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
    String? coupleBackgroundPath,
    bool? isCustom,
  }) {
    return DashboardTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      cardBackground: cardBackground ?? this.cardBackground,
      heartIconColor: heartIconColor ?? this.heartIconColor,
      partnerBorderColor: partnerBorderColor ?? this.partnerBorderColor,
      yourBorderColor: yourBorderColor ?? this.yourBorderColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      coupleBackgroundPath: coupleBackgroundPath ?? this.coupleBackgroundPath,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  // Serialize to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryColor': primaryColor.toARGB32(),
      'accentColor': accentColor.toARGB32(),
      'cardBackground': cardBackground.toARGB32(),
      'heartIconColor': heartIconColor.toARGB32(),
      'partnerBorderColor': partnerBorderColor.toARGB32(),
      'yourBorderColor': yourBorderColor.toARGB32(),
      'textPrimaryColor': textPrimaryColor.toARGB32(),
      'textSecondaryColor': textSecondaryColor.toARGB32(),
      'coupleBackgroundPath': coupleBackgroundPath,
      'isCustom': isCustom,
    };
  }

  // Deserialize from JSON
  factory DashboardTheme.fromJson(Map<String, dynamic> json) {
    return DashboardTheme(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryColor: Color(json['primaryColor'] as int),
      accentColor: Color(json['accentColor'] as int),
      cardBackground: Color(json['cardBackground'] as int),
      heartIconColor: Color(json['heartIconColor'] as int),
      partnerBorderColor: Color(json['partnerBorderColor'] as int),
      yourBorderColor: Color(json['yourBorderColor'] as int),
      textPrimaryColor: Color(json['textPrimaryColor'] as int),
      textSecondaryColor: Color(json['textSecondaryColor'] as int),
      coupleBackgroundPath: json['coupleBackgroundPath'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DashboardTheme &&
        other.id == id &&
        other.name == name &&
        other.primaryColor == primaryColor &&
        other.accentColor == accentColor &&
        other.cardBackground == cardBackground &&
        other.heartIconColor == heartIconColor &&
        other.partnerBorderColor == partnerBorderColor &&
        other.yourBorderColor == yourBorderColor &&
        other.textPrimaryColor == textPrimaryColor &&
        other.textSecondaryColor == textSecondaryColor &&
        other.coupleBackgroundPath == coupleBackgroundPath &&
        other.isCustom == isCustom;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      primaryColor,
      accentColor,
      cardBackground,
      heartIconColor,
      partnerBorderColor,
      yourBorderColor,
      textPrimaryColor,
      textSecondaryColor,
      coupleBackgroundPath,
      isCustom,
    );
  }
}
