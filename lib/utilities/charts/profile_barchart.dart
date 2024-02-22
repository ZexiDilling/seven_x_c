import 'package:fl_chart/fl_chart.dart';
import '../../helpters/time_calculations.dart' show TimePeriod;
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:seven_x_c/utilities/charts/profile_chart_extra.dart';

BarChartData boulderBarChart(
    CloudSettings currentSettings,
    Map<String, List<double>> graphData,
    double maxYValue,
    List<String> colorOrder,
    TimePeriod selectedTimePeriod,
    String chartSelection, bool setterViewGrade) {
  return BarChartData(
    titlesData: FlTitlesData(
      show: true,
      topTitles: const AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (double value, TitleMeta meta) {
              return bottomTitles(
                  value, meta, selectedTimePeriod, chartSelection);
            }),
      ), 
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: leftTitles,
          interval: 5,
          reservedSize: 42,
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),
    ),
    gridData: const FlGridData(
      show: false,
    ),
    borderData: FlBorderData(
      show: false,
    ),
    minY: 0,
    maxY: maxYValue,
    barGroups: graphData.entries
        .map((entry) => generateGroup(
              currentSettings,
              int.parse(entry.key),
              entry.value,
              colorOrder, setterViewGrade,
            ))
        .toList(),
  );
  //   barGroups: graphData.entries
  //       .map(
  //         (entries) => generateGroup(
  //             currentSettings, entries.key, entries.value, colorOrder),
  //       )
  //       .toList(),
  // );
}
