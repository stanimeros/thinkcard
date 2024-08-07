import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/common/slide_page_route.dart';
import 'package:thinkcard/pages/post_page.dart';
import 'package:thinkcard/widgets/custom_loader.dart';
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/common/post.dart';

class UserPosts extends StatefulWidget {
  final AppUser user;
  final User authUser = FirebaseAuth.instance.currentUser!;

  UserPosts({super.key, required this.user});

  @override
  State<UserPosts> createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: FirestoreService().getUserPosts(widget.user.uid),
      builder: (context, postsQuery) {
        List<Post>? posts = postsQuery.data;

        if (posts == null) {
          return const CustomLoader();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: CustomMaterialIndicator(
            onRefresh: () async {
              List<Post> fetchedPosts =
                  await FirestoreService().getUserPosts(widget.user.uid);
              setState(() {
                posts = fetchedPosts;
              });
            },
            indicatorBuilder: (context, controller) {
              return const Icon(
                LucideIcons.loader,
                size: 20,
              );
            },
            child: posts.isEmpty ?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    widget.authUser.uid == widget.user.uid
                        ? 'It looks like you haven\'t posted anything yet. Tap \'Create\' to share your photos!'
                        : 'No posts yet',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ) : GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of items per row
                crossAxisSpacing: 8.0, // Spacing between columns
                mainAxisSpacing: 8.0, // Spacing between rows
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(page: PostPage(post: posts![index], user: widget.user))
                    ).then((value) async {
                      List<Post> fetchedPosts = await FirestoreService().getUserPosts(widget.user.uid);
                      setState(() {
                        posts = fetchedPosts;
                      });
                    });
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5)),
                    child: Hero(
                      tag: 'post-${posts![index].id}',
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: posts![index].images[0],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
