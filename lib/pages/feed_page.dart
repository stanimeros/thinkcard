import 'package:flutter/material.dart';
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/common/post.dart';
import 'package:thinkcard/widgets/draggable_card.dart';
import 'package:thinkcard/common/globals.dart' as globals;

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  List<Post> posts = [];
  List<String> reactedIDs = [];

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
            child: Stack(
              children: posts.asMap().entries.map((entry) {
                return DraggableCard(post: entry.value, dragEvent: dragEvent,);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  void updatePostsList() async {
    List<Post> list =  await FirestoreService().getUserPosts(globals.user!.uid);
    setState((){
      posts.insertAll(0, list);
    });
  }

  void dragEvent(Post post, String direction) async {
    setState(() {
      reactedIDs.add(post.uid);
      
      if (posts.indexOf(post) < posts.length - 1){
        posts.removeRange(posts.indexOf(post) + 1, posts.length);
        debugPrint(posts.length.toString());

        if (posts.length <= 1){
          updatePostsList();
        }
      }
    });
  }
}