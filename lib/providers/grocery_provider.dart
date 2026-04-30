import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/grocery_item_model.dart';
import '../database/db_helper.dart';
import '../services/widget_service.dart';

class GroceryProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<GroceryItem> _items = [];
  List<GroceryItem> get items => _items;

  List<GroceryItem> get unchecked => _items.where((i) => !i.isChecked).toList();
  List<GroceryItem> get checked => _items.where((i) => i.isChecked).toList();

  Future<void> load() async {
    final rows = await _db.getAll('grocery_items');
    _items = rows.map(GroceryItem.fromMap).toList();
    notifyListeners();
  }

  Future<void> add(GroceryItem item) async {
    await _db.insert('grocery_items', item.toMap());
    _items.add(item);
    notifyListeners();
    WidgetService.updateGroceryWidget(_items);
  }

  Future<void> toggle(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    _items[idx].isChecked = !_items[idx].isChecked;
    await _db.update('grocery_items', _items[idx].toMap(), id);
    notifyListeners();
    WidgetService.updateGroceryWidget(_items);
  }

  Future<void> remove(String id) async {
    await _db.delete('grocery_items', id);
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    WidgetService.updateGroceryWidget(_items);
  }

  Future<void> clearChecked() async {
    final toRemove = checked.map((i) => i.id).toList();
    for (final id in toRemove) {
      await _db.delete('grocery_items', id);
    }
    _items.removeWhere((i) => i.isChecked);
    notifyListeners();
  }

  GroceryItem createNew({
    required String name,
    required String category,
    int quantity = 1,
  }) {
    return GroceryItem(
      id: const Uuid().v4(),
      name: name,
      category: category,
      emoji: GroceryItem.emojiForCategory(category),
      quantity: quantity,
    );
  }

  Future<void> clearAllData() async {
    await _db.clearTable('grocery_items');
    _items.clear();
    notifyListeners();
  }
}
