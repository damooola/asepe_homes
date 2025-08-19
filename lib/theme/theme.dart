import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFF0F0F0),
    primary: Color(0xFF1CCE9E),
    secondary: Color(0xFF1F0F5F),
    inversePrimary: Color(0xFF141414),
  ),
  tabBarTheme: TabBarThemeData(indicatorColor: Color(0xFF141414)),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1CCE9E),
    foregroundColor: Color(0xFFF0F0F0),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFF141414)),
  ),
  drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFF0F0F0)),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF141414),
    primary: Color(0xFF1CCE9E),
    secondary: Color(0xFF1CCE9E),
    inversePrimary: Color(0xFFF0F0F0),
  ),
  tabBarTheme: TabBarThemeData(indicatorColor: Color(0xFFF0F0F0)),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1CCE9E),
    foregroundColor: Color(0xFFF0F0F0),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFFF0F0F0)),
  ),

  drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF141414)),
);
