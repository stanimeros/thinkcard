import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:thinkcard/bars/bottom_nav_bar.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/common/custom_theme.dart';
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/firebase_options.dart';
import 'package:thinkcard/pages/chats_page.dart';
import 'package:thinkcard/pages/feed_page.dart';
import 'package:thinkcard/pages/login_page.dart';
import 'package:thinkcard/pages/profile_page.dart';
import 'package:thinkcard/widgets/custom_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CustomTheme.themeData,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          if (snapshot.hasData){
            return FutureBuilder(
              future: FirestoreService().initializeUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData){
                  AppUser? user = snapshot.data;
                  if (user != null){
                    return Scaffold(
                      resizeToAvoidBottomInset: false,
                      extendBodyBehindAppBar: false,
                      bottomNavigationBar: BottomNavBar(changePage: changePage),
                      body: SafeArea(
                        child: PageView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: pageController,
                          children: [
                            const FeedPage(),
                            ChatsPage(),
                            ProfilePage()
                          ],
                        ),
                      )
                    );
                  }
                  return const LoginPage();
                }
                return const Scaffold(
                  body: CustomLoader()
                );
              }
            );
          }else{
            return const LoginPage();
          }
        }
      )
    );
  }

  void changePage(index) {
    setState(() {
      pageController.jumpToPage(index);
    });
  }
}
