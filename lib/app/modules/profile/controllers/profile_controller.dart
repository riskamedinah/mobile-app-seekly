import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Rx map untuk data user
  Rxn<Map<String, dynamic>> userData = Rxn<Map<String, dynamic>>();

  // UID user saat ini
  String? get uid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    if (uid != null) {
      // Listen realtime data user
      _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
        if (snapshot.exists) {
          userData.value = snapshot.data();
        }
      });
    }
  }

  // Update field user
  Future<void> updateField(String field, String value) async {
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update({field: value});
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
