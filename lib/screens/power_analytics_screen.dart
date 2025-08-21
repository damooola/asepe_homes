import 'package:asepe_homes/providers/power_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asepe_homes/models/power.dart';

class PowerAnalyticsScreen extends StatefulWidget {
  const PowerAnalyticsScreen({super.key});

  @override
  State<PowerAnalyticsScreen> createState() => _PowerAnalyticsScreenState();
}

class _PowerAnalyticsScreenState extends State<PowerAnalyticsScreen> {
  int selectedChartType = 0;
  int selectedTimeFrame = 0;
  int selectedPowerLine = 0;

  final List<String> timeFrames = ['24 Hours', '7 Days', '30 Days'];
  final List<String> chartTypes = ['Line Chart', 'Bar Chart', 'Area Chart'];
  final List<String> powerLines = [
    'All Lines',
    'Power 1',
    'Power 2',
    'Power 3',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PowerProvider>().fetchPowerHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PowerProvider>(
        builder: (context, powerProvider, child) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Column(
              children: [
                _buildHeader(context, powerProvider),
                SizedBox(height: 20.h),
                _buildFilterOptions(),
                SizedBox(height: 20.h),
                _buildStatistics(powerProvider),
                SizedBox(height: 20.h),
                if (powerProvider.isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                else if (powerProvider.powerHistory.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64.sp,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No historical data available',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(child: _buildChart(powerProvider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PowerProvider powerProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Power Analytics',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        IconButton(
          onPressed: powerProvider.fetchPowerHistory,
          icon: Icon(
            Icons.refresh,
            color: Theme.of(context).colorScheme.primary,
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Time Frame:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      timeFrames.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: FilterChip(
                            label: Text(entry.value),
                            selected: selectedTimeFrame == entry.key,
                            onSelected: (selected) {
                              setState(() {
                                selectedTimeFrame = entry.key;
                              });
                            },
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2),
                            checkmarkColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Text(
              'Chart Type:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      chartTypes.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: FilterChip(
                            label: Text(entry.value),
                            selected: selectedChartType == entry.key,
                            onSelected: (selected) {
                              setState(() {
                                selectedChartType = entry.key;
                              });
                            },
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.2),
                            checkmarkColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Text(
              'Power Lines:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      powerLines.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: FilterChip(
                            label: Text(entry.value),
                            selected: selectedPowerLine == entry.key,
                            onSelected: (selected) {
                              setState(() {
                                selectedPowerLine = entry.key;
                              });
                            },
                            selectedColor: Colors.orange.withValues(alpha: 0.2),
                            checkmarkColor: Colors.orange,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics(PowerProvider powerProvider) {
    if (powerProvider.powerHistory.isEmpty) return Container();

    final filteredData = _getFilteredData(powerProvider.powerHistory);
    final stats = _calculateStatistics(filteredData);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Average',
                    '${stats['avg']?.toStringAsFixed(1)} W',
                    Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Peak',
                    '${stats['max']?.toStringAsFixed(1)} W',
                    Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Minimum',
                    '${stats['min']?.toStringAsFixed(1)} W',
                    Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(PowerProvider powerProvider) {
    final filteredData = _getFilteredData(powerProvider.powerHistory);

    if (filteredData.isEmpty) {
      return Center(
        child: Text(
          'No data available for selected time frame',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${chartTypes[selectedChartType]} - ${timeFrames[selectedTimeFrame]}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child:
                  selectedChartType == 0
                      ? _buildLineChart(filteredData)
                      : selectedChartType == 1
                      ? _buildBarChart(filteredData)
                      : _buildAreaChart(filteredData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<PowerData> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 500,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1.w,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1.w,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25,
              interval: 5,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].createdAt;
                  return Text(
                    selectedTimeFrame == 0
                        ? '${date.hour}:${date.minute.toString().padLeft(2, '0')}'
                        : '${date.day}/${date.month}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 8.sp,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1500,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}W',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 8.sp,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        lineBarsData: _getLineChartBars(data),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} W',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 8.sp,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<PowerData> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxValue(data) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = data[rodIndex].createdAt;

              String powerLine = '';
              switch (rodIndex) {
                case 0:
                  powerLine = 'Power 1';
                  break;
                case 1:
                  powerLine = 'Power 2';
                  break;
                case 2:
                  powerLine = 'Power 3';
                  break;
              }
              return BarTooltipItem(
                '$powerLine\n${rod.toY.toStringAsFixed(1)} W\n ${date.day}/${date.month}',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 22,
              interval: 20,
              showTitles: false,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].createdAt;
                  return Text(
                    selectedTimeFrame == 0
                        ? '${date.hour}:${date.minute.toString()}'
                        : '${date.day}/${date.month}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 4.sp,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}W',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 10.sp,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _getBarGroups(data),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Widget _buildAreaChart(List<PowerData> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 500,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].createdAt;
                  return Text(
                    selectedTimeFrame == 0
                        ? '${date.hour}:${date.minute.toString().padLeft(2, '0')}'
                        : '${date.day}/${date.month}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 10.sp,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        lineBarsData: _getAreaChartBars(data),
      ),
    );
  }

  List<LineChartBarData> _getLineChartBars(List<PowerData> data) {
    List<LineChartBarData> bars = [];

    if (selectedPowerLine == 0 || selectedPowerLine == 1) {
      bars.add(
        LineChartBarData(
          spots:
              data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.power1);
              }).toList(),
          isCurved: true,
          color: Colors.red,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    if (selectedPowerLine == 0 || selectedPowerLine == 2) {
      bars.add(
        LineChartBarData(
          spots:
              data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.power2);
              }).toList(),
          isCurved: true,
          color: Colors.orange,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    if (selectedPowerLine == 0 || selectedPowerLine == 3) {
      bars.add(
        LineChartBarData(
          spots:
              data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.power3);
              }).toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return bars;
  }

  List<LineChartBarData> _getAreaChartBars(List<PowerData> data) {
    List<LineChartBarData> bars = [];

    if (selectedPowerLine == 0 || selectedPowerLine == 1) {
      bars.add(
        LineChartBarData(
          spots:
              data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.power1);
              }).toList(),
          isCurved: true,
          color: Colors.red,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.red.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    if (selectedPowerLine == 0 || selectedPowerLine == 2) {
      bars.add(
        LineChartBarData(
          spots:
              data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.power2);
              }).toList(),
          isCurved: true,
          color: Colors.orange,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.orange.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    if (selectedPowerLine == 0 || selectedPowerLine == 3) {
      bars.add(
        LineChartBarData(
          spots:
              data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.power3);
              }).toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    return bars;
  }

  List<BarChartGroupData> _getBarGroups(List<PowerData> data) {
    return data.asMap().entries.map((entry) {
      List<BarChartRodData> rods = [];

      if (selectedPowerLine == 0 || selectedPowerLine == 1) {
        rods.add(
          BarChartRodData(
            toY: entry.value.power1,
            color: Colors.red,
            width: 4.w,
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      }

      if (selectedPowerLine == 0 || selectedPowerLine == 2) {
        rods.add(
          BarChartRodData(
            toY: entry.value.power2,
            color: Colors.orange,
            width: 4.w,
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      }

      if (selectedPowerLine == 0 || selectedPowerLine == 3) {
        rods.add(
          BarChartRodData(
            toY: entry.value.power3,
            color: Colors.blue,
            width: 4.w,
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      }

      return BarChartGroupData(x: entry.key, barRods: rods, barsSpace: 8.w);
    }).toList();
  }

  List<PowerData> _getFilteredData(List<PowerData> data) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (selectedTimeFrame) {
      case 0:
        cutoffDate = now.subtract(const Duration(hours: 24));
        break;
      case 1:
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case 2:
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      default:
        cutoffDate = now.subtract(const Duration(hours: 24));
    }

    final filtered =
        data.where((item) => item.createdAt.isAfter(cutoffDate)).toList();

    if (filtered.length > 50) {
      final step = filtered.length ~/ 50;
      return filtered
          .where((item) => filtered.indexOf(item) % step == 0)
          .toList();
    }

    return filtered;
  }

  Map<String, double> _calculateStatistics(List<PowerData> data) {
    if (data.isEmpty) return {'avg': 0, 'max': 0, 'min': 0};

    List<double> allValues = [];

    for (var item in data) {
      if (selectedPowerLine == 0) {
        allValues.addAll([item.power1, item.power2, item.power3]);
      } else if (selectedPowerLine == 1) {
        allValues.add(item.power1);
      } else if (selectedPowerLine == 2) {
        allValues.add(item.power2);
      } else if (selectedPowerLine == 3) {
        allValues.add(item.power3);
      }
    }

    if (allValues.isEmpty) return {'avg': 0, 'max': 0, 'min': 0};

    final avg = allValues.reduce((a, b) => a + b) / allValues.length;
    final max = allValues.reduce((a, b) => a > b ? a : b);
    final min = allValues.reduce((a, b) => a < b ? a : b);

    return {'avg': avg, 'max': max, 'min': min};
  }

  double _getMaxValue(List<PowerData> data) {
    if (data.isEmpty) return 1000;

    double maxVal = 0;
    for (var item in data) {
      if (selectedPowerLine == 0) {
        maxVal = [
          maxVal,
          item.power1,
          item.power2,
          item.power3,
        ].reduce((a, b) => a > b ? a : b);
      } else if (selectedPowerLine == 1) {
        maxVal = maxVal > item.power1 ? maxVal : item.power1;
      } else if (selectedPowerLine == 2) {
        maxVal = maxVal > item.power2 ? maxVal : item.power2;
      } else if (selectedPowerLine == 3) {
        maxVal = maxVal > item.power3 ? maxVal : item.power3;
      }
    }

    return maxVal > 0 ? maxVal : 1000;
  }
}
