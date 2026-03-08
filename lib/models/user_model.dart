// lib/models/user_model.dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String? username;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime? createdAt;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.email,
    this.username,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.createdAt,
    this.fcmToken,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    DateTime? createdAt,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      username: data['username'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : null,
      fcmToken: data['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'fcmToken': fcmToken,
    };
  }

  String get initials {
    final name = displayName ?? username ?? email;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  @override
  List<Object?> get props => [uid, email, username, displayName, photoUrl, emailVerified];
}
