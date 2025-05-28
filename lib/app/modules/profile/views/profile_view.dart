import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../profile_edit/views/profile_edit_view.dart';

class ProfileView extends StatelessWidget {
  ProfileView({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('User tidak ditemukan'));
    }

    final userStream = _firestore.collection('users').doc(uid).snapshots();

    void _showBottomSheet({required String title, required String field, required Map<String, dynamic> data}) {
      String tempValue = data[field] ?? '';

      Get.bottomSheet(
        StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    autofocus: true,
                    controller: TextEditingController(text: data[field] ?? ''),
                    onChanged: (val) => tempValue = val,
                    decoration: InputDecoration(
                      hintText: 'Masukkan $title',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (tempValue.trim().isNotEmpty) {
                        await _firestore.collection('users').doc(uid).update({
                          field: tempValue.trim(),
                        });
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFED652A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            );
          },
        ),
        isScrollControlled: true,
      );
    }

    void _showSettingsMenu() {
      Get.bottomSheet(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await _auth.signOut();
                  Get.back(); // tutup bottom sheet
                  Get.offAllNamed('/login'); // pindah ke halaman login (pastikan route-nya ada)
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Color(0xFFED652A)),
                title: const Text('Edit Profil', style: TextStyle(color: Color(0xFFED652A))),
                onTap: () {
                  Get.back(); // tutup bottom sheet
                  Get.to(() => ProfileEditView());
                },
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Data pengguna tidak ditemukan'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final name = data['name'] ?? 'Nama Kamu';
        final username = data['email']?.split('@')[0] ?? 'username';
        final bio = data['bio'] ?? 'Belum ada bio';
        final pendidikan = data['pendidikan'] ?? 'Tambahkan informasi pendidikan';
        final lokasi = data['lokasi'] ?? 'Tambahkan lokasi';
        final profileImageUrl = data['profileImageUrl'] ?? '';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Profil',
              style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Color(0xFF333333)),
                onPressed: _showSettingsMenu,
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : const AssetImage('images/image1.png') as ImageProvider,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('@$username', style: const TextStyle(fontSize: 14, color: Color(0xFF717171))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(bio),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => ProfileEditView());
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Profil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFED652A),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 8, color: Colors.grey[50]),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Informasi Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildInfoItem(
                  icon: 'images/graduation.png',
                  title: pendidikan,
                  onTap: () => _showBottomSheet(title: 'Pendidikan', field: 'pendidikan', data: data),
                ),
                _buildInfoItem(
                  icon: 'images/location.png',
                  title: lokasi,
                  onTap: () => _showBottomSheet(title: 'Lokasi', field: 'lokasi', data: data),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
                  child: Row(
                    children: [
                      Image.asset('images/calendar.png', width: 22),
                      const SizedBox(width: 24),
                      const Text(
                        'Bergabung sejak Mei 2025',
                        style: TextStyle(color: Color(0xFF717171), fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Color(0xFFED652A), fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFED652A)),
          ],
        ),
      ),
    );
  }
}
