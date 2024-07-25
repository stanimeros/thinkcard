import 'package:flutter/material.dart';
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/common/post.dart';
import 'package:thinkcard/widgets/draggable_card.dart';
import 'package:thinkcard/widgets/skeleton_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  List<Post> posts = [];
  List<DraggableCard> cards = [];

  @override
  void initState() {
    super.initState();
    updatePostsList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
         const  Row(
            children: [
              Text(
                'Thinkcard',
                style: TextStyle(
                  fontSize: 24
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  const SkeletonCard(),
                  // Stack(
                  //   children: cards
                  // ),
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
    List<Post> tempPosts = await FirestoreService().getUserPosts('VM6CxlTAbOTe2JKoyJDrnfVIegh2');
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

  void dragEvent(Key key, String direction) async {
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