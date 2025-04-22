import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventorylbc/pages/src/InventoryPage.dart';
import '../../services/auth.dart';
import '../../components/color.dart';
import '../../services/api_services.dart';
import 'package:lottie/lottie.dart';
import '../login_page.dart'; // Asegúrate de añadir esta dependencia en pubspec.yaml

class EditEquipment extends StatefulWidget {
  final dynamic equipo;

  const EditEquipment({Key? key, required this.equipo}) : super(key: key);

  @override
  _EditEquipmentState createState() => _EditEquipmentState();
}

class _EditEquipmentState extends State<EditEquipment> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _numeroSerieController;
  late String _estadoController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.equipo['nombre']);
    _marcaController = TextEditingController(text: widget.equipo['marca']);
    _modeloController = TextEditingController(text: widget.equipo['modelo']);
    _numeroSerieController = TextEditingController(text: widget.equipo['numeroSerie']);
    _estadoController = widget.equipo['estado'];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _numeroSerieController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _updateEquipment() async {
    if (_formKey.currentState!.validate()) {
      try {
        String response = await apiService.updateEquipo(
          id: widget.equipo['id'].toString(),
          nombre: _nombreController.text,
          marca: _marcaController.text,
          modelo: _modeloController.text,
          numeroSerie: _numeroSerieController.text,
          estado: _estadoController,
          photo: _selectedImage,
        );

        print('Update response: $response');
        _showSuccessDialog(response);
      } catch (e) {
        print('Failed to update equipo: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update equipo: $e')),
        );
      }
    }
  }

  void _showSuccessDialog(String response) {
    var decodedResoponse = jsonDecode(response);
    var status = decodedResoponse['status'];
    var message = decodedResoponse['message'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Éxito'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animation/success.json', // Ruta al archivo Lottie (asegúrate de añadirlo a tus assets)
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                status == 'success'
                    ? "Equipo Actualizado Correctamente"
                    : "Ocurrio un error al actualizar el equipo",
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.off(InventoryPage());
              },
              child: Text('Return'),
            ),
          ],
        );
      },
    );
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
              "Edit Equipment",
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 10),
              _buildTextField(
                controller: _nombreController,
                labelText: 'Nombre',
                icon: Icons.drive_file_rename_outline,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _marcaController,
                labelText: 'Marca',
                icon: Icons.branding_watermark,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _modeloController,
                labelText: 'Modelo',
                icon: Icons.style,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _numeroSerieController,
                labelText: 'Número de Serie',
                icon: Icons.confirmation_number,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _estadoController,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'ALTA',
                    child: Text('ALTA'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'BAJA',
                    child: Text('BAJA'),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _estadoController = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona el estado';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _selectedImage != null
                  ? Image.file(_selectedImage!)
                  : widget.equipo['photo'] != null
                  ? Image.network('http://192.168.1.19:8080/api/uploads/${widget.equipo['photo']}')
                  : Text('No image selected.'),
              TextButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Text('Seleccionar Imagen'),
              ),
              ElevatedButton(
                onPressed: _updateEquipment,
                child: Text('Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese $labelText';
        }
        return null;
      },
    );
  }
}
