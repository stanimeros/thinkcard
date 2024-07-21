import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser{
  final String uid;
  final String email;
  String username;
  DateTime? joined;
  String imageURL;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    this.joined,
    this.imageURL = '',
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      joined: data['joined']?.toDate(),
      imageURL: data['image'] ?? '',
    );
  }
}