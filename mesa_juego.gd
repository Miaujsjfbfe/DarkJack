extends Control
var juego_terminado: bool = false

#Cargamos la carta
const ESCENA_CARTA = preload("res://carta.tscn")
@onready var cartas_jugador_container: HBoxContainer = $CartasJugador
@onready var cartas_crupier_container: HBoxContainer = $CartasCrupier

const PantallaResultado = preload("res://pantalla_resultado.gd")

@onready var boton_pedir: Button = $BotonPedir
@onready var boton_parar: Button = $BotonParar
@onready var label_puntos_jugador: Label = $PuntosJugador
@onready var label_puntos_crupier: Label = $PuntosCrupier

@onready var label_marcador = $Puntos # Asegúrate de que la ruta coincida con el nombre de tu nodo

var vidas: int = 3
var nombre_jugador: String = "SanBaek"

var mazo: Array = []
var mano_jugador: Array = []
var mano_crupier: Array = []

var carta_oculta_revelada: bool = false


func agregar_carta_visual(numero: String, pinta: String, es_jugador: bool, oculta: bool) -> void:
	var nueva_carta = ESCENA_CARTA.instantiate()
	var contenedor: HBoxContainer
	
	if es_jugador:
		contenedor = cartas_jugador_container
	else:
		contenedor = cartas_crupier_container

	contenedor.add_child(nueva_carta)
	
	await get_tree().process_frame
	
	if not is_instance_valid(nueva_carta):
		return
	
	nueva_carta.pivot_offset = nueva_carta.size / 2.0
	
	if nueva_carta.has_method("mostrar_dorso"):
		nueva_carta.mostrar_dorso()
		
	# SI ES OCULTA: No hacemos la animación de revelación, se queda en mostrar_dorso()
	if oculta:
		return
		
	# SI NO ES OCULTA
	var tween = create_tween()
	
	tween.tween_property(nueva_carta, "scale:x", 0.0, 0.2)
	
	tween.tween_callback(func():
		if is_instance_valid(nueva_carta):
			nueva_carta.configurar_carta(numero, pinta)
	)
	
	tween.tween_property(nueva_carta, "scale:x", 1.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)		

func desactivar_botones() -> void:
	boton_pedir.disabled = true
	boton_parar.disabled = true

func actualizar_interfaz() -> void:

	label_puntos_jugador.text = "Total " + nombre_jugador +" : " + str(calcular_puntos(mano_jugador))
	#label_puntos_crupier.text = "Total: " + str(calcular_puntos(mano_crupier))
	
	var puntos_c: int = 0
	if not carta_oculta_revelada and mano_crupier.size() >= 2:
		# Si la carta está tapada y tiene sus 2 cartas iniciales,
		# calculamos solo desde la segunda carta en adelante:
		var mano_visible = mano_crupier.duplicate()
		mano_visible.pop_front() # Quitamos la primera carta (la tapada)
		puntos_c = calcular_puntos(mano_visible)
		
		label_puntos_crupier.text = "Total Crupier: " + str(puntos_c)
	else:
		# Si ya es el turno del crupier y la carta se reveló, calculamos toda la mano
		puntos_c = calcular_puntos(mano_crupier)
		label_puntos_crupier.text = "Total Crupier: " + str(puntos_c)

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

