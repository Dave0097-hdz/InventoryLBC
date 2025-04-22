import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerView extends StatefulWidget {
  final Function(BarcodeCapture) onDetect;

  ScannerView({required this.onDetect});

  @override
  _ScannerViewState createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escaneando...'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: widget.onDetect,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {'image': null, 'code': null});
                },
                child: Text('Capturar número de serie'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
