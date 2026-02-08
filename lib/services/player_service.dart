import 'package:flutter/material.dart';
import '../models/player_status.dart';
import '../models/store_item.dart';
import 'local_storage_service.dart';

/// Notificador global para informar cambios en el inventario
final ValueNotifier<bool> inventoryUpdated = ValueNotifier(false);

class PlayerService {
  final _storageService = LocalStorageService();

  Future<void> buyItem(PlayerStatus player, StoreItem item) async {
    final currentQuantity = player.inventory[item.id] ?? 0;

    if (item.isConsumable) {
      if (currentQuantity >= item.maxQuantity) {
        throw Exception('Has alcanzado el límite de compra para este objeto.');
      }
    } else {
      if (currentQuantity >= 1) {
        throw Exception('Ya posees este objeto.');
      }
    }

    if (player.coins >= item.price) {
      player.coins -= item.price;
      player.inventory[item.id] = currentQuantity + 1;
      await _storageService.saveCharacter(player.toCharacter());

      inventoryUpdated.value = !inventoryUpdated.value; // 🔔 Notificar actualización
    } else {
      throw Exception('No tienes suficientes monedas.');
    }
  }

  Future<void> saveProgress(PlayerStatus player) async {
    await _storageService.saveCharacter(player.toCharacter());
  }
}
