import 'package:flutter/material.dart';
import 'package:thinkcard/common/post.dart';
import 'package:thinkcard/widgets/draggable_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  List<Post> posts = [];
  List<String> reactedIDs = [];

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Feed',
                style: TextStyle(
                  fontSize: 24
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16
          ),
          DraggableCard()
        ],
      ),
    );
  }

  void updatePostsList(){
    
  }
}