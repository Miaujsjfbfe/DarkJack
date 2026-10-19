extends Control

@onready var mensaje_ganador = $MensajeGanador
@onready var descripcion = $Descripcion
@onready var puntos_crupier = $PuntosCrupier
@onready var puntos_jugador = $PuntosJugador

var datos_partida = {
	"titulo": "Resultado",
	"descripcion": "",
	"pts_jugador": 0,
	"pts_crupier": 0
}

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	actualizar_interfaz()

func cargar_datos(datos: Dictionary):
	datos_partida = datos
	if is_node_ready():
		actualizar_interfaz()

func actualizar_interfaz():
	mensaje_ganador.text = datos_partida["titulo"]
	descripcion.text = datos_partida["descripcion"]
	puntos_jugador.text = "Puntos Jugador: " + str(datos_partida["pts_jugador"])
	puntos_crupier.text = "Puntos Crupier: " + str(datos_partida["pts_crupier"])

func boton_jugardenuevo_presionado():
	# Reinicia la mesa de juego para una nueva partida
	get_tree().reload_current_scene()

func boton_salir_presionado():
	# Vuelve al menú principal
	get_tree().change_scene_to_file("res://menu_principal.tscn")
