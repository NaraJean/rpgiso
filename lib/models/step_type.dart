/// Define la función narrativa de un paso dentro de una misión.
///
/// IMPORTANTE:
/// StepType NO representa el minijuego concreto.
/// StepType representa qué papel cumple el paso dentro de la historia.
///
/// Ejemplo:
/// - story: solo narración.
/// - dialogue: conversación con NPC.
/// - concept: explicación educativa.
/// - minigame: lanza una mecánica jugable.
/// - combat: combate normal.
/// - bossCombat: combate especial de jefe.
/// - event: consecuencia narrativa.
/// - closing: cierre de misión.
enum StepType {
  /// Paso narrativo donde se describe una escena, lugar o situación.
  story,

  /// Paso centrado en diálogo con un NPC o enemigo.
  dialogue,

  /// Paso educativo donde se explica el concepto real de ciberseguridad.
  concept,

  /// Paso que lanza un minijuego.
  minigame,

  /// Paso de evento narrativo posterior a una acción del jugador.
  event,

  /// Paso de combate normal.
  combat,

  /// Paso de combate especial contra jefe.
  bossCombat,

  /// Paso de cierre narrativo antes de entregar recompensas.
  closing,

  /// Paso de recompensa o resultado final.
  reward,
}