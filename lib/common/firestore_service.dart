import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/common/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thinkcard/common/message.dart';
import 'package:thinkcard/common/post.dart';

class FirestoreService {
  User authUser = FirebaseAuth.instance.currentUser!;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<AppUser?> getUser(String uid) async {
    try {
      var snapshot = await firestore.collection('users').doc(uid).get();
      AppUser user = AppUser.fromFirestore(snapshot);
      if (authUser.uid == uid){
        globals.user = user;
      }
      return user;
    } catch (e) {
      debugPrint('Error getUser: $e');
      return null;
    }
  }

  Future<List<Post>> getRandomPosts() async {
    final firestore = FirebaseFirestore.instance;
    final postsCollection = firestore.collection('posts');

    // Get all posts
    final querySnapshot = await postsCollection.get();
    final allPosts = querySnapshot.docs;
    allPosts.shuffle();
    
    // Convert to List<Post>
    return allPosts.take(4).map((doc) => Post.fromFirestore(doc)).toList();
  }

  Future<List<Post>> getUserPosts(String uid) async {
    try {
      var querySnapshot = await firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp')
        .get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      return docs.reversed.map((doc) => Post.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getUserPosts: $e');
      return [];
    }
  }

  Future<void> incrementPostReaction(String postId, bool isLike) async {
    final postRef = firestore.collection('posts').doc(postId);

    // Define the field to update and the increment value
    final updateData = isLike
        ? {'likes': FieldValue.increment(1)}
        : {'dislikes': FieldValue.increment(1)};

    // Update the post with the incremented field value
    await postRef.update(updateData);
  }

  Future<List<AppUser>> searchUsers(String query) async {
    try {
      var start = query;
      var end = '$query\uf8ff';

      var querySnapshot = await firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: start)
        .where('username', isLessThan: end)
        .get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      return docs.map((doc) => AppUser.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error searchUsers: $e');
      return [];
    }
  }

  Future<bool> deletePost(Post post) async {
    try{
      DocumentReference postDocRef = firestore.collection('posts').doc(post.id);
      await postDocRef.delete();
      return true;
    }catch(e){
      debugPrint('Error deletePost: $e');
    }

    return false;
  }

  Stream<DocumentSnapshot> getChatSnapshot(AppUser friend){
    List<String> ids = [authUser.uid, friend.uid];
    ids.sort();
    String chatId = ids.join('_');

    var chatSnapshot = firestore
      .collection('chats')
      .doc(chatId)
      .snapshots();

    return chatSnapshot;
  }

  Stream<QuerySnapshot> getChatsSnapshot(){
    var chatsSnapshot = firestore
      .collection('chats')
      .where('users', arrayContains: authUser.uid)
      .snapshots();

    return chatsSnapshot;
  }

  void sendMessage(AppUser friend, String content) async {
    if (content.isEmpty){
      return;
    }
    // Create a Message object with necessary data
    Message message = Message(
      uid: authUser.uid,
      friendUid: friend.uid,
      content: content,
      timestamp: DateTime.now(),
    );

    // Convert the Message object to a map for Firestore
    Map<String, dynamic> messageData = {
      'uid': message.uid,
      // 'friendUid': message.friendUid,
      'content': message.content,
      'timestamp': message.timestamp,
    };

    List<String> ids = [authUser.uid, friend.uid];
    ids.sort();
    String chatId = ids.join('_');
    DocumentReference chatDocRef = firestore.collection('chats').doc(chatId);
    DocumentSnapshot chatDoc = await chatDocRef.get();

    if (chatDoc.exists) {
      // If the document exists, update it by adding the new message
      await chatDocRef.update({
        'messages': FieldValue.arrayUnion([messageData]),
      });
    } else {
      // If the document does not exist, create it with the new message
      await chatDocRef.set({
        'users' : [authUser.uid, friend.uid],
        'messages': [messageData],
      });
    }
  }

  void deleteMessages(AppUser friend) async {
    List<String> ids = [authUser.uid, friend.uid];
    ids.sort();
    String chatId = ids.join('_');

    DocumentReference chatDocRef = firestore.collection('chats').doc(chatId);
    await chatDocRef.delete();
  }

  Future<String?> getUID(String username) async {
    try{
      QuerySnapshot usersSnapshot = await firestore
      .collection('users')
      .where('username', isEqualTo: username)
      .get();

      if (usersSnapshot.docs.isNotEmpty){
        return usersSnapshot.docs.first.id;
      }
    }catch(e){
      debugPrint('Error getUID: $e');
    }
    return null;
  }

  Future<void> setUsername(String username) async {
    try{
      DocumentReference userDocRef = firestore.collection('users').doc(authUser.uid);
      String? someUid = await getUID(username);
      if (someUid == null){
        await userDocRef.set({
          'username': username
        }, SetOptions(merge: true));
        globals.user?.username = username;
      }
    }catch(e){
      debugPrint('Error setUsername: $e');
    }
  }

  Future<void> setProfilePicture(String path) async {
    try{
      String url = '';
      FirebaseStorage storage = FirebaseStorage.instance;

      Reference ref = storage.ref().child("${authUser.uid}/profile/${DateTime.now()}");
      UploadTask uploadTask = ref.putFile(File(path));

      final snapshot = await uploadTask.whenComplete(() {});
      url = await snapshot.ref.getDownloadURL();

      DocumentReference userDocRef = firestore.collection('users').doc(authUser.uid);
      if (url.isNotEmpty){
        await userDocRef.set({
          'image': url
        }, SetOptions(merge: true));
      }
    }catch(e){
      debugPrint('Error setProfilePicture: $e');
    }
  }

  Future<AppUser?> initializeUser() async {
    try{
      if (globals.user == null){
        DocumentReference userDocRef = firestore.collection('users').doc(authUser.uid);
        DocumentSnapshot userDoc = await userDocRef.get();
        if (!userDoc.exists){
          String username = authUser.displayName!.replaceAll(' ', '').toLowerCase().substring(0,8);
          int counter = 1;

          String? someUid = await getUID(username);
          while (someUid != null) {
            username = '$username$counter';
            counter++;
          }

          await userDocRef.set({
            'username': username,
            'email': authUser.email,
            'joined' : FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        await FirestoreService().getUser(authUser.uid);
      }
    }catch(e){
      debugPrint('Error initializeUser: $e');
    }
    return globals.user;
  }

  void signOut() async {
    globals.user = null;
    FirebaseAuth.instance.signOut();
  }

  void deleteAccount() async {
    QuerySnapshot chatsSnapshot = await firestore
      .collection('chats')
      .where('users', arrayContains: authUser.uid)
      .get();

    for (var doc in chatsSnapshot.docs) {
      await doc.reference.delete();
    }

    DocumentReference userDocRef = firestore.collection('users').doc(authUser.uid);
    await userDocRef.delete();

    signOut();
  }
}
