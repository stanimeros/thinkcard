import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/common/post.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:thinkcard/widgets/popup.dart';
import 'package:thinkcard/widgets/profile_picture.dart';
import 'package:thinkcard/widgets/skeleton_card.dart';
import 'package:thinkcard/common/globals.dart' as globals;

class PostPage extends StatefulWidget {
  final Post post;
  final AppUser user;
  final authUser = FirebaseAuth.instance.currentUser!;

  PostPage({
    super.key,
    required this.post,
    required this.user,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  int page = 0;
  PageController photoController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.sizeOf(context).width;

    return Hero(
      tag: 'post-${widget.post.id}',
      child: Scaffold(
        body: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              PageView.builder(
                itemCount: widget.post.images.length,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                controller: photoController,
                onPageChanged: (index) {
                  page = index;
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTapUp: (details) {
                       if (details.globalPosition.dx > sWidth / 2){
                        if (page < widget.post.images.length - 1){
                          setState(() {
                            photoController.jumpToPage(page + 1);
                          });
                        }
                      }else{
                        if (page > 0){
                          setState(() {
                            photoController.jumpToPage(page - 1);
                          });
                        }
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        fadeInDuration: Duration.zero,
                        cacheKey: widget.post.images[index],
                        imageUrl: widget.post.images[index],
                        placeholder: (context, url) => const SkeletonCard()
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            }, 
                            icon: const Icon(
                              size: 26,
                              color: Colors.white,
                              LucideIcons.arrowLeft
                            )
                          ),
                          const Spacer(),
                          Visibility(
                            visible: widget.post.images.length > 1,
                            child: AnimatedSmoothIndicator(
                              activeIndex: page,
                              count: widget.post.images.length,
                              effect: const ExpandingDotsEffect(
                                dotHeight: 6,
                                dotWidth: 24,
                                radius: 4,
                                spacing: 8,
                                activeDotColor: Colors.white
                              ),
                            ),
                          ),
                          const Spacer(),
                          Visibility(
                            maintainSize: true,
                            maintainState: true,
                            maintainAnimation: true,
                            visible: widget.user.uid == widget.authUser.uid,
                            child: IconButton(
                              onPressed:(){
                                AlertDialog popUp = PopUp(
                                  funBtn1: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    FirestoreService().deletePost(widget.post);
                                  },
                                  funBtn2: () {
                                    Navigator.pop(context);
                                  },
                                );

                                showDialog(
                                  context: context, 
                                  builder: (BuildContext context) {
                                    return popUp;
                                  }
                                );
                              }, 
                              icon: const Icon(
                                size: 26,
                                color: Colors.white,
                                LucideIcons.trash
                              )
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context).scaffoldBackgroundColor
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  size: 18,
                                  color:Colors.black,
                                  LucideIcons.heartCrack
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${widget.post.dislikes}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: globals.skeletonDarkColor
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${widget.post.likes}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  size: 18,
                                  color:Colors.white,
                                  LucideIcons.heart
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ProfilePicture(
                                user: widget.user, 
                                size: 36,
                                color: Theme.of(context).textTheme.bodyMedium!.color!, 
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                '@${widget.user.username}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.post.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 30
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 200)
              )
            ],
          ),
        ),
      ),
    );
  }
}