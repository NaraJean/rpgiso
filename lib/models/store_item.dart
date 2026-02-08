import 'character.dart';

enum ItemType { weapon, armor, shield, special, consumable }

class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageAsset;
  final List<CharacterClass> allowedClasses;
  final ItemType type;
  final String allowedSlot; // 'weapon', 'shield', 'armor', 'special', 'consumable'
  bool isSold;
  final int maxQuantity;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageAsset,
    required this.allowedClasses,
    required this.type,
    required this.allowedSlot,
    this.isSold = false, // Valor por defecto
    this.maxQuantity = 1,
  });
}

extension StoreItemExtensions on StoreItem {
  bool get isConsumable => type == ItemType.consumable;
}