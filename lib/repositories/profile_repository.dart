import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<String, Map<String, dynamic>>> updateProfile(
      String userId, Map<String, dynamic> profile);

  Future<Either<String, Map<String, dynamic>>> getProfile(
      String userId);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final _firebaseFireStore = FirebaseFirestore.instance;

  @override
  Future<Either<String, Map<String, dynamic>>> updateProfile(
      String userId, Map<String, dynamic> profile) async {
    try {
      await _firebaseFireStore
          .collection('users')
          .doc(userId)
          .set(profile, SetOptions(merge: true));

      return Right(profile);
    } catch (e) {
      return Left("Profile updating error: $e");
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> getProfile(String userId) async {
    try {
      final doc = await _firebaseFireStore
          .collection('users')
          .doc(userId)
          .get();
      if (!doc.exists || doc.data() == null) {
        return Left("Profile not found");
      }
      return Right(doc.data()!);
    } catch (e) {
      return Left("Profile fetching error: $e");
    }
  }
}