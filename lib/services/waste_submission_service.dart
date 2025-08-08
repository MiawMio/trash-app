import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WasteSubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // User submits waste
  Future<void> submitWaste(String wasteType, double weight) async {
    final user = currentUser;
    if (user == null) throw 'User not authenticated';

    await _firestore.collection('submissions').add({
      'userId': user.uid,
      'userName': user.displayName ?? 'Anonymous',
      'wasteType': wasteType,
      'weight': weight,
      'status': 'pending', // pending, approved, rejected
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  // Admin gets pending submissions
  Stream<QuerySnapshot> getPendingSubmissions() {
    return _firestore
        .collection('submissions')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Admin approves a submission
  Future<void> approveSubmission(String submissionId) async {
    await _firestore.collection('submissions').doc(submissionId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  // Admin rejects a submission
  Future<void> rejectSubmission(String submissionId) async {
    await _firestore.collection('submissions').doc(submissionId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }
}