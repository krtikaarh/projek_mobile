import 'package:projek/services/api_services.dart';
import 'package:projek/services/database_helper.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  RecipeDetailScreen({required this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipe;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadRecipeDetails();
    checkIfFavorite();
  }

  Future<void> loadRecipeDetails() async {
    final details = await ApiService.getMealDetails(widget.recipeId);
    setState(() {
      recipe = details;
      isLoading = false;
    });
  }

  Future<void> checkIfFavorite() async {
    final favorites = await DatabaseHelper().getFavorites();
    setState(() {
      isFavorite = favorites.any((fav) => fav['id'] == widget.recipeId);
    });
  }

  Future<void> toggleFavorite() async {
    if (isFavorite) {
      await DatabaseHelper().deleteFavorite(widget.recipeId);
    } else {
      await DatabaseHelper().insertFavorite({
        'id': widget.recipeId,
        'name': recipe!['strMeal'],
        'image': recipe!['strMealThumb'],
        'category': recipe!['strCategory'],
      });
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Recipe Details')),
        body: Center(child: Text('Recipe not found')),
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Category: ${recipe!['strCategory']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  if (recipe!['strArea'] != null)
                    Text(
                      'Area: ${recipe!['strArea']}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Instructions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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