class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    this.checked = false,
  });

  final String id;
  final String name;
  final bool checked;

  GroceryItem copyWith({bool? checked}) => GroceryItem(
    id: id,
    name: name,
    checked: checked ?? this.checked,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'checked': checked,
  };

  factory GroceryItem.fromJson(Map<String, Object?> json) => GroceryItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    checked: json['checked'] as bool? ?? false,
  );
}
