import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventorylbc/Services/auth.dart';
import 'package:inventorylbc/pages/src/InventoryPage.dart';
import 'package:lottie/lottie.dart';
import '../../components/color.dart';
import '../../controller/pdf_generator.dart';
import '../login_page.dart';

class PrintView extends StatefulWidget {
  final dynamic equipo;

  PrintView({Key? key, required this.equipo}) : super(key: key);

  @override
  _PrintViewState createState() => _PrintViewState();
}

class _PrintViewState extends State<PrintView> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  File? _image;
  bool _pdfGenerated = false;

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
              "PDF Generator",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )
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
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Get.offAll(() => InventoryPage());
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Reporte de Inventario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _image != null
                ? Image.file(
              _image!,
              height: 200,
            )
                : Center(
              child: Lottie.asset(
                'assets/animation/pdf.json',
                height: 400,
                width: 400,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await PdfGenerator.generatePdf(widget.equipo);
                setState(() {
                  _pdfGenerated = true;
                });
              },
              child: Text('Generar PDF'),
            ),
            SizedBox(height: 20),
            if (_pdfGenerated)
              ElevatedButton(
                onPressed: () {
                  PdfGenerator.sharePdf(widget.equipo);
                },
                child: Text('Compartir PDF'),
              ),
          ],
        ),
      ),
    );
  }
}
