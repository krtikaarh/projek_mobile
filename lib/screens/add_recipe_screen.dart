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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nama Field
              Text(
                'NAMA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
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
                  controller: _namaController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Masukkan nama resep',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama resep tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),

              // Kategori Field
              Text(
                'KATEGORI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
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
                  controller: _kategoriController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Contoh: Makanan Utama, Dessert',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kategori tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),

              // Area Field
              Text(
                'Asal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
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
                  controller: _areaController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Contoh: Indonesia, Italia, Jepang',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Asal daerah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),

              // Deskripsi Field
              Text(
                'DESKRIPSI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
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
                  controller: _deskripsiController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding