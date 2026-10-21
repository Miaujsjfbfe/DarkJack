extends Control


func boton_jugar_presionado() -> void:
	# Cambia la escena a la mesa de juego
	get_tree().change_scene_to_file("res://mesa_juego.tscn")

func boton_salir_presionado() -> void:
	# Cierra el juego
	get_tree().quit()


# Efectos visuales de toque
func _input(event: InputEvent) -> void:
	var posicion_toque: Vector2 = Vector2.ZERO
	var disparar_efecto: bool = false
	
	# Detectar click izquierdo del mouse
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		posicion_toque = event.position
		disparar_efecto = true
		
	# Detectar toque en pantallas táctiles / móviles
	elif event is InputEventScreenTouch and event.pressed:
		posicion_toque = event.position
		disparar_efecto = true
		
	if disparar_efecto:
		crear_efecto_toque(posicion_toque)

# Crea el símbolo flotante en el lugar exacto del toque
func crear_efecto_toque(pos: Vector2) -> void:
	var efecto = Label.new()
	efecto.text = "✨" # Puedes cambiarlo por un punto "•", una estrella o el símbolo que quieras
	efecto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	efecto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	efecto.position = pos - Vector2(15, 15)
	
	# Lo agregamos al menú principal
	add_child(efecto)
	
	# Animación suave: sube 30px y se vuelve transparente
	var tween = create_tween().set_parallel(true)
	tween.tween_property(efecto, "position:y", efecto.position.y - 30, 0.4)
	tween.tween_property(efecto, "modulate:a", 0.0, 0.4)
	
	# Se borra solo al finalizar la animación
	tween.chain().tween_callback(efecto.queue_free)



# Referencia a la escena de reglas (puedes precargarla)
const ESCENA_REGLAS = preload("res://reglas.tscn")

# Esta función la conectas con la señal "pressed" de tu botón Reglas
func boton_reglas_presionado() -> void:
	var ventana_reglas = ESCENA_REGLAS.instantiate()
	get_tree().current_scene.add_child(ventana_reglas)
	
	
