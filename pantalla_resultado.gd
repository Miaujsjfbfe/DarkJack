extends Control

@onready var mensaje_ganador = $MensajeGanador
@onready var descripcion = $Descripcion
@onready var puntos_crupier = $PuntosCrupier
@onready var puntos_jugador = $PuntosJugador

static var datos_partida = {
	"titulo": "Resultado",
	"descripcion": "",
	"pts_jugador": 0,
	"pts_crupier": 0
}

func _ready():
	# Cargar los datos reales recibidos de la partida
	mensaje_ganador.text = datos_partida["titulo"]
	descripcion.text = datos_partida["descripcion"]
	puntos_jugador.text = "Puntos Jugador: " + str(datos_partida["pts_jugador"])
	puntos_crupier.text = "Puntos Crupier: " + str(datos_partida["pts_crupier"])
	
	# Conectar las señales de los botones
	$JugarDenuevo.pressed.connect(boton_jugardenuevo_presionado)
	$Salir.pressed.connect(boton_salir_presionado)

func boton_jugardenuevo_presionado():
	# Reinicia la mesa de juego para una nueva partida
	get_tree().change_scene_to_file("res://mesa_juego.tscn")

func boton_salir_presionado():
	# Vuelve al menú principal
	get_tree().change_scene_to_file("res://menu_principal.tscn")
