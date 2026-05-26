# TODO: Sistema de Misiones Narrativas

## Archivos Nuevos a Crear
- [x] lib/models/step_type.dart — Enum StepType (hangman, puzzle, combat)
- [x] lib/models/npc_dialogue.dart — Clase NpcDialogue
- [x] lib/models/mission_step.dart — Clase MissionStep
- [x] lib/models/narrative_mission.dart — Clase NarrativeMission
- [x] lib/data/narrative_missions.dart — Misión "El Encuentro" (3 pasos: Ahorcado, Rompecabezas, Combate)
- [x] lib/ui/screens/narrative_mission_screen.dart — Orquestador de flujo narrativo (máquina de estados)

## Archivos Modificados
- [x] lib/ui/screens/hangman_screen.dart — onComplete cambiado a Function(bool)?
- [x] lib/ui/screens/memory_game_screen.dart — onComplete cambiado a Function(bool)?
- [x] lib/ui/screens/trivia_combat_screen.dart — onComplete cambiado a Function(bool)?, rewards condicionales
- [x] lib/ui/screens/home_screen.dart — Sección "Misiones Narrativas" con tarjetas distintivas

## Pasos de Verificación
- [ ] Verificar que las misiones existentes siguen funcionando
- [ ] Verificar que la misión narrativa fluye correctamente paso a paso
- [ ] Verificar que las recompensas se dan al final de la misión completa
