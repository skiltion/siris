import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/insert_result.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveResult(InsectResult result) async {
    await _firestore.collection('insect_results').add(result.toMap());
  }

  Stream<List<InsectResult>> getResultsStream() {
    return _firestore
        .collection('insect_results')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InsectResult.fromMap(doc.data()))
            .toList());
  }
}
