import 'dart:io';
import 'package:flutter/material.dart';
import 'package:projek/models/recipe_model.dart';
import 'package:projek/screens/recipe_detail_screen.dart';
import 'package:projek/services/database_helper.dart';
import 'package:projek/screens/login_screen.dart';
import 'package:projek/screens/add_recipe_screen.dart';
import 'package:projek/services/favorite_service.dart';
import 'package:projek/services/api_services.dart';

class FavoritScreen extends StatefulWidget {
  @override
  _FavoritScreenState createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  late Future<List<_FavoriteItem>> _futureFavorites;

  @override
  void initState() {
    super.initState();
    _checkLogin();
    _loadFavorites();
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

  Future<List<_FavoriteItem>> _loadFavoriteItems() async {
    final ids = await FavoriteService.getFavorites();
    List<_FavoriteItem> items = [];
    for (final id in ids) {
      if (int.tryParse(id) == null) {
        // API
        final meal = await ApiService.getMealDetail(id);
        if (meal != null) {
          items.add(_FavoriteItem.api(meal));
        }
      } else {
        // Lokal
        final intId = int.tryParse(id);
        if (intId != null) {
          final lokal = await DatabaseHelper.instance.readResepLokal(intId);
          if (lokal != null) {
            items.add(_FavoriteItem.lokal(lokal));
          }
        }
      }
    }
    return items;
  }

  void _loadFavorites() {
    setState(() {
      _futureFavorites = _loadFavoriteItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Resep Favorit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.teal),
            tooltip: 'Tambah Resep Lokal',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TambahResepScreen()),
              );
              if (result == true) _loadFavorites();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<_FavoriteItem>>(
        future: _futureFavorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada resep favorit yang disimpan.'),
            );
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:
                          item.isApi
                              ? Image.network(
                                item.meal!.strMealThumb,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (c, e, s) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                              )
                              : (item.lokal!.imagePath.isNotEmpty
                                  ? Image.file(
                                    File(item.lokal!.imagePath),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[400],
                                    ),
                                  )),
                    ),
                    title: Text(
                      item.isApi ? item.meal!.strMeal : item.lokal!.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      item.isApi
                          ? item.meal!.strCategory
                          : item.lokal!.kategori,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Hapus dari Favorit',
                      onPressed: () async {
                        final id =
                            item.isApi
                                ? item.meal!.idMeal
                                : item.lokal!.id!.toString();
                        await FavoriteService.removeFavorite(id);
                        _loadFavorites();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Dihapus dari favorit')),
                        );
                      },
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => DetailScreen(
                                isFromApi: item.isApi,
                                meal: item.meal,
                                resepLokal: item.lokal,
                              ),
                        ),
                      );
                      if (result == true) _loadFavorites();
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class _FavoriteItem {
  final Meal? meal;
  final ResepLokal? lokal;
  final bool isApi;

  _FavoriteItem.api(this.meal) : lokal = null, isApi = true;
  _FavoriteItem.lokal(this.lokal) : meal = null, isApi = false;
}
