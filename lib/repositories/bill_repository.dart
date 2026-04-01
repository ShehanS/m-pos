import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc_app/entities/bill_entity.dart';

abstract class BillRepository {
  Future<Either<String, BillEntity>> addBill(String userId, BillEntity bill);

  Future<Either<String, List<BillEntity>>> getBills();

  Future<Either<String, List<BillEntity>>> getBillsByUserId(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<String, String>> updateBill(BillEntity bill);

  Future<Either<String, Unit>> deleteBill(String billId);
}

class BillRepositoryImpl implements BillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = "customerBills";

  @override
  Future<Either<String, BillEntity>> addBill(
      String userId, BillEntity bill) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final billToSave = bill.copyWith(billId: docRef.id);
      await docRef.set(billToSave.toFirestore());
      return Right(billToSave);
    } catch (e) {
      return Left("Failed to save customer_bills: $e");
    }
  }

  @override
  Future<Either<String, List<BillEntity>>> getBills() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      final bills = snapshot.docs
          .map((doc) => BillEntity.fromFirestore(doc.id, doc.data()))
          .toList();
      return Right(bills);
    } catch (e) {
      return Left("Failed to fetch bills: $e");
    }
  }

  @override
  Future<Either<String, List<BillEntity>>> getBillsByUserId(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('createdBy', isEqualTo: userId);

      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        final endOfInclusiveDay =
            DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfInclusiveDay));
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();

      final bills = snapshot.docs
          .map((doc) => BillEntity.fromFirestore(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return Right(bills);
    } catch (e) {
      return Left("Failed to fetch user bills: $e");
    }
  }

  @override
  Future<Either<String, String>> updateBill(BillEntity bill) async {
    try {
      if (bill.billId == null) return const Left("Bill ID is missing");
      await _firestore
          .collection(_collection)
          .doc(bill.billId)
          .update(bill.toFirestore());
      return const Right("Updated..");
    } catch (e) {
      return Left("Failed to update customer_bills: $e");
    }
  }

  @override
  Future<Either<String, Unit>> deleteBill(String billId) async {
    try {
      await _firestore.collection(_collection).doc(billId).delete();
      return const Right(unit);
    } catch (e) {
      return Left("Failed to delete customer_bills: $e");
    }
  }
}
