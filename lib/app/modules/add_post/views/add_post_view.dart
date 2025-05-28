import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPostView extends StatefulWidget {
  const AddPostView({super.key});

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final TextEditingController captionController = TextEditingController();
  File? selectedImage;
  bool isLoading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> uploadImageToUploadcare(File image) async {
    final uri = Uri.parse("https://upload.uploadcare.com/base/");

    final request = http.MultipartRequest('POST', uri)
      ..fields['UPLOADCARE_PUB_KEY'] = '5a15c480f72eb806bc3b'
      ..fields['UPLOADCARE_STORE'] = '1'
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = await http.Response.fromStream(response);
      final data = json.decode(res.body);
      return 'https://ucarecdn.com/${data['file']}/';
    }

    return null;
  }

  Future<void> uploadPost() async {
    if (selectedImage == null || captionController.text.isEmpty) {
      Get.snackbar("Error", "Harap isi caption dan pilih gambar.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    final imageUrl = await uploadImageToUploadcare(selectedImage!);

    if (imageUrl == null) {
      Get.snackbar("Error", "Gagal upload gambar.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    await FirebaseFirestore.instance.collection('posts').add({
      'caption': captionController.text.trim(),
      'imageUrl': imageUrl,
      'type': 'image',
      'createdAt': Timestamp.now(),
      'userId': user!.uid,
    });

    // Reset form setelah sukses upload
    captionController.clear();
    setState(() {
      selectedImage = null;
      isLoading = false;
    });

    Get.snackbar("Sukses", "Postingan berhasil ditambahkan");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Postingan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: captionController,
              decoration: InputDecoration(
                labelText: "Caption",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            selectedImage != null
                ? Image.file(selectedImage!, height: 200)
                : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(child: Text("Tidak ada gambar dipilih")),
                  ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.photo),
              label: Text("Pilih Gambar"),
            ),

            const SizedBox(height: 10),

            // Tombol Upload PDF dan Video (baru, belum fungsi)
            ElevatedButton.icon(
              onPressed: () {
                Get.snackbar("Info", "Fitur upload PDF belum tersedia.");
              },
              icon: Icon(Icons.picture_as_pdf),
              label: Text("Upload PDF"),
              style: ElevatedButton.styleFrom(iconColor: Colors.red),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () {
                Get.snackbar("Info", "Fitur upload Video belum tersedia.");
              },
              icon: Icon(Icons.videocam),
              label: Text("Upload Video"),
              style: ElevatedButton.styleFrom(iconColor: Colors.blue),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : uploadPost,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Posting"),
            ),
          ],
        ),
      ),
    );
  }
}
