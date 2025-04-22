import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../components/constants/defautls.dart';
import '../../components/constants/ghaps.dart';
import '../../components/section_title.dart';
import '../../components/theme/app_colors.dart';
import '../../responsive.dart';
import '../../services/api_services.dart';

class ProductOverviews extends StatelessWidget {
  const ProductOverviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(AppDefaults.padding),
        decoration: const BoxDecoration(
          color: AppColors.bgSecondayLight,
          borderRadius: BorderRadius.all(Radius.circular(AppDefaults.borderRadius)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const SectionTitle(
                  title: "Product views",
                  color: AppColors.secondaryLavender,
                ),
                const Spacer(),
                const SizedBox(height: 10),
              ],
            ),
            gapH24,
            const BarChartSample8(),
          ],
        ),
      ),
    );
  }
}

class BarChartSample8 extends StatefulWidget {
  const BarChartSample8({super.key});

  final Color textColor = AppColors.textColor2;
  final Color barBackgroundColor = AppColors.bgSecondayLight;
  final Color barColor = AppColors.barColor;

  @override
  State<StatefulWidget> createState() => BarChartSample8State();
}

class BarChartSample8State extends State<BarChartSample8> {
  final ApiService apiService = ApiService();
  Map<String, double> equipoEstadoMap = {'ALTA': 0, 'BAJA': 0};

  @override
  void initState() {
    super.initState();
    fetchEquipos();
  }

  Future<void> fetchEquipos() async {
    try {
      List<dynamic> fetchedEquipos = await apiService.getAllEquipos();
      setState(() {
        equipoEstadoMap = _aggregateEquipos(fetchedEquipos);
      });
      print('Datos de equipos: $equipoEstadoMap');
    } catch (e) {
      print('Failed to fetch equipos: $e');
    }
  }

  Map<String, double> _aggregateEquipos(List<dynamic> equipos) {
    Map<String, double> aggregatedEquipos = {'ALTA': 0, 'BAJA': 0};
    for (var equipo in equipos) {
      String estado = equipo['estado'];
      if (estado == 'ALTA' || estado == 'BAJA') {
        aggregatedEquipos[estado] = aggregatedEquipos[estado]! + 1;
      }
    }
    return aggregatedEquipos;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.graphic_eq),
              const SizedBox(
                width: 32,
              ),
              Text(
                'Equipment Status',
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          Expanded(
            child: equipoEstadoMap.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : BarChart(
              buildChartData(),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: (x % 2 == 0)
              ? AppColors.secondaryPeach
              : (x % 3 == 0)
              ? AppColors.primary
              : widget.barColor,
          borderRadius: BorderRadius.circular(2),
          borderDashArray: x >= 4 ? [4, 4] : null,
          width: Responsive.isMobile(context) ? 20 : 40,
          borderSide: BorderSide(
            color: (x % 2 == 0)
                ? AppColors.secondaryPeach
                : (x % 3 == 0)
                ? AppColors.primary
                : widget.barColor,
            width: 2.0,
          ),
        ),
      ],
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text = Text(
      equipoEstadoMap.keys.elementAt(value.toInt()),
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  BarChartData buildChartData() {
    double maxY = equipoEstadoMap.isNotEmpty
        ? (equipoEstadoMap.values.reduce((a, b) => a > b ? a : b) * 1.2)
        : 30.0; // Calcula maxY dinámicamente

    return BarChartData(
      maxY: maxY, // Usa el valor calculado dinámicamente
      minY: 0,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipMargin: 0,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              rod.toY.toString(), // Muestra solo el valor de la barra
              const TextStyle(
                color: Colors.white, // Cambiar el color del texto a negro o el que prefieras
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 38,
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(
        equipoEstadoMap.length,
            (i) {
          return makeGroupData(i, equipoEstadoMap.values.elementAt(i));
        },
      ),
      gridData: const FlGridData(show: true, drawVerticalLine: false),
    );
  }
}
