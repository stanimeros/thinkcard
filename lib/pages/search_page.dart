import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/common/slide_page_route.dart';
import 'package:thinkcard/pages/user_page.dart';
import 'package:thinkcard/widgets/profile_picture.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late User authUser;
  bool isLoading = false;
  
  List<AppUser> results = [];
  FocusNode focusNode = FocusNode();
  TextEditingController searchController = TextEditingController();

  Future<void> search(String query) async{
    List<AppUser> queryResults = [];
    if (query.length >3 && query.length<13){
      queryResults = await FirestoreService().searchUsers(query);
    }

    setState(() {
      results = queryResults;
    });
  }

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
        children: [
          TextField(
            focusNode: focusNode,
            controller: searchController,
            onChanged: (value) async {
              value = value.toLowerCase().trim();

              setState(() {
                isLoading = true;
              });

              await search(value);

              setState(() {
                isLoading = false;
              });
            },
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Type a username ..',
              prefixIcon: const Icon(
                LucideIcons.search,
              ),
              suffixIcon: isLoading ?
                const Icon(
                  size: 22,
                  LucideIcons.loader,
                ).animate(
                  onComplete: (controller) {
                    controller.repeat();
                  },
                ).rotate(
                  duration: const Duration(seconds: 2)
                ) 
                : GestureDetector(
                onTap: () {
                  focusNode.unfocus();
                  searchController.clear();
                },
                child: const Icon(
                  size: 22,
                  LucideIcons.x
                ),
              ),
            )
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: results.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.75),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),              
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    onTap: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(page: UserPage(user: results[index]))
                      );
                    },
                    leading: ProfilePicture(
                      user: results[index], 
                      size: 42, 
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                      backgroundColor: Theme.of(context).highlightColor
                    ),
                    title: Row(
                      children: [
                        Text(
                          '@${results[index].username}',
                          style: const TextStyle(
                            fontSize: 18
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}