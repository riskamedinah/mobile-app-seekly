import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileEditController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final bioController = TextEditingController();

  Rxn<File> imageFile = Rxn<File>();
  RxnString imageUrl = RxnString();

  // Uploadcare config
  final String uploadcarePublicKey = '5a15c480f72eb806bc3b'; // ganti dengan public key kamu

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['name'] ?? '';
      bioController.text = data['bio'] ?? '';
      imageUrl.value = data['profileImageUrl'];
      imageFile.value = null;
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile.value = File(picked.path);
    }
  }

  Future<String?> uploadImageToUploadcare(File image) async {
    // Uploadcare expects multipart POST with 'UPLOADCARE_PUB_KEY' and 'file' fields
    final uri = Uri.parse("https://upload.uploadcare.com/base/");

    final request = http.MultipartRequest('POST', uri)
      ..fields['UPLOADCARE_PUB_KEY'] = uploadcarePublicKey
      ..fields['UPLOADCARE_STORE'] = '1' // langsung simpan
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = await http.Response.fromStream(response);
      final data = json.decode(res.body);
      // data contoh: {"file":"<file_id>"}
      if (data['file'] != null) {
        // Format URL uploadcare:
        return 'https://ucarecdn.com/${data['file']}/';
      }
    } else {
      print("Uploadcare upload failed: ${response.statusCode}");
    }
    return null;
  }

  Future<void> saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    String? uploadedUrl = imageUrl.value;

    if (imageFile.value != null) {
      final url = await uploadImageToUploadcare(imageFile.value!);
      if (url != null) {
        uploadedUrl = url;
      }
    }

    await _firestore.collection('users').doc(uid).update({
      'name': nameController.text.trim(),
      'bio': bioController.text.trim(),
      'profileImageUrl': uploadedUrl,
    });

    imageUrl.value = uploadedUrl;
    imageFile.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}

class ProfileEditView extends StatelessWidget {
  ProfileEditView({Key? key}) : super(key: key);

  final controller = Get.put(ProfileEditController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Center(
              child: Obx(() {
                ImageProvider imgProvider;
                if (controller.imageFile.value != null) {
                  imgProvider = FileImage(controller.imageFile.value!);
                } else if (controller.imageUrl.value != null && controller.imageUrl.value!.isNotEmpty) {
                  imgProvider = NetworkImage(controller.imageUrl.value!);
                } else {
                  imgProvider = const AssetImage('images/image1.png');
                }

                return GestureDetector(
                  onTap: controller.pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(radius: 50, backgroundImage: imgProvider),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller.bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Biografi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                try {
                  await controller.saveProfile();
                  Get.back(); // tutup loading
                  Get.back(); // tutup halaman edit profil
                } catch (e) {
                  Get.back();
                  Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text("Simpan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFED652A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
