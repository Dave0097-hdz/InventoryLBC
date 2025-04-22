import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import '../../Services/auth.dart';
import '../../components/color.dart';
import '../login_page.dart';
import 'HomePage.dart';
import 'ResulScannerPage.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  String _scanResult = "No se ha escaneado nada";
  final ImagePicker _picker = ImagePicker();
  File? _image;

  void _onDetect(BarcodeCapture capture) {
    final String code = capture.barcodes.first.rawValue ?? 'Desconocido';
    setState(() {
      _scanResult = code;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      _processImage(File(image.path));
    }
  }

  Future<void> _processImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
    final barcodes = await barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? 'Desconocido';
      setState(() {
        _scanResult = code;
      });
      Navigator.pushNamed(context, '/result', arguments: {'image': _image, 'code': code});
    } else {
      setState(() {
        _scanResult = 'No se detectó ningún código de barras';
      });
    }

    await barcodeScanner.close();
  }

  void _navigateToResult() {
    Navigator.pushNamed(context, '/result', arguments: {'image': _image, 'code': _scanResult});
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
              "Scanner Page",
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
            Get.offAll(() => HomePage());
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Image.file(
              _image!,
              height: 200,
            )
                : Lottie.asset(
              'assets/animation/scanner.json',
              height: 400,
              width: 400,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ScannerView(onDetect: _onDetect)),
                );
              },
              child: Text('Escanear'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: Text('Escanear desde galería'),
            ),
            SizedBox(height: 20),
            Text(
              'Resultado del escaneo: $_scanResult',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            if (_scanResult != "No se ha escaneado nada")
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _scanResult));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Número de serie copiado al portapapeles')),
                  );
                },
                child: Text('Copiar número de serie'),
              ),
          ],
        ),
      ),
    );
  }
}
