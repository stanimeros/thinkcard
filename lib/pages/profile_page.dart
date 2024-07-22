import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/common/globals.dart' as globals;
import 'package:thinkcard/common/slide_page_route.dart';
import 'package:thinkcard/pages/profile_edit_page.dart';
import 'package:thinkcard/widgets/profile_picture.dart';
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
            Row(
              children: [
                const SizedBox(width:8),
                ProfilePicture(
                  user: user, 
                  size: 50, 
                  color: globals.textColor, 
                  backgroundColor: globals.cachedImageColor
                ),
                const SizedBox(width: 8),
                Text(
                  '@${user.username}',
                  style: const TextStyle(
                    fontSize: 18
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      SlidePageRoute(page: ProfileEditPage(user: user))
                    );
                  }, 
                  icon: const Icon(
                    size: 22,
                    LucideIcons.pencil
                  )
                )
              ],
            ),
            UserPosts(user: user),
          ],
        )
    );
  }
}