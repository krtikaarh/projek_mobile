import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek/models/recipe_model.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Mengambil semua kategori
  static Future<List<Kategori>> getKategori() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories.php'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> kategoris = data['categories'] ?? [];

        return kategoris.map((json) => Kategori.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat kategori');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Mengambil semua bahan
  static Future<List<Bahan>> getBahan() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/list.php?i=list'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> bahans = data['meals'] ?? [];

        return bahans.map((json) => Bahan.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat bahan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Mengambil semua area
  static Future<List<Area>> getArea() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/list.php?a=list'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> areas = data['meals'] ?? [];

        return areas.map((json) => Area.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat area');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Mencari resep berdasarkan kategori
  static Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> meals = data['meals'] ?? [];

        return meals.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat resep');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Mencari resep berdasarkan bahan
  static Future<List<Meal>> getMealsByIngredient(String ingredient) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?i=$ingredient'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> meals = data['meals'] ?? [];

        return meals.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat resep');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Mencari resep berdasarkan area
  static Future<List<Meal>> getMealsByArea(String area) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/filter.php?a=$area'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> meals = data['meals'] ?? [];

        return meals.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat resep');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Mengambil detail resep berdasarkan ID
  static Future<Meal?> getMealDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> meals = data['meals'] ?? [];

        if (meals.isNotEmpty) {
          return Meal.fromJson(meals[0]);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Mencari resep berdasarkan nama
  static Future<List<Meal>> searchMealsByName(String name) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search.php?s=$name'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> meals = data['meals'] ?? [];

        return meals.map((json) => Meal.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
