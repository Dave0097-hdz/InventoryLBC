import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:inventorylbc/Services/auth.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.34.102:8080/api/';
  static const String userImages = 'http://192.168.34.102:8080/api/user_images/';

  final FirebaseAuthService _authService = FirebaseAuthService();
  User? user = FirebaseAuth.instance.currentUser;

  // Ver equipos
  Future<List<dynamic>> getAllEquipos() async {
    final response = await http.get(Uri.parse(baseUrl + 'api_services.php?action=get_all_equipos'));

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        print('Failed to decode JSON: $e');
        print('Response body: ${response.body}');
        throw Exception('Failed to decode JSON');
      }
    } else {
      print('Failed to load equipos: ${response.statusCode}');
      throw Exception('Failed to load equipos');
    }
  }

  // Buscar equipos
  Future<List<dynamic>> searchEquipment(String query) async {
    final response = await http.get(Uri.parse(baseUrl + 'api_services.php?action=search&query=$query'));

    if (response.statusCode == 200) {
      List<dynamic> equipos = json.decode(response.body);
      return equipos;
    } else {
      throw Exception('No se encontraron equipos');
    }
  }

  //Metodo para subir la imagen del Usuario
  Future<String> uploadUserProfileImage({
    required String username,
    required String email,
    required File image,
  }) async {
    var uri = Uri.parse(baseUrl + 'upload_user_image.php');
    var request = http.MultipartRequest('POST', uri);
    request.fields['username'] = username;
    request.fields['email'] = email;

    // Determinar el tipo MIME de la imagen
    final mimeType = lookupMimeType(image.path) ?? 'application/octet-stream';
    final mimeTypeList = mimeType.split('/');

    // Crear el archivo MultipartFile
    var multipartFile = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(mimeTypeList[0], mimeTypeList[1]),
    );

    request.files.add(multipartFile);
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);
      if (jsonResponse['status'] == 'success') {
        return jsonResponse['imageUrl'];
      } else {
        throw Exception('Failed to upload user image: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to upload user image');
    }
  }

  // Crear eqipos
  Future<String> createEquipo({
    required String nombre,
    required String marca,
    required String modelo,
    required String numeroSerie,
    required String estado,
    required File photo,
  }) async {
    var uri = Uri.parse(baseUrl + 'create_equipo.php');
    var request = http.MultipartRequest('POST', uri);
    request.fields['nombre'] = nombre;
    request.fields['marca'] = marca;
    request.fields['modelo'] = modelo;
    request.fields['numeroSerie'] = numeroSerie;
    request.fields['estado'] = estado;

    // Determinar el tipo MIME de la imagen
    final mimeType = lookupMimeType(photo.path) ?? 'application/octet-stream';
    final mimeTypeList = mimeType.split('/');

    // Crear el archivo MultipartFile
    var multipartFile = await http.MultipartFile.fromPath(
      'photo',
      photo.path,
      contentType: MediaType(mimeTypeList[0], mimeTypeList[1]),
    );

    request.files.add(multipartFile);
    var response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      throw Exception('Failed to create equipo');
    }
  }

  // Actualizar un equipo
  Future<String> updateEquipo({
    required String id,
    required String nombre,
    required String marca,
    required String modelo,
    required String numeroSerie,
    required String estado,
    File? photo,
  }) async {
    var uri = Uri.parse(baseUrl + 'update_equipo.php');
    var request = http.MultipartRequest('POST', uri);
    request.fields['id'] = id;
    request.fields['nombre'] = nombre;
    request.fields['marca'] = marca;
    request.fields['modelo'] = modelo;
    request.fields['numeroSerie'] = numeroSerie;
    request.fields['estado'] = estado;

    if (photo != null) {
      final mimeType = lookupMimeType(photo.path) ?? 'application/octet-stream';
      final mimeTypeList = mimeType.split('/');

      var multipartFile = await http.MultipartFile.fromPath(
        'photo',
        photo.path,
        contentType: MediaType(mimeTypeList[0], mimeTypeList[1]),
      );

      request.files.add(multipartFile);
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      throw Exception('Failed to update equipo');
    }
  }

  // Eliminar un equipo
  Future<String> deleteEquipo(String id) async {
    final response = await http.post(
      Uri.parse(baseUrl + 'api_services.php?action=delete_equipo'),
      body: {'id': id},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to delete equipo');
    }
  }

  //Baja de un equipo
  Future<String> bajaEquipo(String id) async {
    final response = await http.post(
      Uri.parse(baseUrl + 'api_services.php?action=baja_equipo'),
      body: {'id': id},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to Baja equipo');
    }
  }

  //Metodo para imprimir un equipo
  Future<void> printEquipo(String id) async {
    final response = await http.get(Uri.parse(baseUrl + 'api_services.php?action=print_equipo&id=$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to print equipo');
    }
  }

  // Obtener Datos del Usuario
  Future<String?> _fetchUserImage() async {
    try {
      if (user != null) {
        final imageUrl = ApiService.userImages + '${user!.uid}.jpg';
        final response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          return imageUrl;
        }
      }
      return null;
    } catch (e) {
      print("Error fetching user image: $e");
      return null;
    }
  }
}