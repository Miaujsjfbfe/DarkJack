extends PanelContainer

@onready var texto_carta: Label = $TextoCarta


func configurar_carta(numero: String, pinta: String) -> void:
	# Cambia el texto del Label dinámicamente
	
	texto_carta.text = numero + "\n" + pinta
	
