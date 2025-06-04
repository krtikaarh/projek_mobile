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
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
