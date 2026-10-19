extends Control
var juego_terminado: bool = false

#Cargamos la carta
const ESCENA_CARTA = preload("res://carta.tscn")
@onready var cartas_jugador_container: HBoxContainer = $CartasJugador
@onready var cartas_crupier_container: HBoxContainer = $CartasCrupier

const PantallaResultado = preload("res://pantalla_resultado.gd")

@onready var boton_pedir: Button = $Botones/BotonPedir
@onready var boton_parar: Button = $Botones/BotonParar
@onready var label_puntos_jugador: Label = $PuntosJugador
@onready var label_puntos_crupier: Label = $PuntosCrupier

	
var vidas: int = 3
var nombre_jugador: String = "SanBaek"

var mazo: Array = []
var mano_jugador: Array = []
var mano_crupier: Array = []


func agregar_carta_visual(numero: String, pinta: String, es_jugador: bool) -> void:

	var nueva_carta = ESCENA_CARTA.instantiate()
	var contenedor: HBoxContainer
	
	if es_jugador:
		contenedor = cartas_jugador_container
	else:
		contenedor = cartas_crupier_container
		
	# 3. La agregamos al contenedor
	contenedor.add_child(nueva_carta)
	
	# 4. Le pasamos el número y la pinta
	nueva_carta.configurar_carta(numero, pinta)

func desactivar_botones() -> void:
	boton_pedir.disabled = true
	boton_parar.disabled = true

func actualizar_interfaz() -> void:
	# Actualizamos puntos
	label_puntos_jugador.text = "Total: " + str(calcular_puntos(mano_jugador))
	label_puntos_crupier.text = "Total: " + str(calcular_puntos(mano_crupier))

func reiniciar_mesa() -> void:
	# Limpiamos las manos lógicas
	mano_jugador.clear()
	mano_crupier.clear()
	
	# Borramos físicamente las cartas visuales anteriores de los contenedores
	for n in cartas_jugador_container.get_children():
		n.queue_free()
	for n in cartas_crupier_container.get_children():
		n.queue_free()

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

func turno_crupier() -> void:
	print("\n--- TURNO DEL CRUPIER ---")
	
	while calcular_puntos(mano_crupier) < 17:
		await get_tree().create_timer(0.5).timeout
		var carta = sacar_carta()
		mano_crupier.append(carta)
		
		agregar_carta_visual(str(carta.numero), carta.pinta, false)
		
		var puntos = calcular_puntos(mano_crupier)
		print("Total: ", puntos)
		
		actualizar_interfaz()
		
		if puntos > 21:
			break

	determinar_ganador(true)
	desactivar_botones()


func determinar_ganador(es_fin_forzado: bool = false) -> void:
	var puntos_j = calcular_puntos(mano_jugador)
	var puntos_c = calcular_puntos(mano_crupier)

	# JUGADOR
	if puntos_j > 21:
		mostrar_resultado("PERDISTE", "Te pasaste de 21 puntos.", puntos_j, puntos_c)
		return

	if puntos_j == 21:
		mostrar_resultado("¡GANASTE!", "¡Hiciste 21 puntos exactos!", puntos_j, puntos_c)
		return

	# CRUPIER
	if puntos_c > 21:
		mostrar_resultado("¡GANASTE!", "El crupier se pasó de 21 puntos.", puntos_j, puntos_c)
		return
		
	if puntos_c == 21:
		mostrar_resultado("PERDISTE", "¡El crupier hizo 21 puntos exactos!", puntos_j, puntos_c)

	# COMPARAR 
	if es_fin_forzado:
		if puntos_j > puntos_c:
			mostrar_resultado("¡GANASTE!", "Te acercaste más a 21.", puntos_j, puntos_c)
		elif puntos_j < puntos_c:
			mostrar_resultado("PERDISTE", "El crupier se acercó más a 21.", puntos_j, puntos_c)
		else:
			mostrar_resultado("Empate", "Ambos obtuvieron el mismo puntaje.", puntos_j, puntos_c)

func mostrar_resultado(titulo: String, detalle: String, pts_j: int, pts_c: int):
	if juego_terminado:
		return
		
	juego_terminado = true
	
	# Deshabilitar botones de la mesa
	$Botones/BotonPedir.disabled = true
	$Botones/BotonParar.disabled = true
	
	var popup = $PantallaResultado/PantallaResultado
	
	popup.cargar_datos({
		"titulo": titulo,
		"descripcion": detalle,
		"pts_jugador": pts_j,
		"pts_crupier": pts_c
	})
	
	await get_tree().create_timer(0.5).timeout
	$PantallaResultado.visible = true


#JUEGO PRINCIPAL
func _ready() -> void:
	print("--- INICIANDO PARTIDA DE DARKJACK ---")
	crear_mazo()
	mezclar_mazo()
	
	mano_jugador.clear()
	
	# Repartimos 2 cartas al jugador
	for i in range(2):
		var carta_j = sacar_carta()
		mano_jugador.append(carta_j)
		agregar_carta_visual(str(carta_j.numero), carta_j.pinta, true)
	
	# Repartimos 2 cartas al crupier
	for j in range(2):
		var carta_c = sacar_carta()
		mano_crupier.append(carta_c)
		agregar_carta_visual(str(carta_c.numero), carta_c.pinta, false)
	
	
	# Mostramos los resultados en la consola de salida
	print("Tus cartas: ")
	print("Total: ", calcular_puntos(mano_jugador))
	
	actualizar_interfaz()


#ACCIONES DE BOTONES
func boton_pedir_presionado() -> void:
	
	if juego_terminado:
		return
	
	await get_tree().create_timer(0.5).timeout
	#lo pongo aquí?
	
	var nueva_carta = sacar_carta()
	mano_jugador.append(nueva_carta)
	
	agregar_carta_visual(str(nueva_carta.numero), nueva_carta.pinta, true)
	
	var puntos = calcular_puntos(mano_jugador)
	print("Total: ", puntos)
	
	actualizar_interfaz()

	determinar_ganador(false)

func boton_parar_presionado() -> void:
	turno_crupier()
