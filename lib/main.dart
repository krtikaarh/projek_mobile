import 'package:flutter/material.dart';
import 'package:projek/screens/home_screen.dart';
import 'package:projek/screens/login_screen.dart';
import 'package:projek/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hapus database untuk development/test (hapus baris ini di production)
  // await DatabaseHelper.instance.deleteDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resep Masakan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1A237E), // Deep Indigo
          primary: Color(0xFF1A237E), // Deep Indigo
          secondary: Color(0xFF00B8A9), // Teal Accent
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF22223B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Color(0xFFF5F6FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1A237E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFB0BEC5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          labelStyle: TextStyle(color: Color(0xFF1A237E)),
        ),
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: DatabaseHelper.instance.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data == true) {
            // Session masih aktif
            return BerandaScreen();
          }
          return LoginScreen();
        },
      ),
    );
  }
}
