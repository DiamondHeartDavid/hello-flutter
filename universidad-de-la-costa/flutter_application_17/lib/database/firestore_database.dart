// Universidad de la Costa - Computación Móvil - Flutter Application 17:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== USERS ====================

  Future<void> createUserDocument({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String zone,
    required List<String> availableDays,
    String role = 'volunteer',
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'zone': zone,
        'availableDays': availableDays,
        'role': role,
        'totalHours': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Stream<Map<String, dynamic>?> currentUserStream() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// Set the role for a user document in `users` collection.
  /// Useful for test or admin elevation from the client during development.
  Future<void> setUserRole({required String uid, required String role}) async {
    try {
      // Use set with merge so the document is created if missing (dev/test only)
      await _firestore.collection('users').doc(uid).set({'role': role}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error setting user role: $e');
    }
  }

  // ==================== PLOTS ====================

  Future<void> createParcela({
    required String name,
    required String size,
    required String cropType,
    String status = 'Active',
    String? assignedTo,
  }) async {
    try {
      await _firestore.collection('parcelas').add({
        'name': name,
        'size': size,
        'cropType': cropType,
        'status': status,
        'assignedTo': assignedTo,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error creating plot: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getAllParcelas() {
    return _firestore
        .collection('parcelas')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> updateParcela({
    required String parcelaId,
    required String name,
    required String size,
    required String cropType,
    required String status,
    String? assignedTo,
  }) async {
    try {
      await _firestore.collection('parcelas').doc(parcelaId).update({
        'name': name,
        'size': size,
        'cropType': cropType,
        'status': status,
        'assignedTo': assignedTo,
      });
    } catch (e) {
      throw Exception('Error updating plot: $e');
    }
  }

  Future<Map<String, dynamic>?> getParcelaById(String parcelaId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('parcelas').doc(parcelaId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      throw Exception('Error getting plot: $e');
    }
  }

  Future<void> deleteParcela(String parcelaId) async {
    try {
      await _firestore.collection('parcelas').doc(parcelaId).delete();
    } catch (e) {
      throw Exception('Error deleting plot: $e');
    }
  }

  // ==================== TASKS ====================

  Future<void> createTask({
    required String title,
    required String description,
    required String type,
    required String parcelaId,
    required DateTime date,
    String? assignedTo,
  }) async {
    try {
      await _firestore.collection('tasks').add({
        'title': title,
        'description': description,
        'type': type,
        'parcelaId': parcelaId,
        'assignedTo': assignedTo,
        'date': Timestamp.fromDate(date),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error creating task: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getUserTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('assignedTo', isEqualTo: userId)
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getAllTasks() {
    return _firestore
        .collection('tasks')
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

  // ==================== PARTICIPATION ====================

  Future<void> registerParticipation({
    required String taskId,
    required double hoursWorked,
    String? notes,
  }) async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      await _firestore.collection('participation').add({
        'userId': uid,
        'taskId': taskId,
        'hoursWorked': hoursWorked,
        'date': FieldValue.serverTimestamp(),
        'notes': notes ?? '',
      });

      // Actualizar horas totales
      DocumentReference userRef = _firestore.collection('users').doc(uid);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);
        double currentHours =
            (userDoc.data() as Map<String, dynamic>)['totalHours'] ?? 0.0;
        transaction.update(userRef, {'totalHours': currentHours + hoursWorked});
      });
    } catch (e) {
      throw Exception('Error registering participation: $e');
    }
  }
}