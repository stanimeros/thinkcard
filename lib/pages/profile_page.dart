import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/common/globals.dart' as globals;
import 'package:thinkcard/widgets/user_posts.dart';

class ProfilePage extends StatefulWidget {
  final authUser = FirebaseAuth.instance.currentUser!;

  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin{
  AppUser user = globals.user!;

  @override
  bool get wantKeepAlive => true;

  void refreshState(){
    setState(() {
      user = globals.user!;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserPosts(user: user),
          ],
        )
    );
  }
}