import 'package:flutter/material.dart';
import 'package:projek/models/recipe_model.dart';
import 'package:projek/services/database_helper.dart';


class FavoritScreen extends StatefulWidget {
  @override
  _FavoritScreenState createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  List<ResepLokal> resepLokalFavorit = [];
  List<Map<String, dynamic>> resepApiFavorit = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final resepLokal = await DatabaseHelper.instance.getFavoritResepLokal();
      final resepApi = await DatabaseHelper.instance.getFavoritApi();
      
      setState(() {
        resepLokalFavorit = resepLokal;
        resepApiFavorit = resepApi;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat favorit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Favorit'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : resepLokalFavorit.isEmpty && resepApiFavorit.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada resep favorit',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tambahkan resep ke favorit untuk melihatnya di sini',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: resepLokalFavorit.length + resepApiFavorit.length,
                      itemBuilder: (context, index) {
                        if (index < resepLokalFavorit.length) {
                          return _buildResepLokalCard(resepLokalFavorit[index]);
                        } else {
                          return _buildResepApiCard(
                              resepApiFavorit[index - resepLokalFavorit.length]);
                        }
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildResepLokalCard(ResepLokal resep) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailResepScreen(
              resepLokal: resep,
              isFromApi: false,
            ),
          ),
        ).then((_) => _loadFavorites());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[200],
                ),
                child: resep.imagePath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          resep.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.restaurant,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.restaurant,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          resep.nama,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    resep.kategori,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResepApiCard(Map<String, dynamic> resep) {
    return GestureDetector(
      onTap: () {
        // Buat objek Meal dari data favorit
        final meal = Meal(
          idMeal: resep['idMeal'],
          strMeal: resep['strMeal'],
          strDrinkAlternate: '',
          strCategory: resep['strCategory'],
          strArea: resep['strArea'],
          strInstructions: '',
          strMealThumb: resep['strMealThumb'],
          strTags: '',
          strYoutube: '',
          ingredients: [],
          measures: [],
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailResepScreen(
              meal: meal,
              isFromApi: true,
            ),
          ),
        ).then((_) => _loadFavorites());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: NetworkImage(resep['strMealThumb']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          resep['strMeal'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    resep['strCategory'],
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}