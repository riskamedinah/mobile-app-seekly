import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailView extends StatefulWidget {
  final String postId;

  const PostDetailView({required this.postId});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final TextEditingController _commentController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> addComment() async {
    if (user == null || _commentController.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'userId': user!.uid,
      'content': _commentController.text.trim(),
      'createdAt': Timestamp.now(),
    });

    _commentController.clear();
  }

  @override
  void dispose() {
    _commentController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
    super.dispose();
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white, // Scaffold background putih
    appBar: AppBar(title: Text('Detail Postingan')),
    body: StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.white, // pastikan loading juga putih background-nya
            child: Center(child: CircularProgressIndicator()),
          );
        }
          final post = snapshot.data!.data() as Map<String, dynamic>;
          final createdAt = (post['createdAt'] as Timestamp).toDate();
          final imageUrl = post['imageUrl'];
          final userId = post['userId'];

          return SafeArea(
            child: Container(
              color: Colors.white, // Container pembungkus dengan background putih
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // === Post Header ===
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData) {
                                  return SizedBox.shrink();
                                }

                                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                final name = userData?['name'] ?? 'Anonim';
                                final profileImageUrl = userData?['profileImageUrl'];

                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                          profileImageUrl == null || profileImageUrl.isEmpty
                                              ? Colors.grey.shade300
                                              : null,
                                      backgroundImage:
                                          profileImageUrl != null && profileImageUrl.isNotEmpty
                                              ? NetworkImage(profileImageUrl)
                                              : null,
                                      child: (profileImageUrl == null || profileImageUrl.isEmpty)
                                          ? Icon(Icons.person, color: Colors.white)
                                          : null,
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
                          ),

                          // === Caption ===
                          if ((post['caption'] ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(post['caption'], style: TextStyle(fontSize: 16)),
                            ),
                          if ((post['caption'] ?? '').isNotEmpty)
                            SizedBox(height: 10),

                          // === Image ===
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                          // === Like & Comment Count ===
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(widget.postId)
                                      .collection('likes')
                                      .doc(user?.uid)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    final isLiked = snapshot.data?.exists ?? false;
                                    return IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked ? Colors.red : null,
                                      ),
                                      onPressed: () async {
                                        final likeRef = FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(widget.postId)
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
                                      .doc(widget.postId)
                                      .collection('likes')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    final count = snapshot.data?.docs.length ?? 0;
                                    return Text('$count suka');
                                  },
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.comment, size: 20),
                                SizedBox(width: 8),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(widget.postId)
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
                          Divider(),

                          // === Comments ===
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.postId)
                                .collection('comments')
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return Center(child: CircularProgressIndicator());
                              final comments = snapshot.data!.docs;

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index].data() as Map<String, dynamic>;
                                  final commentUserId = comment['userId'];
                                  final content = comment['content'] ?? '';
                                  final date = (comment['createdAt'] as Timestamp).toDate();

                                  return StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(commentUserId)
                                        .snapshots(),
                                    builder: (context, userSnapshot) {
                                      final userData =
                                          userSnapshot.data?.data() as Map<String, dynamic>?;
                                      final name = userData?['name'] ?? 'Anonim';
                                      final profileImageUrl = userData?['profileImageUrl'];

                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              (profileImageUrl != null && profileImageUrl.isNotEmpty)
                                                  ? NetworkImage(profileImageUrl)
                                                  : null,
                                          child: (profileImageUrl == null ||
                                                  profileImageUrl.isEmpty)
                                              ? Icon(Icons.person)
                                              : null,
                                        ),
                                        title: Text(name),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(content),
                                            Text(
                                              timeago.format(date, locale: 'id'),
                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // === Input komentar ===
                  Container(
                    color: Colors.white, // Background input komentar juga putih
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Tulis komentar...',
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: addComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
