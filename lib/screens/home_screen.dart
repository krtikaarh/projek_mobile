import 'package:flutter/material.dart';
import 'package:projek/models/recipe_model.dart';
import 'package:projek/screens/add_recipe_screen.dart';
import 'package:projek/screens/favorites_screen.dart';
import 'package:projek/services/api_services.dart';



class BerandaScreen extends StatefulWidget {
  @override
  _BerandaScreenState createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _selectedIndex = 0;
  List<Kategori> kategoriList = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  void _loadKategori() async {
    try {
      final categories = await ApiService.getKategori();
      setState(() {
        kategoriList = categories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kategori: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => //PencarianScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FavoritScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TambahResepScreen()),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Halo,',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                'Apa yang ada di dapur Anda?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),

              // Search Bar
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
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan bahan-bahan Anda',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => //PencarianScreen(initialSearch: value),
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 30),

              // Categories Title
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),

              // Categories Grid
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3,
                        ),
                        itemCount: kategoriList.length,
                        itemBuilder: (context, index) {
                          final kategori = kategoriList[index];
                          return _buildKategoriCard(kategori);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IconButton(
          onPressed: () => _onItemTapped(3),
          icon: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey[600],
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Cari',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Tambah',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriCard(Kategori kategori) {
    // Icon mapping untuk setiap kategori
    IconData getKategoriIcon(String nama) {
      switch (nama.toLowerCase()) {
        case 'beef':
          return Icons.lunch_dining;
        case 'chicken':
          return Icons.set_meal;
        case 'dessert':
          return Icons.cake;
        case 'lamb':
          return Icons.restaurant;
        case 'miscellaneous':
          return Icons.restaurant_menu;
        case 'pasta':
          return Icons.ramen_dining;
        case 'pork':
          return Icons.fastfood;
        case 'seafood':
          return Icons.set_meal;
        case 'side':
          return Icons.rice_bowl;
        case 'starter':
          return Icons.appetizer;
        case 'vegan':
          return Icons.eco;
        case 'vegetarian':
          return Icons.local_florist;
        case 'breakfast':
          return Icons.free_breakfast;
        case 'goat':
          return Icons.restaurant;
        default:
          return Icons.restaurant;
      }
    }

    return GestureDetector(
      onTap: () async {
        try {
          final meals = await ApiService.getMealsByCategory(kategori.strCategory);
          if (meals.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailResepScreen(
                  meal: meals[0],
                  isFromApi: true,
                ),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat resep: $e')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  getKategoriIcon(kategori.strCategory),
                  color: Colors.teal,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  kategori.strCategory,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}