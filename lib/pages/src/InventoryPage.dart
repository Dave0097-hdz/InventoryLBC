import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:inventorylbc/controller/pdf_generator.dart';
import 'package:inventorylbc/pages/src/EditEquimentPage.dart';
import 'package:inventorylbc/pages/src/HomePage.dart';
import 'package:inventorylbc/pages/src/ViewEquimentPage.dart';
import 'dart:convert';

import '../../Services/auth.dart';
import '../../components/color.dart';
import '../../services/api_services.dart';
import '../login_page.dart';
import 'PrintViewPage.dart';

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ApiService _apiService = ApiService();

  List<dynamic> _equipos = [];
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadEquipos();
  }

  Future<void> _loadEquipos() async {
    try {
      List<dynamic> equipos = await _apiService.getAllEquipos();
      setState(() {
        _equipos = equipos;
      });
    } catch (e) {
      print('Error cargando equipos: $e');
    }
  }

  Future<void> _deleteEquipo(String id) async {
    try {
      await _apiService.deleteEquipo(id);
      await _loadEquipos();
    } catch (e) {
      print('Error eliminando equipo: $e');
    }
  }

  Future<void> _bajaEquipo(String id) async {
    try {
      final equipo = _equipos.firstWhere((equipo) => equipo['id'] == id);
      if (equipo['estado'] == 'BAJA') {
        Get.snackbar(
          'Error',
          'El equipo ya está dado de baja.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await _apiService.bajaEquipo(id);
      await _loadEquipos();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _searchEquipment(String query) async {
    try {
      List<dynamic> searchResults = await _apiService.searchEquipment(query);
      setState(() {
        _searchResults = searchResults;
        _isSearching = true;
      });
    } catch (e) {
      print('Error al buscar equipos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar equipos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> displayList = _isSearching ? _searchResults : _equipos;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orangeColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20),
            Text(
              "IT Inventory",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.print,
              color: Colors.white,
                size: 30,
              ),
              onPressed: () async{
                await PdfGenerator.generatePdfTodosLosEquipos(_equipos);
            },
          ),
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
          icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Get.offAll(() => HomePage());
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(Icons.search, color: Colors.blue),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _searchEquipment(value);
                    } else {
                      setState(() {
                        _isSearching = false;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: displayList.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith((states) {
                          return Colors.grey.shade200; // Color de sombreado gris
                        }),
                        columns: [
                          DataColumn(
                            label: Center(
                              child: Text(
                                'ID',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                'Nombre',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                'Marca',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                'Modelo',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                'N° Serie',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                'Estado',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                'Acciones',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        rows: displayList
                            .map((equipo) => DataRow(cells: [
                          DataCell(Text(equipo['id'].toString())),
                          DataCell(Text(equipo['nombre'])),
                          DataCell(Text(equipo['marca'])),
                          DataCell(Text(equipo['modelo'])),
                          DataCell(Text(equipo['numeroSerie'])),
                          DataCell(Text(equipo['estado'])),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  Get.to(() => ViewEquipment(equipo: equipo));
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Get.to(() => EditEquipment(equipo: equipo));
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.print),
                                onPressed: () async {
                                  await _apiService.printEquipo(equipo['id'].toString());
                                  Get.to(() => PrintView(equipo: equipo));
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Baja del Equipo'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: const <Widget>[
                                              Icon(
                                                Icons.warning,
                                                color: Colors.orange,
                                                size: 60,
                                              ),
                                              SizedBox(height: 20),
                                              Text('¿Está seguro que desea realizar esta acción?'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Baja'),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await _bajaEquipo(equipo['id'].toString());
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Eliminar'),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await _deleteEquipo(equipo['id'].toString());
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          )),
                        ]))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
