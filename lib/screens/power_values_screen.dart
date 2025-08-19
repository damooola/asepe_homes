import 'package:asepe_homes/providers/power_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PowerValuesScreen extends StatelessWidget {
  const PowerValuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PowerProvider>(
        builder: (context, powerProvider, child) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Power Monitor',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: powerProvider.fetchLatestPowerData,
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                if (powerProvider.isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                else if (powerProvider.latestPowerData == null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.power_off,
                            size: 64.sp,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No power data available',
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
                  Expanded(
                    child: Column(
                      children: [
                        _buildPowerCard(
                          context,
                          'Power 1',
                          powerProvider.latestPowerData!.power1,
                          Icons.flash_on,
                          Colors.red,
                        ),
                        SizedBox(height: 20.h),
                        _buildPowerCard(
                          context,
                          'Power 2',
                          powerProvider.latestPowerData!.power2,
                          Icons.flash_on,
                          Colors.orange,
                        ),
                        SizedBox(height: 20.h),
                        _buildPowerCard(
                          context,
                          'Power 3',
                          powerProvider.latestPowerData!.power3,
                          Icons.flash_on,
                          Colors.blue,
                        ),
                        SizedBox(height: 30.h),
                        _buildLastUpdatedCard(
                          context,
                          powerProvider.latestPowerData!.createdAt,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPowerCard(
    BuildContext context,
    String title,
    double power,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 24.sp, color: color),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${power.toStringAsFixed(2)} W',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdatedCard(BuildContext context, DateTime lastUpdated) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 20.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 12.w),
            Text(
              'Last updated: ${_formatDateTime(lastUpdated)}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
