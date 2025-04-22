import 'package:flutter/material.dart';
import 'package:inventorylbc/config/methods/method.dart';
import '../../components/constants/defautls.dart';
import '../../components/constants/ghaps.dart';
import '../../components/section_title.dart';
import '../../components/theme/app_colors.dart';
import '../../services/api_services.dart';

class Overview extends StatelessWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(AppDefaults.padding),
        decoration: const BoxDecoration(
          color: AppColors.bgSecondayLight,
          borderRadius: BorderRadius.all(
              Radius.circular(AppDefaults.borderRadius)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: "Search"),
            gapH24,
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.padding),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                    Radius.circular(AppDefaults.borderRadius)),
                border: Border.all(width: 2, color: AppColors.highlightLight),
              ),
              child: Row(
                children: [
                  Icon(Icons.search),
                  const SizedBox(width: 8),
                  // Espacio entre el icono y el TextField
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        _searchEquipment(context, value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            gapH24,
          ],
        ),
      ),
    );
  }

  void _searchEquipment(BuildContext context, String query) async {
    try {
      ApiService apiService = ApiService();
      dynamic response = await apiService.searchEquipment(
          query); // Puede ser List<dynamic> o Map<String, dynamic>

      if (response is List) {
        List<DataRow> rows = [];
        for (var equipo in response) {
          rows.add(DataRow(cells: [
            DataCell(Text(equipo["nombre"] ?? "")),
            DataCell(Text(equipo["marca"] ?? "")),
            DataCell(Text(equipo["modelo"] ?? "")),
            DataCell(Text(equipo["estado"] ?? "")),
            DataCell(Text(equipo["numeroSerie"] ?? "")),
            DataCell(Row(
              children: [
                VerEquiposButton(equipo: equipo),
                ModificarEquipoButton(equipo: equipo),
                EliminarEquipoButton(equipo: equipo),
                ImprimirEquipoButton(equipo: equipo),
              ],
            )),
          ]));
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Resultados de la búsqueda"),
              content: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowHeight: 50,
                  headingRowColor: MaterialStateColor.resolveWith(
                        (state) => Colors.grey,
                  ),
                  columns: [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Marca')),
                    DataColumn(label: Text('Modelo')),
                    DataColumn(label: Text("Estado")),
                    DataColumn(label: Text('Número de Serie')),
                    DataColumn(label: Text('')),
                  ],
                  rows: rows,
                ),
              ),
            );
          },
        );
      } else {
        throw Exception('Respuesta inesperada de la API');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar equipos')),
      );
    }
  }
}