extends Control

@onready var boton_pedir: Button = $BotonPedir
@onready var boton_parar: Button = $BotonParar
@onready var label_puntos_jugador: Label = $PuntosJugador
@onready var label_puntos_crupier: Label = $PuntosCrupier
@onready var label_cartas_jugador: Label = $CartasJugador
@onready var label_cartas_crupier: Label = $CartasCrupier
@onready var label_mensaje: Label = $MensajeEstado

var vidas: int = 3
var nombre_jugador: String = "SanBaek"

var mazo: Array = []
var mano_jugador: Array = []
var mano_crupier: Array = []

func desactivar_botones() -> void:
	boton_pedir.disabled = true
	boton_parar.disabled = true

func actualizar_interfaz() -> void:
	# 1. Actualizamos puntos
	label_puntos_jugador.text = "Total: " + str(calcular_puntos(mano_jugador))
	label_puntos_crupier.text = "Total: " + str(calcular_puntos(mano_crupier))
	
	# 2. Formateamos las cartas del jugador para el Label
	var texto_cartas_j = "Tus Cartas:\n"
	for carta in mano_jugador:
		texto_cartas_j += str(carta["numero"]) + " " + carta["pinta"] + "\n"
	label_cartas_jugador.text = texto_cartas_j
	
	# 3. Formateamos las cartas del crupier
	var texto_cartas_c = "Cartas Crupier:\n"
	for carta in mano_crupier:
		texto_cartas_c += str(carta["numero"]) + " " + carta["pinta"] + "\n"
	label_cartas_crupier.text = texto_cartas_c

func crear_mazo() -> void:
	
	mazo.clear()
	
	var pintas = ["♠", "♥", "♦", "♣"]
	
	for pinta in pintas:
		for numero in range(1, 11):
			var carta = {"pinta": pinta, "numero": numero}
			mazo.append(carta)

func mezclar_mazo() -> void:
	mazo.shuffle()

func sacar_carta() -> Dictionary:
	
	if (mazo.is_empty()):
		crear_mazo()
		mezclar_mazo()
		
	return mazo.pop_back()

func calcular_puntos(mano:Array) -> int:
	
	var total: int = 0
	
	for carta in mano:
		total += carta["numero"]
	return total

func ver_cartas(mano:Array) -> void:
	for carta in mano:
		print("- ", carta["numero"], carta["pinta"])

func turno_crupier() -> void:
	print("\n--- TURNO DEL CRUPIER ---")
	
	while calcular_puntos(mano_crupier) < 19:
		mano_crupier.append(sacar_carta())
		ver_cartas(mano_crupier)	
		
		var puntos = calcular_puntos(mano_crupier)
	
		print("Total: ", puntos)
		
		actualizar_interfaz()
		
		if puntos == 21:
			print("¡El crupier hizo 21 puntos exactos!")
			print("¡PERDISTE!")
			desactivar_botones()
			return
		elif puntos > 21:
			print("El crupier se pasó de 21.")
			print("¡GANASTE!")
			desactivar_botones()
			return

	determinar_ganador()
	desactivar_botones()

func determinar_ganador() -> void:
	var puntos_j = calcular_puntos(mano_jugador)
	var puntos_c = calcular_puntos(mano_crupier)
	
	print("\n=== RESULTADO FINAL ===")
	print("Jugador: ", puntos_j, " pts | Crupier: ", puntos_c, " pts")
	
	if puntos_c > 21:
		print("¡El crupier se pasó! ¡GANASTE!")
	elif puntos_j > puntos_c:
		print("¡Superaste al crupier! ¡GANASTE!")
	elif puntos_c > puntos_j:
		print("El crupier gana.")
	else:
		print("¡Empate!")


#JUEGO PRINCIPAL
func _ready() -> void:
	print("--- INICIANDO PARTIDA DE DARKJACK ---")
	crear_mazo()
	mezclar_mazo()
	
	# Repartimos 2 cartas al jugador
	mano_jugador.append(sacar_carta())
	mano_jugador.append(sacar_carta())
	
	# Repartimos 2 cartas al crupier
	mano_crupier.append(sacar_carta())
	mano_crupier.append(sacar_carta())
	
	# Mostramos los resultados en la consola de salida
	print("Tus cartas: ")
	ver_cartas(mano_jugador)
	print("Total: ", calcular_puntos(mano_jugador))
	
	actualizar_interfaz()

#ACCIONES DE BOTONES
func boton_pedir_presionado() -> void:
	
	mano_jugador.append(sacar_carta())
	ver_cartas(mano_jugador)
	
	var puntos = calcular_puntos(mano_jugador)
	print("Total: ", puntos)
	
	if puntos == 21:
		print("¡GANASTE!")
		print("¡", nombre_jugador, " hizo 21 puntos exactos!")
		desactivar_botones()
	elif puntos > 21:
		print("¡Te pasaste de 21! Perdiste.")
		desactivar_botones()
	
	actualizar_interfaz()

func boton_parar_presionado() -> void:
	turno_crupier()
