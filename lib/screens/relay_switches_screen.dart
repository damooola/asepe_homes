import 'package:asepe_homes/providers/relay_provider.dart';
import 'package:asepe_homes/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RelaySwitchesScreen extends StatefulWidget {
  const RelaySwitchesScreen({super.key});

  @override
  State<RelaySwitchesScreen> createState() => _RelaySwitchesScreenState();
}

class _RelaySwitchesScreenState extends State<RelaySwitchesScreen> {
  String? _previousError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelayProvider>().fetchRelayStates();
    });
  }

  void _checkForErrors(RelayProvider relayProvider) {
    if (relayProvider.lastError != null &&
        relayProvider.lastError != _previousError) {
      CustomSnackBar.showError(
        context: context,
        message: relayProvider.lastError!,
        duration: const Duration(seconds: 4),
      );

      _previousError = relayProvider.lastError;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        relayProvider.clearError();
      });
    }

    if (relayProvider.lastError == null) {
      _previousError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RelayProvider>(
        builder: (context, relayProvider, child) {
          _checkForErrors(relayProvider);

          return RefreshIndicator(
            onRefresh: () => relayProvider.fetchRelayStates(),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Relay Control Panel',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed:
                                relayProvider.isLoading
                                    ? null
                                    : () => _showResetDialog(context),
                            icon: Icon(
                              Icons.settings_backup_restore_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24.sp,
                            ),
                            tooltip: 'Reset All Relays',
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Relay cards
                  Expanded(
                    child: ListView(
                      children: [
                        _buildRelayCard(
                          context,
                          'Relay 1',
                          relayProvider.relay1,
                          (value) => relayProvider.updateRelay(1, value),
                          relayProvider.isLoading,
                          Icons.power_settings_new,
                          Color(0xFF1CCE9E),
                        ),
                        SizedBox(height: 20.h),
                        _buildRelayCard(
                          context,
                          'Relay 2',
                          relayProvider.relay2,
                          (value) => relayProvider.updateRelay(2, value),
                          relayProvider.isLoading,
                          Icons.power_settings_new,
                          Color(0xFF1CCE9E),
                        ),
                        SizedBox(height: 20.h),
                        _buildRelayCard(
                          context,
                          'Relay 3',
                          relayProvider.relay3,
                          (value) => relayProvider.updateRelay(3, value),
                          relayProvider.isLoading,
                          Icons.power_settings_new,
                          Color(0xFF1CCE9E),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRelayCard(
    BuildContext context,
    String title,
    bool value,
    Function(bool) onChanged,
    bool isLoading,
    IconData icon,
    Color accentColor,
  ) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color:
              value
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: (value
                        ? accentColor
                        : Theme.of(context).colorScheme.inversePrimary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 32.sp,
                color:
                    value
                        ? accentColor
                        : Theme.of(context).colorScheme.inversePrimary,
              ),
            ),

            SizedBox(width: 20.w),

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
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: (value
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          value ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                value
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (isLoading)
              SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            else
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                activeTrackColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                inactiveTrackColor: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset All Relays'),
          content: const Text(
            'This will turn OFF all relay switches. Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<RelayProvider>().resetAllRelays();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset All'),
            ),
          ],
        );
      },
    );
  }
}
