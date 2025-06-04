import 'package:flutter/material.dart';
import 'package:projek/models/recipe_model.dart';
import 'package:projek/screens/add_recipe_screen.dart';
import 'package:projek/screens/edit_profile_screen.dart';
import 'package:projek/screens/favorites_screen.dart';
import 'package:projek/screens/recipe_detail_screen.dart';
import 'package:projek/screens/login_screen.dart';
import 'package:projek/services/api_services.dart';
import 'package:projek/services/database_helper.dart';

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
    _checkLogin();
    _loadKategori();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat kategori: $e')));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Container()),
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

  Future<void> _logout() async {
    await DatabaseHelper.instance.logoutUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  void _onSearch(String value) async {
    if (value.isNotEmpty) {
      final meals = await ApiService.searchMealsByName(value);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultScreen(keyword: value, meals: meals),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Beranda',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              size: 28,
              color: Theme.of(context).colorScheme.secondary,
            ),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              size: 26,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Selamat Datang,',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Temukan resep favoritmu atau tambahkan kreasi baru!',
                style: TextStyle(fontSize: 16, color: Color(0xFF6C757D)),
              ),
              SizedBox(height: 22),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.07),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama makanan...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18),
                  ),
                  onSubmitted: _onSearch,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 30),

              // Categories Title
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 16),

              // Categories Grid
              Expanded(
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2.7,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onItemTapped(3),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add, size: 28),
        label: Text(
          'Tambah Resep',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Cari',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorit',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Tambah'),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriCard(Kategori kategori) {
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
          final meals = await ApiService.getMealsByCategory(
            kategori.strCategory,
          );
          if (meals.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MealsByCategoryScreen(
                      kategori: kategori.strCategory,
                      meals: meals,
                    ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tidak ada menu di kategori ini.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal memuat resep: $e')));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.07),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  getKategoriIcon(kategori.strCategory),
                  color: Colors.teal[700],
                  size: 26,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  kategori.strCategory,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[900],
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

// Tambahkan layar baru untuk menampilkan daftar menu berdasarkan kategori
class MealsByCategoryScreen extends StatelessWidget {
  final String kategori;
  final List<Meal> meals;

  const MealsByCategoryScreen({
    Key? key,
    required this.kategori,
    required this.meals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu: $kategori'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        itemCount: meals.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, index) {
          final meal = meals[index];
          return ListTile(
            leading: Image.network(
              meal.strMealThumb,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(meal.strMeal),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(meal: meal, isFromApi: true),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Layar hasil pencarian makanan
class SearchResultScreen extends StatelessWidget {
  final String keyword;
  final List<Meal> meals;

  const SearchResultScreen({
    Key? key,
    required this.keyword,
    required this.meals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil: "$keyword"'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body:
          meals.isEmpty
              ? Center(child: Text('Tidak ada hasil ditemukan.'))
              : ListView.separated(
                itemCount: meals.length,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return ListTile(
                    leading: Image.network(
                      meal.strMealThumb,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(meal.strMeal),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => DetailScreen(meal: meal, isFromApi: true),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
