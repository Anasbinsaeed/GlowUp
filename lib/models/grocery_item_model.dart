class GroceryItem {
  final String id;
  String name;
  String category;
  String emoji;
  bool isChecked;
  int quantity;

  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    this.isChecked = false,
    this.quantity = 1,
  });

  static String emojiForCategory(String cat) {
    switch (cat) {
      case 'fruits':
        return '🍓';
      case 'veggies':
        return '🥦';
      case 'snacks':
        return '🍿';
      case 'dairy':
        return '🥛';
      case 'protein':
        return '🍗';
      case 'drinks':
        return '🧃';
      case 'bakery':
        return '🥐';
      default:
        return '🛒';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'emoji': emoji,
        'isChecked': isChecked ? 1 : 0,
        'quantity': quantity,
      };

  factory GroceryItem.fromMap(Map<String, dynamic> m) => GroceryItem(
        id: m['id'],
        name: m['name'],
        category: m['category'],
        emoji: m['emoji'],
        isChecked: m['isChecked'] == 1,
        quantity: m['quantity'],
      );
}
