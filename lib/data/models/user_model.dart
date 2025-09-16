class User {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? username;
  final String? phoneNumber;
  final bool isActive;
  final bool isStaff;
  final DateTime? dateJoined;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.username,
    this.phoneNumber,
    this.isActive = true,
    this.isStaff = false,
    this.dateJoined,
  });

  // Computed property for full name
  String get fullName => '$firstName $lastName';

  // Factory constructor from JSON (for API responses)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      phoneNumber: json['phone_number'],
      isActive: json['is_active'] ?? true,
      isStaff: json['is_staff'] ?? false,
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'])
          : null,
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'username': username,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'is_staff': isStaff,
      'date_joined': dateJoined?.toIso8601String(),
    };
  }

  // Copy with method for updates
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? phoneNumber,
    bool? isActive,
    bool? isStaff,
    DateTime? dateJoined,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      dateJoined: dateJoined ?? this.dateJoined,
    );
  }
}
