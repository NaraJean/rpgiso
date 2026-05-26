/// Representa el diálogo de un NPC dentro de una misión narrativa.
class NpcDialogue {
  /// Nombre del NPC que habla (e.g. "Sir Cedric", "El Camaleón").
  final String npcName;

  /// Ruta opcional a la imagen del NPC. Si es null, se muestra solo el nombre.
  final String? npcImageAsset;

  /// Texto del diálogo que se muestra con efecto de máquina de escribir.
  final String text;

  const NpcDialogue({
    required this.npcName,
    required this.text,
    this.npcImageAsset,
  });
}
