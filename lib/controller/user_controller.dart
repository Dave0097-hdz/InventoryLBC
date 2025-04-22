class UserProfile {
  final String imageUrl;
  final String displayName;
  final String email;

  UserProfile({required this.imageUrl, required this.displayName, required this.email});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      imageUrl: json['imageUrl'],
      displayName: json['displayName'],
      email: json['email'],
    );
  }
}