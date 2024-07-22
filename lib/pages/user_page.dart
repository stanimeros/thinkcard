import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/common/slide_page_route.dart';
import 'package:thinkcard/widgets/chat.dart';
import 'package:thinkcard/widgets/custom_loader.dart';
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/widgets/profile_picture.dart';
import 'package:thinkcard/widgets/user_posts.dart';
import 'package:thinkcard/common/globals.dart' as globals;

class UserPage extends StatefulWidget {
  final AppUser user;

  const UserPage({
    super.key,
    required this.user
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>{
  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<AppUser?>(
            future: FirestoreService().getUser(widget.user.uid),
            builder: (context, userQuery) {
              AppUser? user = userQuery.data;
        
              if (user == null) {
                return const SafeArea(
                  child: CustomLoader()
                );
              }
                        
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        }, 
                        icon: const Icon(
                          size: 22,
                          LucideIcons.arrowLeft
                        )
                      ),
                      ProfilePicture(
                        user: user, 
                        size: 50, 
                        color: globals.textColor, 
                        backgroundColor: globals.cachedImageColor
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.username
                      ),
                      const Spacer(),
                      IconButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        SlidePageRoute(page: Chat(friend: widget.user))
                      );
                    }, 
                    icon: const Icon(
                      size: 22,
                      LucideIcons.messageCircle
                    )
                  ),
                    ],
                  ),
                  UserPosts(user: user)
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}