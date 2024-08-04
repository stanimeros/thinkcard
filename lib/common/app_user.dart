import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser{
  final String uid;
  final String email;
  String username;
  String description;
  String imageURL;
  DateTime? joined;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    this.description = '',
    this.imageURL = '',
    this.joined,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      description: data['description'] ?? '',
      imageURL: data['image'] ?? '',
      joined: data['joined']?.toDate(),
    );
  }
}