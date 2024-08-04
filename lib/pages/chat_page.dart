import 'package:flutter/material.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/widgets/messenger.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:thinkcard/widgets/custom_loader.dart';
import 'package:thinkcard/common/globals.dart' as globals;
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/widgets/profile_picture.dart';

class ChatPage extends StatefulWidget {
  final AppUser user;

  const ChatPage({
    super.key,
    required this.user
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>{

  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.75),
                    foregroundColor: Theme.of(context).textTheme.bodyMedium!.color!,
                    child: IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      }, 
                      icon: const Icon(
                        size: 22,
                        LucideIcons.arrowLeft
                      )
                    ),
                  ),
                  const SizedBox(width: 16),
                  ProfilePicture(
                    user: widget.user, 
                    size: 50, 
                    color: Theme.of(context).textTheme.bodyMedium!.color!, 
                    backgroundColor: Theme.of(context).highlightColor
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '@${widget.user.username}',
                    style: const TextStyle(
                      fontSize: 18
                    ),
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirestoreService().getChatSnapshots(widget.user),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var chatData = snapshot.data!.data() as Map<String, dynamic>?;
                      if (chatData != null) {
                        var messages = (chatData['messages'] as List<dynamic>).cast<Map<String, dynamic>>();
                        return ListView(
                          reverse: true,
                          shrinkWrap: true,
                          children: messages.reversed.map<Widget>((message) {
                            bool userMessage = message['uid'] == globals.user!.uid;
                            return ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              title: Row(
                                mainAxisAlignment: userMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: userMessage ? [
                                  Flexible(
                                    child: Text(
                                      message['content'],
                                      textAlign: TextAlign.end,
                                    )
                                  ),
                                  const SizedBox(width: 8),
                                  ProfilePicture(
                                    user: globals.user!,
                                    size: 36,
                                    color: Theme.of(context).textTheme.bodyMedium!.color!, 
                                    backgroundColor: Theme.of(context).highlightColor
                                  ),
                                ]:[
                                  ProfilePicture(
                                    user: widget.user,
                                    size: 36,
                                    color: Theme.of(context).textTheme.bodyMedium!.color!, 
                                    backgroundColor: Theme.of(context).highlightColor
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(message['content'])
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return const Messenger(message: 'No messages to display');
                      }
                    }else{
                      return const CustomLoader();
                    }
                  }
                ),
              ),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () async {
                      FirestoreService().sendMessage(widget.user, messageController.text);
                      messageController.clear();
                    }, 
                    icon: const Icon(
                      size: 24,
                      LucideIcons.send
                    )
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}