import 'package:flutter/material.dart';
import '../../services/local_auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../../services/local_storage_service.dart';
import '../../models/player_status.dart';
import '../../data/store_items.dart';
import '../../models/store_item.dart';
import '../../services/player_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  PlayerStatus? _player;
  List<StoreItem> _inventoryItems = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
    inventoryUpdated.addListener(() {
      if (mounted) _loadPlayer();
    });
  }

  @override
  void dispose() {
    inventoryUpdated.removeListener(() {});
    super.dispose();
  }

  Future<void> _loadPlayer() async {
    final character = await LocalStorageService().loadCharacter();
    if (character != null && mounted) {
      final player = PlayerStatus.fromCharacter(character);
      setState(() {
        _player = player;
        _inventoryItems = storeItems.where((item) => player.inventory.containsKey(item.id)).toList();
      });
    }
  }

  void _logout(BuildContext context) async {
    await LocalAuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _equipItem(StoreItem item) async {
    if (_player == null) return;
    setState(() {
      switch (item.type) {
        case ItemType.weapon:
          _player!.equippedWeapon = item.id;
          break;
        case ItemType.shield:
          _player!.equippedShield = item.id;
          break;
        case ItemType.armor:
          _player!.equippedArmor = item.id;
          break;
        case ItemType.special:
          _player!.equippedSpecial = item.id;
          break;
        default:
          break;
      }
    });
    await LocalStorageService().saveCharacter(_player!.toCharacter());
  }

  void _showAddCoinsDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1B),
        title: const Text(
          'Agregar Monedas',
          style: TextStyle(color: Colors.amberAccent, fontFamily: 'MedievalSharp'),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Cantidad de monedas',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Agregar', style: TextStyle(color: Colors.amberAccent)),
            onPressed: () {
              final int? amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                setState(() => _player!.coins += amount);
                LocalStorageService().saveCharacter(_player!.toCharacter());
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSlot(String label, String? itemId, ItemType slotType) {
    final item = storeItems.firstWhere(
      (element) => element.id == itemId,
      orElse: () => StoreItem(
        id: '',
        name: 'Vacío',
        description: '',
        price: 0,
        imageAsset: '',
        allowedClasses: [],
        type: slotType,
        allowedSlot: '',
      ),
    );

    final isEquipped = item.id.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (_player == null || !isEquipped) return;

        setState(() {
          switch (slotType) {
            case ItemType.weapon:
              _player!.equippedWeapon = null;
              break;
            case ItemType.shield:
              _player!.equippedShield = null;
              break;
            case ItemType.armor:
              _player!.equippedArmor = null;
              break;
            case ItemType.special:
              _player!.equippedSpecial = null;
              break;
            default:
              break;
          }
        });

        LocalStorageService().saveCharacter(_player!.toCharacter());
      },
      child: Container(
        width: 70,
        height: 70,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          border: Border.all(
            color: isEquipped ? Colors.amberAccent : Colors.white,
            width: isEquipped ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isEquipped
            ? Image.asset(item.imageAsset, fit: BoxFit.contain)
            : Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
      ),
    );
  }

  Widget _buildInventoryGrid() {
    const int inventorySlots = 12;
    List<Widget> slotWidgets = List.generate(inventorySlots, (index) {
      if (index < _inventoryItems.length) {
        final item = _inventoryItems[index];
        return _buildInventoryItemCard(item);
      } else {
        return _buildEmptySlot();
      }
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slotWidgets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) => slotWidgets[index],
    );
  }

  Widget _buildInventoryItemCard(StoreItem item) {
    final quantity = _player?.inventory[item.id] ?? 0;
    final isEquipped = _player?.equippedWeapon == item.id ||
        _player?.equippedShield == item.id ||
        _player?.equippedArmor == item.id ||
        _player?.equippedSpecial == item.id;

    return GestureDetector(
      onTap: () => _equipItem(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          border: Border.all(
            color: isEquipped ? Colors.amberAccent : Colors.white,
            width: isEquipped ? 2 : 1,
          ),
          boxShadow: isEquipped
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AnimatedScale(
                    scale: isEquipped ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Image.asset(
                      item.imageAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontFamily: 'MedievalSharp'),
                ),
              ],
            ),
            if (quantity > 1)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Vacío',
          style: TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'MedievalSharp'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      endDrawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3E2723), Color(0xFF1B1B1B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.account_circle, size: 60, color: Colors.amberAccent),
                  SizedBox(height: 10),
                  Text(
                    'Menú de Usuario',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.amberAccent,
                      fontFamily: 'MedievalSharp',
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on, color: Colors.amberAccent),
              title: const Text(
                'Agregar Monedas',
                style: TextStyle(color: Colors.white, fontFamily: 'MedievalSharp'),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddCoinsDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.white, fontFamily: 'MedievalSharp'),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/backgrounds/medieval_background.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: Builder(
              builder: (context) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pantalla de Perfil',
                          style: TextStyle(fontSize: 22, fontFamily: 'MedievalSharp', color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_player != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white70, width: 2),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/characters/${_player!.characterClass.name}_battle.png',
                                  height: 320,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Container(width: 1, height: 300, color: Colors.white38),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildEquipmentSlot('Arma', _player!.equippedWeapon, ItemType.weapon),
                                    const SizedBox(height: 12),
                                    _buildEquipmentSlot('Escudo', _player!.equippedShield, ItemType.shield),
                                    const SizedBox(height: 12),
                                    _buildEquipmentSlot('Armadura', _player!.equippedArmor, ItemType.armor),
                                    const SizedBox(height: 12),
                                    _buildEquipmentSlot('Especial', _player!.equippedSpecial, ItemType.special),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text('Inventario', style: TextStyle(fontSize: 20, color: Colors.white)),
                    const SizedBox(height: 10),
                    _buildInventoryGrid(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
