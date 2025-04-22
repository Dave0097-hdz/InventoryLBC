import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Services/auth.dart';
import '../../components/color.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../controller/image_controller.dart';
import '../login_page.dart';

class ViewEquipment extends StatefulWidget {
  final dynamic equipo;

  const ViewEquipment({Key? key, required this.equipo}) : super(key: key);

  @override
  _ViewEquipmentState createState() => _ViewEquipmentState();
}

class _ViewEquipmentState extends State<ViewEquipment> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  late EquipmentImageController _imageController;

  @override
  void initState() {
    super.initState();
    _imageController = Get.put(EquipmentImageController());
    _loadEquipmentImage();
  }

  Future<void> _loadEquipmentImage() async {
    if (widget.equipo['photo'] != null) {
      await _imageController.loadEquipmentImage(
          'http://192.168.1.19:8080/api/uploads/${widget.equipo['photo']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: orangeColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20),
            Text(
              "View Equipment",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
            onSelected: (value) {
              if (value == 'Configuración') {
                Get.toNamed("/edit-profile");
              } else if (value == 'Cerrar sesión') {
                _authService.signOut().then((_) {
                  Get.offAll(() => LoginPage());
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Configuración', 'Cerrar sesión'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Stack(
              children: [
                Obx(() => CircleAvatar(
                  radius: 120,
                  backgroundImage: _imageController.equipmentImage.value != null
                      ? FileImage(_imageController.equipmentImage.value!)
                      : (_imageController.imageUrl.value != null
                      ? NetworkImage(_imageController.imageUrl.value!)
                      : const AssetImage('assets/images/no_image.png') as ImageProvider),
                )),
              ],
            ),
            const SizedBox(height: 20),
            itemProfile('Nombre', widget.equipo['nombre'], Icons.drive_file_rename_outline),
            const SizedBox(height: 10),
            itemProfile('Marca', widget.equipo['marca'], Icons.branding_watermark),
            const SizedBox(height: 10),
            itemProfile('Modelo', widget.equipo['modelo'], Icons.style),
            const SizedBox(height: 10),
            itemProfile('Número de Serie', widget.equipo['numeroSerie'], Icons.confirmation_number),
            const SizedBox(height: 10),
            itemProfile('Estado', widget.equipo['estado'], Icons.info_outline),
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
