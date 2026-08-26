enum RecipeSort { standard, rating, alphabetisch, beliebtheit }

class RecipeFilters {
  const RecipeFilters({
    this.search = '',
    this.title = '',
    this.mine = false,
    this.rating = 0,
    this.tags = const [],
    this.sort = RecipeSort.standard,
  });

  final String search;
  final String title;
  final bool mine;
  final int rating;
  final List<String> tags;
  final RecipeSort sort;

  RecipeFilters copyWith({
    String? search,
    String? title,
    bool? mine,
    int? rating,
    List<String>? tags,
    RecipeSort? sort,
  }) => RecipeFilters(
    search: search ?? this.search,
    title: title ?? this.title,
    mine: mine ?? this.mine,
    rating: rating ?? this.rating,
    tags: tags ?? this.tags,
    sort: sort ?? this.sort,
  );

  Map<String, Object?> toJson() => {
    'search': search,
    'title': title,
    'mine': mine,
    'rating': rating,
    'tags': tags,
    'sort': sort.name,
  };

  factory RecipeFilters.fromJson(Map<String, Object?> json) => RecipeFilters(
    search: json['search'] as String? ?? '',
    title: json['title'] as String? ?? '',
    mine: json['mine'] as bool? ?? false,
    rating: json['rating'] as int? ?? 0,
    tags: (json['tags'] as List<Object?>? ?? const [])
        .whereType<String>()
        .toList(),
    sort: RecipeSort.values.firstWhere(
      (value) => value.name == json['sort'],
      orElse: () => RecipeSort.standard,
    ),
  );
}
