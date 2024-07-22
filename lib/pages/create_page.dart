import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreatePage extends StatefulWidget {
  final user = FirebaseAuth.instance.currentUser!;

  CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {

  bool isUploading = false;

  final ImagePicker picker = ImagePicker();
  List<XFile> imageFiles = [];

  final focusNode = FocusNode();
  final TextEditingController titleController = TextEditingController();

  Future<void> pickImages() async {
    if (imageFiles.isEmpty){
      final List<XFile> selectedImages = await picker.pickMultiImage(
        maxHeight: 1920,
        maxWidth: 1080,
        imageQuality: 85,
        limit: 5
      );
      
      if (selectedImages.isNotEmpty) {
        setState(() {
          imageFiles = selectedImages;
        });
      }
    }
  }

  Future<bool> upload() async {
    focusNode.unfocus();
    String title = titleController.text;
    if (imageFiles.isNotEmpty && title.isNotEmpty) {
      FirebaseStorage storage = FirebaseStorage.instance;
      List<String> imagesURLs = [];
      for (var imageFile in imageFiles) {
        Reference ref = storage.ref().child("${widget.user.uid}/${DateTime.now()}");
        UploadTask uploadTask = ref.putFile(File(imageFile.path));

        final snapshot = await uploadTask.whenComplete(() {});
        imagesURLs.add(await snapshot.ref.getDownloadURL());
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'uid': widget.user.uid,
        'title': title,
        'images': imagesURLs,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        imageFiles = [];
        titleController.text = '';
      });

      return true;
    }

    return false;
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
              IconButton(
                onPressed: () async{
                  if (!isUploading){
                    setState(() {
                      isUploading = true;
                    });
                    await upload();
                    setState(() {
                      isUploading = false;
                    });
                  }
                }, 
                icon: const Icon(
                  size: 22,
                  LucideIcons.save
                )
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: pickImages,
          child: Container(
            height: 120.0,
            color: Colors.grey[300],
            child: imageFiles.isEmpty
              ? const Center(child: Text('Tap to select images'))
              : ListView(
                  scrollDirection: Axis.horizontal,
                  children: imageFiles.map((imageFile) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Image.file(
                              File(imageFile.path), 
                              width: 100, 
                              height: 100, 
                              fit: BoxFit.cover
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            width: 100,
                            height: 100,
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  imageFiles.remove(imageFile);
                                });
                              },
                              child: const Icon(
                                size: 25,
                                color: Color.fromARGB(255, 235, 235, 235),
                                LucideIcons.x
                              )
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            focusNode: focusNode,
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
        ),
      ],
    );
  }
}