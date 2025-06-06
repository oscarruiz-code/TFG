/// Clase que define las constantes para los tipos de eventos del juego.
///
/// Centraliza todos los nombres de eventos disponibles en el juego para
/// evitar errores tipográficos y facilitar la refactorización.
class GameEvents {
  static const String playerJump = 'player_jump';
  static const String playerSlide = 'player_slide';
  static const String playerCollision = 'player_collision';
  static const String scoreUpdate = 'score_update';
  static const String gameOver = 'game_over';
  static const String playerMove = 'player_move';
  static const String playerIdle = 'player_idle';
  static const String playerEndSlide = 'player_end_slide';
  static const String playerSlideProgress = 'player_slide_progress'; 
  static const String playerUpdatePosition = 'player_update_position';
  static const String playerLand = 'player_land';
  static const String buttonPressed = 'button_pressed';
  static const String joystickMoved = 'joystick_moved';
  static const String distanceUpdated = 'distance_updated';
  static const String playerCrouch = 'player_crouch';
  static const String playerStandUp = 'player_stand_up';
  static const String playerUpdateAnimation = 'player_update_animation';
  static const String checkpointSet = 'checkpoint_set';
  static const String playerRespawn = 'player_respawn';
  static const String coinCollected = 'coin_collected';
  static const String playerCollisionTop = 'player_collision_top';
  static const String playerCollisionBottom = 'player_collision_bottom';
  static const String playerCollisionWithHouse = 'player_collision_with_house'; 
  static const String playerInVoid = 'player_in_void'; 
  static const String playerStateChange = 'player_state_change';
}
