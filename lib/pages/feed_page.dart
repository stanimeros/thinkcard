import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/common/post.dart';
import 'package:thinkcard/common/theme_provider.dart';
import 'package:thinkcard/widgets/draggable_card.dart';
import 'package:thinkcard/widgets/skeleton_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with AutomaticKeepAliveClientMixin{

  List<Post> posts = [];
  List<DraggableCard> cards = [];

  @override
  void initState() {
    super.initState();
    updatePostsList();
  }
    
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Thinkcard',
                style: TextStyle(
                  fontSize: 24
                ),
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.75),
                foregroundColor: Theme.of(context).textTheme.bodyMedium!.color!,
                child: IconButton(
                  splashColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.75),
                  onPressed: () {
                    setState(() {
                      themeProvider.setThemeMode(
                        themeProvider.themeMode == ThemeMode.dark ?
                        ThemeMode.light : ThemeMode.dark
                      );
                    });
                  }, 
                  icon: Icon(
                    size: 20,
                    themeProvider.themeMode == ThemeMode.dark ?
                    LucideIcons.sun : LucideIcons.moon
                  )
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  const SkeletonCard(),
                  Stack(
                    children: cards
                  ),
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  void updatePostsList() async {
    List<DraggableCard> tempCards = [];
    List<Post> tempPosts = await FirestoreService().getRandomPosts();
    for (var post in tempPosts) {
      if (!posts.any((exPost) => exPost.uid == post.uid)) {
        tempCards.add( DraggableCard (
          key: UniqueKey(),
          post: post,
          dragEvent: dragEvent
        ));
      }
    }
    setState((){
      posts.insertAll(0, tempPosts);
      cards.insertAll(0, tempCards);  
    });
  }

  void dragEvent(Key key, Post post, String direction) async {
    FirestoreService().incrementPostReaction(post.id, direction == 'Right');

    int indexToRemove = cards.indexWhere((c) => c.key == key);
    if (indexToRemove != -1 && indexToRemove < cards.length - 1) {
      setState(() {
        cards.removeRange(indexToRemove + 1, cards.length);
      });
    }

    if (cards.length <= 2) {
      updatePostsList();
    }
  }
}