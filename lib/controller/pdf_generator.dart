import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class PdfGenerator {
  // Función para generar PDF de un equipo específico
  static Future<void> generatePdf(Map<String, dynamic> equipo) async {
    final pdf = await _createPdfDocument(equipo);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Nueva función para generar PDF de todos los equipos
  static Future<void> generatePdfTodosLosEquipos(List<dynamic> equipos) async {
    final pdf = await _createPdfDocumentTodosLosEquipos(equipos);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> savePdf(Map<String, dynamic> equipo) async {
    final pdf = await _createPdfDocument(equipo);

    final output = await getExternalStorageDirectory();
    final file = File('${output?.path}/reporte_inventario.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  static Future<void> sharePdf(Map<String, dynamic> equipo) async {
    final pdf = await _createPdfDocument(equipo);

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'reporte_inventario.pdf');
  }

  static Future<pw.Document> _createPdfDocument(Map<String, dynamic> equipo) async {
    final pdf = pw.Document();
    final User? user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Nombre del Usuario';

    // URL de la imagen en tu servidor
    final imageUrl = 'http://192.168.1.19:8080/api/uploads/${equipo['photo']}';

    // Descargar la imagen
    final imageResponse = await http.get(Uri.parse(imageUrl));
    final image = pw.MemoryImage(imageResponse.bodyBytes);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('THE PALACE COMPANY®', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 5),
                pw.Text('Reporte de Inventario', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Ubicación: Blvd. Kukulcan, Punta Cancun, Zona Hotelera, 77550 Cancún, Q.R.'),
          pw.Text('Fecha: ${DateTime.now().toLocal().toString().split(' ')[0]}'),
          pw.Text('Departamento: Sistemas'),
          pw.SizedBox(height: 20),
          pw.Text('Detalles del equipo', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Nombre', 'Marca', 'Modelo', 'Estado', 'N° Serie', 'Imagen'],
            data: [
              [
                equipo['nombre'],
                equipo['marca'],
                equipo['modelo'],
                equipo['estado'],
                equipo['numeroSerie'],
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Image(image, width: 50, height: 50),
                ),
              ]
            ],
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.center,
            cellAlignments: {4: pw.Alignment.center}, // Centrar la celda de la imagen
          ),
          pw.Spacer(),
          pw.Center(child: pw.Text('Atentamente:')),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Container(
              width: 150, // Reducir el ancho de la línea
              height: 1,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text(userName)),
        ],
      ),
    );

    return pdf;
  }

  static Future<pw.Document> _createPdfDocumentTodosLosEquipos(List<dynamic> equipos) async {
    final pdf = pw.Document();
    final User? user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Nombre del Usuario';

    final List<List<dynamic>> data = [];

    for (var equipo in equipos) {
      final imageUrl = 'http://192.168.1.19:8080/api/uploads/${equipo['photo']}';
      final imageResponse = await http.get(Uri.parse(imageUrl));
      final image = pw.MemoryImage(imageResponse.bodyBytes);

      data.add([
        equipo['nombre'],
        equipo['marca'],
        equipo['modelo'],
        equipo['estado'],
        equipo['numeroSerie'],
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Image(image, width: 50, height: 50),
        ),
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('THE PALACE COMPANY®', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 5),
                pw.Text('Reporte de Inventario', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Ubicación: Blvd. Kukulcan, Punta Cancun, Zona Hotelera, 77550 Cancún, Q.R.'),
          pw.Text('Fecha: ${DateTime.now().toLocal().toString().split(' ')[0]}'),
          pw.Text('Departamento: Sistemas'),
          pw.SizedBox(height: 20),
          pw.Text('Detalles de los equipos', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Nombre', 'Marca', 'Modelo', 'Estado', 'N° Serie', 'Imagen'],
            data: data,
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.center,
          ),
          pw.Spacer(),
          pw.Center(child: pw.Text('Atentamente:')),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Container(
              width: 150, // Reducir el ancho de la línea
              height: 1,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text(userName)),
        ],
      ),
    );

    return pdf;
  }
}
