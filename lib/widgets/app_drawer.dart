import 'package:asepe_homes/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35.r,
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  child: Icon(
                    Icons.person,
                    size: 34.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Asepe Homes',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Power Display & Relay Control',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary.withValues(alpha: 0.8),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 24.sp,
            ),
            title: Text(
              'Profile',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 16.sp,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 16.sp,
                  ),
                ),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  size: 24.sp,
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.switchTheme();
                },
                activeColor: Theme.of(context).colorScheme.primary,
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 24.sp,
            ),
            title: Text(
              'About',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 16.sp,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About Asepe Homes'),
            content: const Text(
              'This app controls relay switches and monitors power values for electrical engineering projects.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
