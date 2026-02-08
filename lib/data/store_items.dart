import '../models/store_item.dart';
import '../models/character.dart'; // Asegúrate de importar CharacterClass correctamente

final List<StoreItem> storeItems = [
  StoreItem(
    id: 'potion',
    name: 'Poción de Salud',
    description: 'Restaura 50 de salud.',
    price: 50,
    imageAsset: 'assets/items/health_potion.png',
    allowedClasses: [], // General
    type: ItemType.consumable,
    allowedSlot: 'consumable',
    maxQuantity: 2,
  ),
  StoreItem(
    id: 'shield',
    name: 'Escudo de Hierro',
    description: 'Reduce el daño recibido.',
    price: 100,
    imageAsset: 'assets/items/shield.png',
    allowedClasses: [], // General
    type: ItemType.shield,
    allowedSlot: 'shield',
  ),
  StoreItem(
    id: 'sword',
    name: 'Espada de Fuego',
    description: 'Aumenta tu daño.',
    price: 150,
    imageAsset: 'assets/items/fire_sword.png',
    allowedClasses: [CharacterClass.guerrero],
    type: ItemType.weapon,
    allowedSlot: 'weapon',
  ),
  StoreItem(
    id: 'bow',
    name: 'Arco Infernal',
    description: 'Ideal para ataques a distancia.',
    price: 120,
    imageAsset: 'assets/items/infernal_bow.png',
    allowedClasses: [CharacterClass.arquero],
    type: ItemType.weapon,
    allowedSlot: 'weapon',
  ),
  StoreItem(
    id: 'scepter',
    name: 'Cetro de Agua',
    description: 'Potencia tus hechizos.',
    price: 130,
    imageAsset: 'assets/items/water_scepter.png',
    allowedClasses: [CharacterClass.mago],
    type: ItemType.weapon,
    allowedSlot: 'weapon',
  ),
];
