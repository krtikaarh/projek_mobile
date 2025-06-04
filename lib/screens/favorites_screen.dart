import 'dart:io';

import 'package:flutter/material.dart';

import 'package:projek/models/recipe_model.dart';
import 'package:projek/screens/recipe_detail_screen.dart';
import 'package:projek/services/database_helper.dart';
import 'package:projek/screens/login_screen.dart';

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
    _checkLogin();
    loadFavorit();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await DatabaseHelper.instance.isLoggedIn();
    if (!loggedIn) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> loadFavorit() async {
    final apiData = await DatabaseHelper.instance.getFavoritApi();
    final lokalData = await DatabaseHelper.instance.getFavoritResepLokal();

    setState(() {
      favoritApi = apiData.map((data) => Meal.fromMap(data)).toList();
      favoritLokal = lokalData.where((r) => r.isFavorite == 1).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Resep Favorit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (favoritApi.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Favorit dari API',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: favoritApi.length,
                              itemBuilder: (context, index) {
                                final meal = favoritApi[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 2,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        meal.strMealThumb,
                                        width: 54,
                                        height: 54,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      meal.strMeal,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(meal.strCategory ?? ''),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => DetailScreen(
                                                isFromApi: true,
                                                meal: meal,
                                              ),
                                        ),
                                      ).then((_) => loadFavorit());
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                          if (favoritLokal.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Favorit dari Lokal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: favoritLokal.length,
                              itemBuilder: (context, index) {
                                final resep = favoritLokal[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 2,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(resep.imagePath),
                                        width: 54,
                                        height: 54,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      resep.nama,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(resep.kategori),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => DetailScreen(
                                                isFromApi: false,
                                                resepLokal: resep,
                                              ),
                                        ),
                                      ).then((_) => loadFavorit());
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                          if (favoritApi.isEmpty && favoritLokal.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text(
                                  "Belum ada resep favorit yang disimpan.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
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
}
