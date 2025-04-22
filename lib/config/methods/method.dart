import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/src/EditEquimentPage.dart';
import '../../pages/src/PrintViewPage.dart';
import '../../pages/src/ViewEquimentPage.dart';
import '../../services/api_services.dart';


// Ver Equipos
class VerEquiposButton extends StatelessWidget {
  final dynamic equipo;
  const VerEquiposButton({Key? key, required this.equipo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.remove_red_eye),
      onPressed: () {
        _verEquipo(context, equipo);
      },
    );
  }

  void _verEquipo(BuildContext context, dynamic equipo) {
    // Puedes mostrar un nuevo diálogo, navegar a una nueva pantalla, etc.
    Get.to(() => ViewEquipment(equipo:equipo));
  }
}

// Modificar equipos
class ModificarEquipoButton extends StatelessWidget {
  final dynamic equipo;
  const ModificarEquipoButton({Key? key, required this.equipo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        _modificarEquipo(context, equipo);
      },
    );
  }

  void _modificarEquipo(BuildContext context, dynamic equipo) {
    // Implementa la lógica necesaria
    Get.to(() => EditEquipment(equipo: equipo));
  }
}

// Eliminar equipos
class EliminarEquipoButton extends StatelessWidget {
  final dynamic equipo;
  const EliminarEquipoButton({Key? key, required this.equipo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {
        _bajaEquipo(context, equipo);
      },
    );
  }

  void _bajaEquipo(BuildContext context, dynamic equipo) async{
    // Lógica para imprimir el equipo
    print("Baja del equipo: ${equipo['nombre']}");
    // Implementa la lógica necesaria
    try {
      ApiService apiService = ApiService();
      await apiService.bajaEquipo(equipo['id']);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Equipo dado de Baja correctamente')),
      );

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al dar de baja el equipo')),
      );
    }
  }
}

// Imprimir equipos
class ImprimirEquipoButton extends StatelessWidget {
  final dynamic equipo;
  const ImprimirEquipoButton({Key? key, required this.equipo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.print),
      onPressed: () {
        _imprimirEquipo(context, equipo);
      },
    );
  }

  void _imprimirEquipo(BuildContext context, dynamic equipo) {
    // Implementa la lógica necesaria
    Get.to(() => PrintView(equipo: equipo,));
  }
}
