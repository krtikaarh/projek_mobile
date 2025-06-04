import 'package:flutter/material.dart';
import 'package:projek/models/recipe_model.dart';
import 'package:projek/services/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TambahResepScreen extends StatefulWidget {
  final ResepLokal? resep;
  final bool isEdit;

  const TambahResepScreen({Key? key, this.resep, this.isEdit = false})
    : super(key: key);

  @override
  _TambahResepScreenState createState() => _TambahResepScreenState();
}

class _TambahResepScreenState extends State<TambahResepScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _areaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _bahanController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.resep != null) {
      _namaController.text = widget.resep!.nama;
      _kategoriController.text = widget.resep!.kategori;
      _areaController.text = widget.resep!.area;
      _deskripsiController.text = widget.resep!.deskripsi;
      _bahanController.text = widget.resep!.bahan;
      _imageUrlController.text = widget.resep!.imagePath;
      if (_imageUrlController.text.isNotEmpty &&
          File(_imageUrlController.text).existsSync()) {
        _imageFile = File(_imageUrlController.text);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _areaController.dispose();
    _deskripsiController.dispose();
    _bahanController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil gambar dari kamera
  Future<void> _ambilGambarDariKamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _imageUrlController.text = picked.path;
      });
    }
  }

  Future<void> _simpanResep() async {
    // Validasi gambar: harus ada salah satu (kamera atau url)
    if (_imageFile == null &&
        (_imageUrlController.text.isEmpty ||
            !Uri.tryParse(_imageUrlController.text)!.isAbsolute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar resep harus diisi (kamera atau URL)!')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      try {
        final resep = ResepLokal(
          id: widget.isEdit ? widget.resep!.id : null,
          nama: _namaController.text,
          kategori: _kategoriController.text,
          area: _areaController.text,
          deskripsi: _deskripsiController.text,
          bahan: _bahanController.text,
          imagePath:
              _imageFile != null ? _imageFile!.path : _imageUrlController.text,
          isFavorite: widget.isEdit ? widget.resep!.isFavorite : 0,
        );

        if (widget.isEdit) {
          await DatabaseHelper.instance.updateResepLokal(resep);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Resep berhasil diperbarui')));
        } else {
          await DatabaseHelper.instance.createResepLokal(resep);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Resep berhasil ditambahkan')));
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan resep: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Resep' : 'Resep Baru'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _simpanResep,
            child: Text(
              'SIMPAN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Nama Field
                  _buildSectionLabel('NAMA'),
                  _buildTextFormField(
                    controller: _namaController,
                    hintText: 'Masukkan nama resep',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama resep tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Kategori Field
                  _buildSectionLabel('KATEGORI'),
                  _buildTextFormField(
                    controller: _kategoriController,
                    hintText: 'Contoh: Makanan Utama, Dessert',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kategori tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Area Field
                  _buildSectionLabel('ASAL DAERAH'),
                  _buildTextFormField(
                    controller: _areaController,
                    hintText: 'Contoh: Indonesia, Italia, Jepang',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Asal daerah tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Deskripsi Field
                  _buildSectionLabel('DESKRIPSI'),
                  _buildTextFormField(
                    controller: _deskripsiController,
                    hintText: 'Jelaskan cara membuat resep...',
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Bahan Field
                  _buildSectionLabel('BAHAN-BAHAN'),
                  _buildTextFormField(
                    controller: _bahanController,
                    hintText:
                        'Contoh: 500gr daging sapi, 2 buah bawang bombay...',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bahan-bahan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Image URL Field
                  _buildSectionLabel('GAMBAR (URL)'),
                  _buildTextFormField(
                    controller: _imageUrlController,
                    hintText: 'https://example.com/image.jpg',
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!Uri.tryParse(value)!.isAbsolute) {
                          return 'URL gambar tidak valid';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Image Field (Camera)
                  _buildSectionLabel('GAMBAR (KAMERA)'),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _ambilGambarDariKamera,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Ambil dari Kamera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          elevation: 2,
                        ),
                      ),
                      SizedBox(width: 16),
                      if (_imageFile != null)
                        Text(
                          'Gambar dipilih',
                          style: TextStyle(color: Colors.teal),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Preview Image
                  if (_imageFile != null)
                    Container(
                      height: 180,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
                    )
                  else if (_imageUrlController.text.isNotEmpty)
                    Container(
                      height: 180,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _imageUrlController.text,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.error,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _simpanResep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      widget.isEdit ? 'UPDATE RESEP' : 'SIMPAN RESEP',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      children: [
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText: hintText,
            ),
            validator: validator,
            onChanged: (value) {
              if (controller == _imageUrlController) {
                setState(() {}); // Refresh untuk preview image
              }
            },
          ),
        ),
      ],
    );
  }
}
