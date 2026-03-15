import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc_app/entities/global_setting_entity.dart';

abstract class MasterDataRepository {
  Future<Either<String, GlobalSettingEntity>> loadMasterData();
}

class MasterDataRepositoryImpl extends MasterDataRepository {
  final _firebaseFireStore = FirebaseFirestore.instance;

  @override
  Future<Either<String, GlobalSettingEntity>> loadMasterData() async {
    try {
      final doc =
          await _firebaseFireStore.collection("global").doc("settings").get();

      if (!doc.exists) {
        return const Left("Settings not found");
      }

      final data = doc.data()!;
      return Right(GlobalSettingEntity.fromFirestore(data));
    } catch (e) {
      return Left("Master data fetching error: $e");
    }
  }
}
