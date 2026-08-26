class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.tags,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    this.rating = 0,
    this.favorite = false,
    this.mine = true,
  });

  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final String prepTime;
  final String cookTime;
  final String servings;
  final int rating;
  final bool favorite;
  final bool mine;

  Recipe copyWith({int? rating, bool? favorite}) {
    return Recipe(
      id: id,
      title: title,
      ingredients: ingredients,
      instructions: instructions,
      tags: tags,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      rating: rating ?? this.rating,
      favorite: favorite ?? this.favorite,
      mine: mine,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'ingredients': ingredients,
    'instructions': instructions,
    'tags': tags,
    'prepTime': prepTime,
    'cookTime': cookTime,
    'servings': servings,
    'rating': rating,
    'favorite': favorite,
    'mine': mine,
  };

  factory Recipe.fromJson(Map<String, Object?> json) {
    List<String> strings(String key) =>
        (json[key] as List<Object?>? ?? const []).whereType<String>().toList();
    return Recipe(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      ingredients: strings('ingredients'),
      instructions: strings('instructions'),
      tags: strings('tags'),
      prepTime: json['prepTime'] as String? ?? '',
      cookTime: json['cookTime'] as String? ?? '',
      servings: json['servings'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      favorite: json['favorite'] as bool? ?? false,
      mine: json['mine'] as bool? ?? true,
    );
  }
}
