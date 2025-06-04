import 'dart:io';

import 'package:flutter/material.dart';

import 'package:projek/models/recipe_model.dart';
import 'package:projek/screens/recipe_detail_screen.dart';

import 'package:projek/services/database_helper.dart';

class FavoritScreen extends StatefulWidget {
  @override
  _FavoritScreenState createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  List<Meal> favoritApi = [];
  List<ResepLokal> favoritLokal = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorit();
  }

  Future<void> loadFavorit() async {
    final apiData = await DatabaseHelper.instance.getFavoritApi();
    final lokalData = await DatabaseHelper.instance.getFavoritResepLokal();

    setState(() {
      favoritApi = apiData.map((data) => Meal.fromMap(data)).toList();
      favoritLokal = lokalData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resep Favorit')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (favoritApi.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Favorit dari API',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: favoritApi.length,
                      itemBuilder: (context, index) {
                        final meal = favoritApi[index];
                        return ListTile(
                          leading: Image.network(meal.strMealThumb, width: 60, height: 60, fit: BoxFit.cover),
                          title: Text(meal.strMeal),
                          subtitle: Text(meal.strCategory ?? ''),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  isFromApi: true,
                                  meal: meal,
                                ),
                              ),
                            ).then((_) => loadFavorit()); // refresh after return
                          },
                        );
                      },
                    ),
                  ],
                  if (favoritLokal.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Favorit dari Lokal',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: favoritLokal.length,
                      itemBuilder: (context, index) {
                        final resep = favoritLokal[index];
                        return ListTile(
                          leading: Image.file(File(resep.imagePath),
                              width: 60, height: 60, fit: BoxFit.cover),
                          title: Text(resep.nama),
                          subtitle: Text(resep.kategori),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  isFromApi: false,
                                  resepLokal: resep,
                                ),
                              ),
                            ).then((_) => loadFavorit()); // refresh after return
                          },
                        );
                      },
                    ),
                  ],
                  if (favoritApi.isEmpty && favoritLokal.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text("Belum ada resep favorit yang disimpan.",
                            style: TextStyle(fontSize: 16)),
                      ),
                    )
                ],
              ),
            ),
    );
  }
}
