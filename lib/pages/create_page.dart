import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:thinkcard/widgets/custom_loader.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {

  late User authUser;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;

  bool isUploading = false;
  List<XFile> imageFiles = [];
  ImagePicker picker = ImagePicker();

  FocusNode titleFocusNode = FocusNode();
  FocusNode descFocusNode = FocusNode();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  Future<void> pickImages() async {
    final List<XFile> selectedImages = await picker.pickMultiImage(
      maxHeight: 1920,
      maxWidth: 1080,
      imageQuality: 85,
      limit: 4,
    );
    
    if (selectedImages.isNotEmpty) {
      setState(() {
        imageFiles.addAll(selectedImages);
      });
    }
  }

  Future<void> upload() async {
    if (imageFiles.isNotEmpty && !isUploading && titleController.text.isNotEmpty) {
      setState(() {
        isUploading = true;
      });

      DocumentReference docRef = firestore.collection('posts').doc();

      List<String> imagesURLs = [];
      while (imageFiles.isNotEmpty) {
        XFile imageFile = imageFiles.first;
        Reference ref = storage.ref().child("${authUser.uid}/${docRef.id}/${DateTime.now()}");
        UploadTask uploadTask = ref.putFile(File(imageFile.path));

        final snapshot = await uploadTask.whenComplete(() {});
        imagesURLs.add(await snapshot.ref.getDownloadURL());

        setState(() {
          imageFiles.removeAt(0);
        });
      }

      docRef.set({
        'uid': authUser.uid,
        'title': titleController.text,
        'description' : descController.text,
        'images': FieldValue.arrayUnion(imagesURLs),
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        imageFiles = [];
        isUploading = false;
      });

      titleController.clear();
      descController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    authUser = FirebaseAuth.instance.currentUser!;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Create',
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
                    upload();
                  }, 
                  icon: isUploading ?
                  const CustomLoader()
                  : const Icon(
                    size: 20,
                    LucideIcons.uploadCloud
                  )
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            focusNode: titleFocusNode,
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            maxLines: 2,
            maxLength: 60,
            focusNode: descFocusNode,
            controller: descController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: pickImages,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.transparent,
              child: imageFiles.isEmpty
              ? const Center(child: Text('Tap to select images'))
              : GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: imageFiles.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Image.file(
                          File(imageFiles[index].path), 
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: isUploading ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          color: Theme.of(context).highlightColor,
                          child: const CustomLoader()
                        )
                      ),
                      Visibility(
                        visible: !isUploading,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                imageFiles.removeAt(index);
                              });
                            },
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              child: const Icon(
                                size: 18,
                                LucideIcons.x
                              ),
                            )
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        )
      ],
    );
  }
}