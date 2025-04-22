import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventorylbc/components/color.dart';
import '../../services/api_services.dart';
import '../login_page.dart';

class ImageController extends GetxController {
  Rx<File?> userImage = Rx<File?>(null);
  RxBool isImageChanged = false.obs;

  void setUserImage(File? image) {
    userImage.value = image;
    isImageChanged.value = true;
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  late String _userName = '';
  late String _userEmail = '';
  late String _userPassword = '';
  late String _imageUrl = 'assets/images/profile.jpg';
  late ImageController _imageController;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _imageController = Get.put(ImageController());
  }

  Future<void> _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? 'No Username';
        _userEmail = user.email ?? 'No email';
        _userPassword = '********'; // Muestra asteriscos por seguridad
        _imageUrl = user.photoURL != null && user.photoURL!.isNotEmpty
            ? ApiService.userImages + user.photoURL!.split('/').last
            : 'assets/images/profile.jpg';
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageController.setUserImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage() async {
    final image = _imageController.userImage.value;
    if (image != null) {
      try {
        final imageUrl = await _apiService.uploadUserProfileImage(
          username: _userName,
          email: _userEmail,
          image: image,
        );
        await _auth.currentUser?.updatePhotoURL(imageUrl);
        setState(() {
          _imageUrl = ApiService.userImages + imageUrl.split('/').last;
          _imageController.isImageChanged.value = false;
        });
        print('Imagen subida correctamente: $imageUrl');
      } catch (e) {
        print('Error al subir la imagen: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: orangeColor,
        title: const Text(
          "User Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Stack(
              children: [
                GestureDetector(
                  onTap: _getImageFromGallery,
                  child: Obx(() => CircleAvatar(
                    radius: 120,
                    backgroundImage: _imageController.userImage.value != null
                        ? FileImage(_imageController.userImage.value!)
                        : (_imageUrl.isNotEmpty && _imageUrl.startsWith('http'))
                        ? NetworkImage(_imageUrl)
                        : const AssetImage('assets/images/profile.jpg') as ImageProvider,
                  )),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.black),
                    onPressed: _getImageFromGallery,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            itemProfile('Name', _userName, Icons.person),
            const SizedBox(height: 10),
            itemProfile('Email', _userEmail, Icons.mail),
            const SizedBox(height: 10),
            itemProfile('Contraseña', _userPassword, Icons.lock),
            const SizedBox(height: 20),
            Obx(() {
              return _imageController.isImageChanged.value
                  ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _uploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
                  : Container();
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(() => LoginPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(15),
                ),
                child: Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.deepOrange.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        tileColor: Colors.white,
      ),
    );
  }
}
