extends Control

@onready var dorso = $Dorso
@onready var frente = $Frente
@onready var texto_carta = $Frente/TextoCarta
@onready var imagenDorso = $Dorso/FondoDorso

const TEXTURA_DORSO = preload("res://fotos/dorso_carta.jpg.jpg")

#C:\Users\pazoy\Desktop\JACK

# Función para configurar los datos y mostrar el frente
func configurar_carta(numero: String, pinta: String) -> void:
	texto_carta.text = numero + "\n" + pinta

	# Cambiamos visibilidad: ocultamos dorso, mostramos frente
	dorso.visible = false
	frente.visible = true

# Función para dejarla boca abajo (por si se necesita)
func mostrar_dorso() -> void:
	frente.visible = false
	dorso.visible = true
	imagenDorso.texture = TEXTURA_DORSO
