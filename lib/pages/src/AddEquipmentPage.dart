import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../Services/auth.dart';
import '../../components/color.dart';
import '../../services/api_services.dart';
import '../login_page.dart';

class AddEquipment extends StatefulWidget {
  @override
  _AddEquipmentState createState() => _AddEquipmentState();
}

class _AddEquipmentState extends State<AddEquipment> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Equipo registrado correctamente'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 60,
                ),
                SizedBox(height: 20),
                Text('El equipo ha sido registrado correctamente.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Regresar al menú'),
              onPressed: () {
                Navigator.of(context).pop();
                Get.toNamed('/homepage'); // Asegúrate de tener esta ruta configurada
              },
            ),
            TextButton(
              child: const Text('Añadir nuevo equipo'),
              onPressed: () {
                Navigator.of(context).pop();
                // Limpiar los campos para añadir un nuevo equipo
                setState(() {
                  _nameController.clear();
                  _brandController.clear();
                  _modelController.clear();
                  _serialNumberController.clear();
                  _statusController.clear();
                  _imageFile = null;
                });
              },
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
              "Add Equiment",
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingrese los datos del equipo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'Nombre',
                      icon: Icons.drive_file_rename_outline,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _brandController,
                      labelText: 'Marca',
                      icon: Icons.branding_watermark,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _modelController,
                      labelText: 'Modelo',
                      icon: Icons.style,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _serialNumberController,
                      labelText: 'Número de Serie',
                      icon: Icons.confirmation_number,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _statusController,
                      labelText: 'Estado',
                      icon: Icons.info,
                    ),
                    const SizedBox(height: 10),
                    _imageFile == null
                        ? ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Seleccionar imagen'),
                    )
                        : Image.file(
                      _imageFile!,
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: orangeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await _apiService.createEquipo(
                              nombre: _nameController.text,
                              marca: _brandController.text,
                              modelo: _modelController.text,
                              numeroSerie: _serialNumberController.text,
                              estado: _statusController.text,
                              photo: _imageFile!,
                            );
                            await _showSuccessDialog();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al registrar el equipo'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text('Guardar equipo'),
                    ),
                  ],
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
