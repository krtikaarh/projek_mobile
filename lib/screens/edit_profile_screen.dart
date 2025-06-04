import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _imageFile;
  String? _username;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('loggedInUsername') ?? '';
      final path = prefs.getString('profileImagePath');
      if (path != null && path.isNotEmpty) {
        _imageFile = File(path);
      }
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.teal[100],
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child:
                    _imageFile == null
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.teal)
                        : null,
              ),
            ),
            SizedBox(height: 16),
            Text(
              _username ?? '',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            Text(
              'Tap foto untuk mengganti foto profil.\nFoto akan diambil dari kamera.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
