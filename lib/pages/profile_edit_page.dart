import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:thinkcard/common/app_user.dart';
import 'package:thinkcard/common/firestore_service.dart';
import 'package:thinkcard/widgets/custom_loader.dart';
import 'package:thinkcard/widgets/popup.dart';
import 'package:thinkcard/widgets/profile_picture.dart';

class ProfileEditPage extends StatefulWidget {
  final AppUser user;
  final authUser = FirebaseAuth.instance.currentUser!;

  ProfileEditPage({
    super.key,
    required this.user
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {

  bool isSaving = false;

  XFile? newProfilePicture;
  final ImagePicker picker = ImagePicker();

  bool invalid = false;
  FocusNode nameFocusNode = FocusNode();
  FocusNode descFocusNode = FocusNode();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController joinedController = TextEditingController();

  Future<void> pickImage() async {
    final XFile? selectedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
    );
    
    setState(() {
      newProfilePicture = selectedImage;
    });
  }

  Future<void> saveChanges() async{
    String newUsername = nameController.text.trim().toLowerCase();

    if (!invalid){
      if (widget.user.username != newUsername){
        await FirestoreService().setUsername(newUsername);
      }

      if (widget.user.description != descController.text){
        await FirestoreService().setDescription(descController.text);
      }

      if (newProfilePicture != null){
        await FirestoreService().setProfilePicture(newProfilePicture!.path);
      }

      if (mounted){
        Navigator.pop(context);
      }
    }
  }

  String? usernameError(String value) {
    if (value.length < 4){
      return "Username should contain at least 4 characters";
    }else if (value.length > 10){
      return "Username should not contain more than 10 characters";
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    String dateJoined = 
      '${widget.user.joined!.day.toString().padLeft(2,'0')}/${widget.user.joined!.month.toString().padLeft(2,'0')}/${widget.user.joined!.year}';
    nameController = TextEditingController(text: widget.user.username);
    descController = TextEditingController(text: widget.user.description);
    emailController = TextEditingController(text: widget.user.email);
    joinedController = TextEditingController(text: dateJoined);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                  const Spacer(),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 24
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.75),
                    foregroundColor: Theme.of(context).textTheme.bodyMedium!.color!,
                    child: IconButton(
                      onPressed: () async{
                        if (!isSaving){
                          setState(() {
                            isSaving = true;
                          });
                    
                          await saveChanges();
                    
                          setState(() {
                            isSaving = false;
                          });
                        }
                      }, 
                      icon: isSaving ?
                        const CustomLoader()
                        : const Icon(
                        size: 20,
                        LucideIcons.save
                      )
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle
                      ),
                      alignment: Alignment.center,
                      child: newProfilePicture != null ?
                      Image.file(
                        width: 85,
                        height: 85,
                        fit: BoxFit.cover,
                        File(newProfilePicture!.path)
                      ) : ProfilePicture(
                        user: widget.user,
                        size: 85,
                        color: Theme.of(context).textTheme.bodyMedium!.color!,
                        backgroundColor: Theme.of(context).highlightColor

                      )
                    ),
                  ),
                  const SizedBox(height: 8,),
                  const Text('Profile picture')
                ],
              ),
              const SizedBox(height: 30),
              TextField(
                focusNode: nameFocusNode,
                controller: nameController,
                onEditingComplete: () {
                  setState(() {
                    invalid = usernameError(nameController.text) != null;
                  });
                  nameFocusNode.unfocus();
                },
                onTapOutside: (event) {
                  setState(() {
                    invalid = usernameError(nameController.text) != null;
                  });
                  nameFocusNode.unfocus();
                },
                decoration: InputDecoration(
                  labelText: 'Username',
                  errorText: invalid ? usernameError(nameController.text) : null,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                focusNode: descFocusNode,
                controller: descController,
                onEditingComplete: () {
                  descFocusNode.unfocus();
                },
                onTapOutside: (event) {
                  descFocusNode.unfocus();
                },
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                readOnly: true,
                enableInteractiveSelection: false,
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                readOnly: true,
                enableInteractiveSelection: false,
                controller: joinedController,
                decoration: const InputDecoration(
                  labelText: 'Joined',
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: ElevatedButton(
                  onPressed: () async {
                    AlertDialog popUp = PopUp(
                      funBtn1: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        FirestoreService().signOut();
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign out',
                      ),
                      SizedBox(width: 8),
                      Icon(
                        size: 18,
                        LucideIcons.logOut
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: ElevatedButton(
                  onPressed: () async {
                    AlertDialog popUp = PopUp(
                      funBtn1: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        FirestoreService().deleteAccount();
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Delete your account',
                      ),
                      SizedBox(width: 8),
                      Icon(
                        size: 18,
                        LucideIcons.delete
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}