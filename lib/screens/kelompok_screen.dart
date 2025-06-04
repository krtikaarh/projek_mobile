import 'package:flutter/material.dart';

class KelompokScreen extends StatelessWidget {
  // Data kelompok statis (langsung tampil, tidak perlu input manual)
  final List<KelompokAnggota> anggota = [
    KelompokAnggota(
      index: 0,
      nama: 'Arrafi Nuristiawan',
      nim: '123220141',
      fotoAsset: 'assets/2.jpeg',
    ),
    KelompokAnggota(
      index: 1,
      nama: 'Kartika Rahmi Anjani',
      nim: '123220143',
      fotoAsset: 'assets/1.png',
    ),
    // Tambahkan anggota lain jika perlu
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Kelompok'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: anggota.length,
        padding: EdgeInsets.all(24),
        itemBuilder: (context, i) {
          final a = anggota[i];
          return Card(
            margin: EdgeInsets.only(bottom: 24),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.teal[50],
                    backgroundImage:
                        (a.fotoAsset != null && a.fotoAsset!.isNotEmpty)
                            ? AssetImage(a.fotoAsset!)
                            : null,
                    child:
                        (a.fotoAsset == null || a.fotoAsset!.isEmpty)
                            ? Icon(
                              Icons.account_circle,
                              size: 48,
                              color: Colors.teal,
                            )
                            : null,
                  ),
                  SizedBox(height: 16),
                  Text(
                    a.nama,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'NIM: ${a.nim}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class KelompokAnggota {
  final int index;
  final String nama;
  final String nim;
  final String? fotoAsset;
  KelompokAnggota({
    required this.index,
    required this.nama,
    required this.nim,
    this.fotoAsset,
  });
}
