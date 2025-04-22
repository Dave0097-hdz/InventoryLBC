import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventorylbc/controller/avatar_controller.dart';
import 'package:inventorylbc/pages/src/AddEquipmentPage.dart';
import 'package:inventorylbc/pages/src/OverviewTabspage.dart';
import 'package:inventorylbc/pages/src/ProfilePage.dart';
import 'package:inventorylbc/services/api_services.dart';
import '../../Services/auth.dart';
import '../../components/color.dart';
import '../../components/constants/ghaps.dart';
import '../../responsive.dart';
import '../login_page.dart';
import 'InventoryPage.dart';
import 'PrintViewPage.dart';
import 'QrPage.dart';
import 'OverviewPage.dart';
import 'ProductOverview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();
  User? user = FirebaseAuth.instance.currentUser;

  late String _userName = '';
  late String _userEmail = '';
  late String _imageUrl = 'assets/images/profile.jpg';
  late AvatarController _avatarController;

  @override
  void initState() {
   super.initState();
   _getCurrentUser();
   _avatarController = Get.put(AvatarController());
  }

  Future<void> _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? 'No Username';
        _userEmail = user.email ?? 'No Email';
        _imageUrl = user.photoURL != null && user.photoURL!.isNotEmpty
          ? ApiService.userImages + user.photoURL!.split('/').last
          : 'assets/images/profile.jpg';
      });
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
              "IT Dashboard",
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
                _firebaseAuthService.signOut().then((_) {
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
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!Responsive.isMobile(context)) gapH24,
            gapH20,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      const Overview(),
                      gapH16,
                      const OverviewTabs(),
                      gapH16,
                      const ProductOverviews(),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Made by: David C.H",
                  style: TextStyle(
                    color: lightTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header of the Drawer
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.to(() => EditProfile());
                },
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: 24,
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/lbc_gallery_gallgrid.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      Get.to(() => EditProfile());
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundImage: _avatarController.userImage.value != null
                              ? FileImage(_avatarController.userImage.value!)
                              : (_imageUrl.isNotEmpty && _imageUrl.startsWith('http'))
                              ? NetworkImage(_imageUrl)
                              : const AssetImage('assets/images/profile.jpg') as ImageProvider,
                        ),
                        SizedBox(height: 10),
                        Text(
                          user != null ? user?.displayName ?? 'Usuario' : 'Usuario',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          user != null ? user?.email ?? 'Correo' : 'Correo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Header Menu Items
            // Menú de items: Parte 1 - Navegación
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Divider(color: Colors.orange[700]),
                  _buildMenuItem(
                    icon: Icons.home_outlined,
                    text: 'Home',
                    onTap: () => Get.to(() => HomePage()),
                  ),
                  _buildMenuItem(
                    icon: Icons.qr_code_scanner,
                    text: 'Serial Number Scanner',
                    onTap: () => Get.to(() => ScanScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.inventory_outlined,
                    text: 'Inventory',
                    onTap: () => Get.to(() => InventoryPage()),
                  ),
                  _buildMenuItem(
                    icon: Icons.save_as_rounded,
                    text: 'Add Equipment',
                    onTap: () => Get.to(() => AddEquipment()),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.orange[700], thickness: 1),
            // Menú de items: Parte 2 - Configuración y Salir
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Divider(color: Colors.orange[700]),
                  _buildMenuItem(
                    icon: Icons.person,
                    text: 'Profile Settings',
                    onTap: () => Get.to(() => EditProfile()),
                  ),
                  _buildMenuItem(
                    icon: Icons.exit_to_app_outlined,
                    text: 'Exit',
                    onTap: () {
                      Navigator.of(context).pop();
                      _firebaseAuthService.signOut().then((_) {
                        Get.offAll(() => LoginPage());
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
      hoverColor: orangeColor, // Color al pasar el puntero o al tocar
      textColor: Colors.black,
      iconColor: Colors.black,
      selectedTileColor: orangeColor, // Color al seleccionar
      selectedColor: Colors.white, // Color del texto al seleccionar
    );
  }
}