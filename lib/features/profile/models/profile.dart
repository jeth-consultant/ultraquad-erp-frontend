/// The signed-in member's profile, as returned by GET /profile.
class Profile {
  const Profile({
    required this.id,
    required this.memberCode,
    required this.name,
    required this.phone,
    required this.email,
    required this.githubUsername,
    required this.role,
    required this.createdAt,
  });

  final int id;
  final String memberCode;
  final String name;
  final String phone;
  final String email;
  final String? githubUsername;
  final String role;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      memberCode: json['member_code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      githubUsername: json['github_username'] as String?,
      role: json['role'] as String? ?? 'member',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