func revelar_carta_oculta_crupier() -> void:
	if cartas_crupier_container.get_child_count() > 0:
		var primera_carta = cartas_crupier_container.get_child(0)
		var datos_carta = mano_crupier[0] # La primera carta de la lista de datos
		
		var tween = create_tween()
		tween.tween_property(primera_carta, "scale:x", 0.0, 0.2)
		tween.tween_callback(func():
			if is_instance_valid(primera_carta):
				primera_carta.configurar_carta(str(datos_carta.numero), datos_carta.pinta)
		)
		tween.tween_property(primera_carta, "scale:x", 1.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func turno_crupier() -> void:
	var puntos_j = calcular_puntos(mano_jugador)
	
	revelar_carta_oculta_crupier()
	
	carta_oculta_revelada = true
	actualizar_interfaz() # Ahora sí calculará la mano completa y mostrará el total real
	
	while calcular_puntos(mano_crupier) < 20:
		await get_tree().create_timer(0.8).timeout
		var carta = sacar_carta()
		mano_crupier.append(carta)
		
		agregar_carta_visual(str(carta.numero), carta.pinta, false, false)
		
		var puntos = calcular_puntos(mano_crupier)
		print("Total: ", puntos)
		
		actualizar_interfaz()
		
		if puntos > puntos_j:
			break

		if puntos > 21:
			break

	determinar_ganador(true)
	desactivar_botones()

func puntaje_guardado(es_jugador: bool = true) -> void:
	if es_jugador:
		GestorGeneral.partidas_ganadas += 1
		GestorGeneral.guardar_datos()
		actualizar_label_marcador()
	elif !es_jugador:
		GestorGeneral.partidas_perdidas += 1
		GestorGeneral.guardar_datos()
		actualizar_label_marcador()

func determinar_ganador(es_fin_forzado: bool = false) -> void:
	var puntos_j = calcular_puntos(mano_jugador)
	var puntos_c = calcular_puntos(mano_crupier)
	
	# JUGADOR
	if puntos_j > 21:
		mostrar_resultado("PERDISTE", "Te pasaste de 21 puntos.", puntos_j, puntos_c)
		puntaje_guardado(false)
		return

	if puntos_j == 21:
		mostrar_resultado("¡GANASTE!", "¡Hiciste 21 puntos exactos!", puntos_j, puntos_c)
		puntaje_guardado(true)
		return

	# CRUPIER
	if puntos_c > 21:
		mostrar_resultado("¡GANASTE!", "El crupier se pasó de 21 puntos.", puntos_j, puntos_c)
		puntaje_guardado(true)
		return
		
	if puntos_c == 21:
		mostrar_resultado("PERDISTE", "¡El crupier hizo 21 puntos exactos!", puntos_j, puntos_c)
		puntaje_guardado(false)
		return
		
	# COMPARAR 
	if es_fin_forzado:
		if puntos_j > puntos_c:
			mostrar_resultado("¡GANASTE!", "Te acercaste más a 21.", puntos_j, puntos_c)
			puntaje_guardado(true)
		elif puntos_j < puntos_c:
			mostrar_resultado("PERDISTE", "El crupier se acercó más a 21.", puntos_j, puntos_c)
			puntaje_guardado(false)
		else:
			mostrar_resultado("Empate", "Ambos obtuvieron el mismo puntaje.", puntos_j, puntos_c)

func mostrar_resultado(titulo: String, detalle: String, pts_j: int, pts_c: int):
	if juego_terminado:
		return
		
	juego_terminado = true
	
	# Deshabilitar botones de la mesa
	$BotonPedir.disabled = true
	$BotonParar.disabled = true
	
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
	# Cargar los datos guardados al iniciar
	GestorGeneral.cargar_datos()
	actualizar_label_marcador()
	
	print("--- INICIANDO PARTIDA DE DARKJACK ---")
	crear_mazo()
	mezclar_mazo()
	
	mano_jugador.clear()
	
	# Repartimos 2 cartas al jugador
	for i in range(2):
		var carta_j = sacar_carta()
		mano_jugador.append(carta_j)
		agregar_carta_visual(str(carta_j.numero), carta_j.pinta, true, false)
	
	# Repartimos 2 cartas al crupier
	for j in range(2):
		var carta_c = sacar_carta()
		mano_crupier.append(carta_c)
		
		var aux: bool = true
	
		if j == 1:
			aux = false
		
		agregar_carta_visual(str(carta_c.numero), carta_c.pinta, false, aux)
	
	# Mostramos los resultados en la consola de salida
	print("Tus cartas: ")
	print("Total: ", calcular_puntos(mano_jugador))
	
	actualizar_interfaz()

func actualizar_label_marcador() -> void:
	if label_marcador:
		label_marcador.text = "Victorias: " + str(GestorGeneral.partidas_ganadas)


#ACCIONES DE BOTONES
func boton_pedir_presionado() -> void:
	
	if juego_terminado:
		return
	
	#await get_tree().create_timer(0.3).timeout
	#lo pongo aquí?
	
	var nueva_carta = sacar_carta()
	mano_jugador.append(nueva_carta)
	
	agregar_carta_visual(str(nueva_carta.numero), nueva_carta.pinta, true, false)
	
	var puntos = calcular_puntos(mano_jugador)
	print("Total: ", puntos)
	
	actualizar_interfaz()

	determinar_ganador(false)

func boton_parar_presionado() -> void:
	turno_crupier()
