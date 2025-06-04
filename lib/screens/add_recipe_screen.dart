import 'package:flutter/material.dart';
import 'package:projek/models/recipe_model.dart';
import 'package:projek/services/database_helper.dart';

class TambahResepScreen extends StatefulWidget {
  final ResepLokal? resep;
  final bool isEdit;

  const TambahResepScreen({Key? key, this.resep, this.isEdit = false}) : super(key: key);

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

  Future<void> _simpanResep() async {
    if (_formKey.currentState!.validate()) {
      try {
        final resep = ResepLokal(
          id: widget.isEdit ? widget.resep!.id : null,
          nama: _namaController.text,
          kategori: _kategoriController.text,
          area: _areaController.text,
          deskripsi: _deskripsiController.text,
          bahan: _bahanController.text,
          imagePath: _imageUrlController.text,
          isFavorite: widget.isEdit ? widget.resep!.isFavorite : 0,
        );

        if (widget.isEdit) {
          await DatabaseHelper.instance.updateResepLokal(resep);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Resep berhasil diperbarui')),
          );
        } else {
          await DatabaseHelper.instance.createResepLokal(resep);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Resep berhasil ditambahkan')),
          );
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan resep: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
                hintText: 'Contoh: 500gr daging sapi, 2 buah bawang bombay...',
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
              SizedBox(height: 30),

              // Preview Image
              if (_imageUrlController.text.isNotEmpty)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
              SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                onPressed: _simpanResep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.isEdit ? 'UPDATE RESEP' : 'SIMPAN RESEP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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