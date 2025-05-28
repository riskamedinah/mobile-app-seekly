import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../views/post_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final user = FirebaseAuth.instance.currentUser;

  Widget buildMediaWidget(Map<String, dynamic> data) {
    final type = data['type'] ?? 'text';
    final imageUrl = data['imageUrl'] ?? '';
    final videoUrl = data['videoUrl'] ?? '';
    final documentUrl = data['documentUrl'] ?? '';
    final thumbnailUrl = data['thumbnailUrl'] ?? '';
    final postId = data['postId'];

    if (type == 'image' && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, size: 50),
            );
          },
        ),
      );
    } else if (type == 'video' && videoUrl.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          Get.to(() => PostDetailView(postId: postId));
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: thumbnailUrl.isNotEmpty
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.black12,
                      child: Icon(Icons.videocam, size: 80, color: Colors.grey),
                    ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    } else if (type == 'document' && documentUrl.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          Get.to(() => PostDetailView(postId: postId));
        },
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  documentUrl.split('/').last,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox.shrink(); // untuk tipe text atau kosong
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 🔷 Latar belakang biru muda
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true, // 🔸 Buat teks di tengah
        elevation: 0,
        title: Text(
          'Beranda',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              final caption = data['caption'] ?? '';
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              final userId = data['userId'];

              return GestureDetector(
                onTap: () => Get.to(() => PostDetailView(postId: post.id)),
                child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                          builder: (context, userSnapshot) {
                            final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                            final name = userData?['name'] ?? 'Anonim';
                            final profileImageUrl = userData?['profileImageUrl'] ?? '';

                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: (profileImageUrl.isNotEmpty)
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                                  child: (profileImageUrl.isEmpty) ? Icon(Icons.person) : null,
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      timeago.format(createdAt, locale: 'id'),
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 10),

                        if (caption.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(caption),
                          ),

                        buildMediaWidget({
                          'type': data['type'],
                          'imageUrl': data['imageUrl'],
                          'videoUrl': data['videoUrl'],
                          'documentUrl': data['documentUrl'],
                          'thumbnailUrl': data['thumbnailUrl'],
                          'postId': post.id,
                        }),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(post.id)
                                    .collection('likes')
                                    .doc(user?.uid)
                                    .snapshots(),
                                builder: (context, likeSnapshot) {
                                  final isLiked = likeSnapshot.data?.exists ?? false;
                                  return IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? Colors.red : null,
                                    ),
                                    onPressed: () async {
                                      final likeRef = FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(post.id)
                                          .collection('likes')
                                          .doc(user!.uid);

                                      if (isLiked) {
                                        await likeRef.delete();
                                      } else {
                                        await likeRef.set({'likedAt': Timestamp.now()});
                                      }
                                    },
                                  );
                                },
                              ),

                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(post.id)
                                    .collection('likes')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  final count = snapshot.data?.docs.length ?? 0;
                                  return Text('$count suka');
                                },
                              ),

                              SizedBox(width: 16),

                              GestureDetector(
                                onTap: () => Get.to(() => PostDetailView(postId: post.id)),
                                child: Row(
                                  children: [
                                    Icon(Icons.comment, size: 20),
                                    SizedBox(width: 6),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(post.id)
                                          .collection('comments')
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        final count = snapshot.data?.docs.length ?? 0;
                                        return Text('$count komentar');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
