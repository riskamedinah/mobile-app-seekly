import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends GetxController {
  RxList<DocumentSnapshot> posts = <DocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      posts.value = snapshot.docs;
    });
  }
}
