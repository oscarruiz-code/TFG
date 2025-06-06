/// Archivo central de importaciones para el proyecto TFG.
/// 
/// Este archivo exporta todas las dependencias externas y clases internas
/// utilizadas en el proyecto, permitiendo importar todo lo necesario
/// con una sola línea: `import 'package:oscarruizcode_pingu/dependencias/imports.dart';`

//===============================================
/// DEPENDENCIAS EXTERNAS
/// 
/// Paquetes y librerías de Flutter y Dart necesarios para el proyecto.
//===============================================
export 'package:flutter/material.dart';
export 'dart:math';
export 'package:video_player/video_player.dart';
export 'package:audioplayers/audioplayers.dart';
export 'package:mysql1/mysql1.dart';
export 'package:flutter/foundation.dart';
export 'dart:async';

//===============================================
/// CLASES
/// 
/// Componentes internos del proyecto organizados por categorías.
//===============================================

/// Pantalla de inicio con animación de logo
export 'package:oscarruizcode_pingu/screens/Splash/logo.dart';

/// Módulos de administración
export 'package:oscarruizcode_pingu/screens/pages/administradores/menus/admin_menu.dart';
export 'package:oscarruizcode_pingu/screens/pages/administradores/listas/user_detalles.dart';
export 'package:oscarruizcode_pingu/screens/pages/administradores/listas/user_lista.dart';
export 'package:oscarruizcode_pingu/screens/pages/administradores/menus/admin_register.dart';

/// Pantallas de autenticación
export 'package:oscarruizcode_pingu/screens/pages/iniciales/login.dart';
export 'package:oscarruizcode_pingu/screens/pages/iniciales/register.dart';

/// Menús principales de la aplicación
export 'package:oscarruizcode_pingu/screens/pages/menus/menuhistorial.dart';
export 'package:oscarruizcode_pingu/screens/pages/menus/menuinicio.dart';
export 'package:oscarruizcode_pingu/screens/pages/menus/menuopcion.dart';
export 'package:oscarruizcode_pingu/screens/pages/menus/menutienda.dart';
export 'package:oscarruizcode_pingu/screens/pages/menus/menu_editar_perfil.dart';

/// Sistema de eventos del juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/eventos/eventos.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/eventos/game_eventos.dart';

/// Personajes del juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/personajes/manejador/player_principal.dart';

/// Modulos del Personaje
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/personajes/modulos/player_potenciadores.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/personajes/modulos/player_animaciones.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/personajes/modulos/player_checkpoint.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/personajes/modulos/player_colision.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/personajes/modulos/player_movimiento.dart';




/// Animaciones del personaje en el juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/animaciones/deslizarse/deslizarse.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/animaciones/andar/andar.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/animaciones/saltar/salto.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/animaciones/agachado/agacharse.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/animaciones/andar/andar_agachado.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/animaciones/saltar/salto_agachado.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/animaciones/deslizarse/deslizarse_agachado.dart';

/// Sistema de colisiones del juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/colisiones/tipos/colision_suelo.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/colisiones/tipos/colision_casa.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/colisiones/tipos/colision_item.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/colisiones/manejador/colision_manager.dart';

/// Mapas del juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/mapa/mapa1.dart';

/// Controles y botones de acción del juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/funcionalidades/action_buttons.dart';

/// Estructuras y elementos del escenario del juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/objetos/estructuras/suelo.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/objetos/estructuras/suelo2.dart';

/// Objetos meta del juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/objetos/meta/casa.dart';

/// Sistema de monedas y coleccionables del juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/objetos/monedas/moneda_base.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/objetos/monedas/moneda_normal.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/objetos/monedas/moneda_salto.dart';
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/objetos/monedas/moneda_velocidad.dart';

/// Pantalla principal del juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/pages/game1.dart';

/// Controles del juego 1
export 'package:oscarruizcode_pingu/screens/pages/games/juego1/widgets/joystik.dart';

/// Juego 2
export 'package:oscarruizcode_pingu/screens/pages/games/juego2/game2.dart';

/// Conexión a base de datos
export 'package:oscarruizcode_pingu/servicios/conexion/mysql_connection.dart';

/// Entidades y modelos de datos
export 'package:oscarruizcode_pingu/servicios/entity/admin.dart';
export 'package:oscarruizcode_pingu/servicios/entity/user.dart';
export 'package:oscarruizcode_pingu/servicios/entity/player.dart';
export 'package:oscarruizcode_pingu/servicios/entity/subadmin.dart';

/// Servicios para la lógica de negocio
export 'package:oscarruizcode_pingu/servicios/sevices/administradores/service/admin_service.dart';
export 'package:oscarruizcode_pingu/servicios/sevices/administradores/consultas/consultas_administradores.dart';

export 'package:oscarruizcode_pingu/servicios/sevices/usuarios/service/user_service.dart';
export 'package:oscarruizcode_pingu/servicios/sevices/usuarios/consultas/consultas_user.dart';

export 'package:oscarruizcode_pingu/servicios/sevices/jugadores/service/player_service.dart';
export 'package:oscarruizcode_pingu/servicios/sevices/jugadores/consultas/consultas_jugadores.dart';


/// Widgets de animación reutilizables
export 'package:oscarruizcode_pingu/widgets/animacion/animacion_texto.dart';
export 'package:oscarruizcode_pingu/widgets/animacion/glass_container.dart';
export 'package:oscarruizcode_pingu/widgets/animacion/animacion_revelado.dart';
export 'package:oscarruizcode_pingu/widgets/animacion/transicion.dart';

/// Recursos multimedia y servicios relacionados
export 'package:oscarruizcode_pingu/widgets/recursos/music_service.dart';
export 'package:oscarruizcode_pingu/widgets/recursos/video_background.dart';
export 'package:oscarruizcode_pingu/widgets/recursos/efectos_sonidos.dart';


/// Widgets compartidos entre pantallas
export 'package:oscarruizcode_pingu/widgets/widgets/shared_widgets.dart';
export 'package:oscarruizcode_pingu/widgets/widgets/game_over_dialog.dart';






