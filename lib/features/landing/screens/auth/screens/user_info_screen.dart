import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp_clone/colors.dart';
import 'package:whatapp_clone/common/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatapp_clone/common/widgets/loader.dart';
import 'package:whatapp_clone/features/landing/screens/auth/controller/auth_controller.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  static const routeName = '/user-info';
  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  TextEditingController nameController = TextEditingController();
  XFile? image;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    String name = nameController.text.trim();
    if (name.isNotEmpty) {
      ref
          .read(authControllerProvider.notifier)
          .saveUserDataToFirebase(context, name, image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCreatingAccount = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  image == null
                      ? CircleAvatar(
                          backgroundColor: Colors.green,
                          backgroundImage: NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/219/219988.png',
                          ),
                          radius: 64,
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.green,
                          backgroundImage: FileImage(File(image!.path)),
                          radius: 64,
                        ),
                  Positioned(
                    bottom: -10,
                    right: 10,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: Icon(Icons.add_a_photo, color: Colors.white),
                    ),
                  ),
                ],
              ),

              Container(
                width: size.width * 0.85,
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: "Enter your name"),
                ),
              ),
              GestureDetector(
                onTap: () => storeUserData(),
                child: isCreatingAccount
                    ? const Loader()
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: tabColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Create Account",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
