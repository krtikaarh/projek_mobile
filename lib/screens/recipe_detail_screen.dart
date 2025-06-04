import 'package:flutter/material.dart';
import 'package:projek/models/recipe_model.dart';
import 'package:projek/services/api_services.dart';
import 'package:projek/services/database_helper.dart';

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
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFromApi) {
      loadRecipeDetails();
    } else {
      loadLokalDetails();
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
      };
      isLoading = false;
    });

    await checkIfFavorite();
  }

  void loadLokalDetails() {
    final lokal = widget.resepLokal!;
    setState(() {
      recipe = {
        'strMeal': lokal.nama,
        'strMealThumb': lokal.imagePath,
        'strCategory': lokal.kategori,
        'strArea': 'Lokal',
        'strInstructions': lokal.deskripsi,
      };
      isLoading = false;
    });

    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    bool favorite = false;
    if (widget.isFromApi) {
      favorite = await DatabaseHelper.instance.isFavoritApi(widget.meal!.idMeal);
    } else {
      final resep = await DatabaseHelper.instance.readResepLokal(widget.resepLokal!.id!);
      favorite = resep?.isFavorite == 1;
    }

    setState(() {
      isFavorite = favorite;
    });
  }

  Future<void> toggleFavorite() async {
    if (widget.isFromApi) {
      final id = widget.meal!.idMeal;
      if (isFavorite) {
        await DatabaseHelper.instance.removeFavoritApi(id);
      } else {
        await DatabaseHelper.instance.addFavoritApi(widget.meal!);
      }
    } else {
      final id = widget.resepLokal!.id!;
      final newValue = isFavorite ? 0 : 1;
      await DatabaseHelper.instance.toggleFavoritResepLokal(id, newValue);
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                recipe!['strMealThumb'],
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe!['strMeal'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kategori: ${recipe!['strCategory']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  if (recipe!['strArea'] != null)
                    Text(
                      'Asal: ${recipe!['strArea']}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Instruksi Memasak',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    recipe!['strInstructions'],
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
