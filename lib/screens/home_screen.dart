import 'package:asepe_homes/screens/power_analytics_screen.dart';
import 'package:asepe_homes/screens/relay_switches_screen.dart';
import 'package:asepe_homes/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:asepe_homes/screens/power_values_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Asepe Homes',
            style: TextStyle(
              fontSize: 24.sp,
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            indicatorWeight: 3.w,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.inversePrimary.withValues(alpha: 0.7),
            tabs: [
              Tab(
                text: 'Relay Control',
                icon: Icon(Icons.electrical_services, size: 24.sp),
              ),
              Tab(text: 'Power Monitor', icon: Icon(Icons.power, size: 24.sp)),
              Tab(
                text: 'Power Analytics',
                icon: Icon(Icons.poll_outlined, size: 24.sp),
              ),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: const TabBarView(
          children: [
            RelaySwitchesScreen(),
            PowerValuesScreen(),
            PowerAnalyticsScreen(),
          ],
        ),
      ),
    );
  }
}
