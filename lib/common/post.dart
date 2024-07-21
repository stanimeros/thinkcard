import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String id;
  final String uid;
  final String title;
  final int likes;
  final int dislikes;
  final List<String> images;

  const Post({
    required this.id,
    required this.uid,
    required this.title,
    required this.likes,
    required this.dislikes,
    required this.images
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Post(
      id: doc.id,
      uid: data['uid'] ?? 'debug',
      title: data['title'] ?? 'Untitled',
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
      images: List<String>.from(data['images'] ?? []),
    );
  }
}