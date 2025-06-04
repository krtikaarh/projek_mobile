import 'package:flutter/material.dart';
import 'package:projek/models/recipe_model.dart';
import 'package:projek/services/api_services.dart';
import 'package:projek/services/database_helper.dart';
import 'package:projek/screens/login_screen.dart';
import 'dart:io';

class DetailScreen extends StatefulWidget {
  final Meal? meal;
  final ResepLokal? resepLokal;
  final bool isFromApi;

  const DetailScreen({
    Key? key,
    this.meal,
    this.resepLokal,
    required this.isFromApi,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? recipe;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
    if (widget.isFromApi) {
      loadRecipeDetails();
    } else {
      loadLokalDetails();
    }
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

  Future<void> loadRecipeDetails() async {
    final detail = await ApiService.getMealDetail(widget.meal!.idMeal);
    setState(() {
      recipe = {
        'strMeal': detail?.strMeal,
        'strMealThumb': detail?.strMealThumb,
        'strCategory': detail?.strCategory,
        'strArea': detail?.strArea,
        'strInstructions': detail?.strInstructions,
        'ingredients': detail?.ingredients ?? [],
        'measures': detail?.measures ?? [],
      };
      isLoading = false;
    });
  }

  void loadLokalDetails() {
    final lokal = widget.resepLokal!;
    setState(() {
      recipe = {
        'strMeal': lokal.nama,
        'strMealThumb': lokal.imagePath,
        'strCategory': lokal.kategori,
        'strArea': lokal.area,
        'strInstructions': lokal.deskripsi,
        'ingredients': lokal.bahan.split(','),
        'measures': [],
      };
      isLoading = false;
    });
  }

  Widget _buildImage() {
    final img = recipe!['strMealThumb'];
    if (img != null && img.toString().startsWith('http')) {
      return Image.network(
        img,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
      );
    } else if (img != null && img.toString().isNotEmpty) {
      return Image.file(
        File(img),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
      );
    } else {
      return Container(
        width: double.infinity,
        height: 220,
        color: Colors.grey[200],
        child: Icon(Icons.image, size: 60, color: Colors.grey[400]),
      );
    }
  }

  Widget _buildIngredients() {
    final List ingredients = recipe!['ingredients'] ?? [];
    final List measures = recipe!['measures'] ?? [];
    if (ingredients.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bahan-bahan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 8),
        ...List.generate(ingredients.length, (i) {
          final ing = ingredients[i].toString().trim();
          if (ing.isEmpty) return SizedBox.shrink();
          final measure =
              (measures.length > i ? measures[i] : '').toString().trim();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(fontSize: 16, color: Colors.teal[700]),
                ),
                Expanded(
                  child: Text(
                    measure.isNotEmpty ? '$measure $ing' : ing,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Detail Resep')),
        body: Center(child: Text('Resep tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(recipe!['strMeal'] ?? 'Detail Resep'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  child: _buildImage(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe!['strMeal'],
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: Colors.teal[400],
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            recipe!['strCategory'] ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(width: 18),
                          if (recipe!['strArea'] != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.place,
                                  color: Colors.teal[400],
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  recipe!['strArea'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 18),
                      _buildIngredients(),
                      SizedBox(height: 18),
                      Text(
                        'Instruksi Memasak',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        recipe!['strInstructions'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
