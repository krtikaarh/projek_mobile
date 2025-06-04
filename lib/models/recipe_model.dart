// Model untuk Kategori
class Kategori {
  final String idCategory;
  final String strCategory;
  final String strCategoryThumb;
  final String strCategoryDescription;

  Kategori({
    required this.idCategory,
    required this.strCategory,
    required this.strCategoryThumb,
    required this.strCategoryDescription,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      idCategory: json['idCategory'] ?? '',
      strCategory: json['strCategory'] ?? '',
      strCategoryThumb: json['strCategoryThumb'] ?? '',
      strCategoryDescription: json['strCategoryDescription'] ?? '',
    );
  }
}

// Model untuk Bahan
class Bahan {
  final String strIngredient;
  final String strDescription;
  final String strType;

  Bahan({
    required this.strIngredient,
    required this.strDescription,
    required this.strType,
  });

  factory Bahan.fromJson(Map<String, dynamic> json) {
    return Bahan(
      strIngredient: json['strIngredient'] ?? '',
      strDescription: json['strDescription'] ?? '',
      strType: json['strType'] ?? '',
    );
  }
}

// Model untuk Area
class Area {
  final String strArea;

  Area({required this.strArea});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(strArea: json['strArea'] ?? '');
  }
}

// Model untuk Meal/Resep
class Meal {
  final String idMeal;
  final String strMeal;
  final String strDrinkAlternate;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final String strTags;
  final String strYoutube;
  final List<String> ingredients;
  final List<String> measures;

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strDrinkAlternate,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.strTags,
    required this.strYoutube,
    required this.ingredients,
    required this.measures,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];
    
    // Mengambil ingredients dan measures dari API
    for (int i = 1; i <= 20; i++) {
      String ingredient = json['strIngredient$i'] ?? '';
      String measure = json['strMeasure$i'] ?? '';
      
      if (ingredient.isNotEmpty) {
        ingredients.add(ingredient);
        measures.add(measure);
      }
    }

    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strDrinkAlternate: json['strDrinkAlternate'] ?? '',
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strTags: json['strTags'] ?? '',
      strYoutube: json['strYoutube'] ?? '',
      ingredients: ingredients,
      measures: measures,
    );
  }
}

// Model untuk Resep Lokal (Custom Recipe)
class ResepLokal {
  final int? id;
  final String nama;
  final String kategori;
  final String area;
  final String deskripsi;
  final String bahan;
  final String imagePath;
  final int isFavorite;

  ResepLokal({
    this.id,
    required this.nama,
    required this.kategori,
    required this.area,
    required this.deskripsi,
    required this.bahan,
    required this.imagePath,
    this.isFavorite = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'area': area,
      'deskripsi': deskripsi,
      'bahan': bahan,
      'imagePath': imagePath,
      'isFavorite': isFavorite,
    };
  }

  factory ResepLokal.fromMap(Map<String, dynamic> map) {
    return ResepLokal(
      id: map['id'],
      nama: map['nama'] ?? '',
      kategori: map['kategori'] ?? '',
      area: map['area'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      bahan: map['bahan'] ?? '',
      imagePath: map['imagePath'] ?? '',
      isFavorite: map['isFavorite'] ?? 0,
    );
  }
}