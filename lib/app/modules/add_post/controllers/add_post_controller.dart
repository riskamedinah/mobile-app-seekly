import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostController extends GetxController {
  final captionController = TextEditingController();
  final Rx<File?> pickedImage = Rx<File?>(null);
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedImage.value = File(pickedFile.path);
    }
  }

  Future<void> submitPost() async {
    String? imageBase64;
    if (pickedImage.value != null) {
      final bytes = await pickedImage.value!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    await FirebaseFirestore.instance.collection('posts').add({
      'caption': captionController.text,
      'imageBase64': imageBase64,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'userName': userData['name'],
      'userProfile': userData['profileImageBase64'],
    });

    captionController.clear();
    pickedImage.value = null;
    Get.back(); // Return to Home
  }
}
