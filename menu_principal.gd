extends Control


func boton_jugar_presionado() -> void:
	# Cambia la escena a la mesa de juego
	get_tree().change_scene_to_file("res://mesa_juego.tscn")

func boton_reglas_presionado() -> void:
	print("Mostrando reglas...")

func boton_salir_presionado() -> void:
	# Cierra el juego
	get_tree().quit()
