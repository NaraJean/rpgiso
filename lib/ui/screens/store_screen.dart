import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../models/player_status.dart';
import '../../services/local_storage_service.dart';
import '../../data/store_items.dart';
import '../../services/player_service.dart';
import '../../models/store_item.dart';
import 'dart:math';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with TickerProviderStateMixin {
  PlayerStatus? _player;
  late String _vendorDialogue;
  List<StoreItem> _filteredItems = [];

  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _animations;

  final List<String> _dialogues = [
    '¡Bienvenido, viajero!',
    'Cada objeto tiene su historia...',
    'No encontrarás mejores precios.',
    'Todo lo que ves es auténtico.',
    'Lleva lo que necesites para tu aventura.'
  ];

  final List<String> _purchaseDialogues = [
    '¡Buena elección!',
    'Ese objeto te será útil.',
    'Gracias por tu compra.',
    'Vuelve pronto, aventurero.',
  ];

  final List<String> _noMoneyDialogues = [
    'No tienes suficientes monedas.',
    'Vuelve cuando tengas más oro.',
    'Ese objeto cuesta más de lo que llevas.',
    'Necesitas ahorrar un poco más.',
  ];

  @override
  void initState() {
    super.initState();
    _vendorDialogue = _dialogues[Random().nextInt(_dialogues.length)];

    _controllers = List.generate(20, (_) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    ));

    _animations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    _loadPlayer();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPlayer() async {
    final character = await LocalStorageService().loadCharacter();
    if (character != null && mounted) {
      final player = PlayerStatus.fromCharacter(character);
      setState(() {
        _player = player;
        _filteredItems = storeItems.where((item) =>
          item.allowedClasses.isEmpty || item.allowedClasses.contains(player.characterClass)
        ).toList();
      });
    }
  }

  void _showWarningBanner(String message) {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 22, 22, 43),
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text(
              'CERRAR',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  void _setVendorDialogue(String message) {
    setState(() {
      _vendorDialogue = message;
    });
  }

  Future<void> _buyItem(StoreItem item) async {
    try {
      await PlayerService().buyItem(_player!, item);
      if (!mounted) return;
      setState(() {});
      _showWarningBanner('Compraste: ${item.name}');
      _setVendorDialogue(_purchaseDialogues[Random().nextInt(_purchaseDialogues.length)]);
    } catch (e) {
      if (!mounted) return;
      _showWarningBanner(e.toString());
      _setVendorDialogue(_noMoneyDialogues[Random().nextInt(_noMoneyDialogues.length)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_player == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/backgrounds/store_bg.png', fit: BoxFit.cover),
                Container(color: Colors.black.withOpacity(0.6)),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/coin_icon.png',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_player!.coins}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'MedievalSharp',
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: SizedBox(
                    width: 280,
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'MedievalSharp',
                      ),
                      child: AnimatedTextKit(
                        key: ValueKey(_vendorDialogue), // Fuerza reinicio de animación
                        animatedTexts: [
                          TypewriterAnimatedText(
                            _vendorDialogue,
                            speed: const Duration(milliseconds: 60),
                          ),
                        ],
                        totalRepeatCount: 1,
                        pause: const Duration(milliseconds: 1000),
                        displayFullTextOnTap: true,
                        stopPauseOnTap: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 4,
            width: double.infinity,
            color: const Color.fromARGB(180, 40, 40, 60),
          ),

          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgrounds/item_card_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Objetos Disponibles',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 253, 251, 251),
                      fontFamily: 'MedievalSharp',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        if (index < _controllers.length) {
                          Future.delayed(Duration(milliseconds: 100 * index), () {
                            if (mounted) _controllers[index].forward();
                          });
                        }

                        return SlideTransition(
                          position: _animations[index % _animations.length],
                          child: _buildItemCard(_filteredItems[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(StoreItem item) {
    final isSold = _player!.inventory.containsKey(item.id);
    return SizedBox(
      height: 220,
      child: Container(
        width: 110,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(121, 9, 12, 26).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(item.imageAsset, height: 100),
                  if (isSold)
                    Container(
                      height: 100,
                      color: Colors.black.withOpacity(0.6),
                      alignment: Alignment.center,
                      child: const Text(
                        'VENDIDO',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 19),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'MedievalSharp',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Text(
                item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                ' ${item.price}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _buyItem(item),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: const Color.fromARGB(190, 16, 19, 36),
                textStyle: const TextStyle(
                  fontFamily: 'MedievalSharp',
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              child: const Text('Comprar'),
            ),
          ],
        ),
      ),
    );
  }
}
