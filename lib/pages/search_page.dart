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
  SearchPage({super.key});
  final user = FirebaseAuth.instance.currentUser!;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  bool isLoading = false;
  FocusNode focusNode = FocusNode();
  TextEditingController searchController = TextEditingController();

  List<AppUser> results = [];

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
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: results.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(page: UserPage(user: results[index]))
                      );
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          ProfilePicture(user: results[index], size: 48, color: Colors.white, backgroundColor:const Color.fromARGB(255, 180, 180, 180)),
                          const SizedBox(width: 8),
                          Text(
                            '@${results[index].username}',
                            style: const TextStyle(
                              fontSize: 18
                            ),
                          ),
                        ],
                      ),
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