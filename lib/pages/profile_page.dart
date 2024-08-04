import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/common/globals.dart' as globals;
import 'package:thinkcard/common/slide_page_route.dart';
import 'package:thinkcard/pages/profile_edit_page.dart';
import 'package:thinkcard/widgets/profile_picture.dart';
import 'package:thinkcard/widgets/user_posts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>{
  late User authUser;
  AppUser user = globals.user!;

  @override
  void initState() {
    authUser = FirebaseAuth.instance.currentUser!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Theme.of(context).textTheme.bodyMedium!.color!, 
                  backgroundColor: Theme.of(context).highlightColor, 
                ),
                const SizedBox(width: 8),
                Text(
                  '@${user.username}',
                  style: const TextStyle(
                    fontSize: 18
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.75),
                  foregroundColor: Theme.of(context).textTheme.bodyMedium!.color!,
                  child: IconButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        SlidePageRoute(page: ProfileEditPage(user: user))
                      ).then((value) async{
                        AppUser? temp = await FirestoreService().getUser(authUser.uid);
                        if (temp != null){
                          setState(() {
                            user = temp;
                          });
                        }
                      });
                    }, 
                    icon: const Icon(
                      size: 20,
                      LucideIcons.pencil
                    )
                  ),
                )
              ],
            ),
            UserPosts(user: user),
          ],
        )
    );
  }
}