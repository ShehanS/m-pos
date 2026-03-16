import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<String, UserEntity>> updateUser(String userId, UserEntity user);

  Future<Either<String, UserEntity>> getUser(String userId);
}

class UserRepositoryImpl implements UserRepository {
  final _firebaseFireStore = FirebaseFirestore.instance;

  @override
  Future<Either<String, UserEntity>> updateUser(
      String userId, UserEntity user) async {
    try {
      await _firebaseFireStore
          .collection('users')
          .doc(userId)
          .set(user.toFirestore(), SetOptions(merge: true));

      return Right(user);
    } catch (e) {
      return Left("User updating error: $e");
    }
  }

  @override
  Future<Either<String, UserEntity>> getUser(String userId) async {
    try {
      final doc = await _firebaseFireStore.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        return const Left("User not found");
      }
      return Right(UserEntity.fromFirestore(doc.data()!));
    } catch (e) {
      return Left("User fetching error: $e");
    }
  }
}
