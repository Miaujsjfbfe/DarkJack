extends Node

var nombre_jugador: String = ""
var partidas_ganadas: int = 0
var partidas_perdidas: int = 0

#var volumen_musica: float = 1.0
#var volumen_sfx: float = 1.0
var efectos_tactiles_activos: bool = true

# ruta guardado local
const RUTA_GUARDADO = "user://datos_jugador.json"

# Guardar datos en disco (JSON)
func guardar_datos() -> void:
	var datos = {
		"nombre_jugador": nombre_jugador,
		"partidas_ganadas": partidas_ganadas,
		"partidas_perdidas": partidas_perdidas,
		#"volumen_musica": volumen_musica,
		#"volumen_sfx": volumen_sfx,
		"efectos_tactiles_activos": efectos_tactiles_activos
	}
	
	var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.WRITE)
	if archivo:
		var json_string = JSON.stringify(datos)
		archivo.store_string(json_string)
		archivo.close()

# Cargar datos desde disco (JSON)
func cargar_datos() -> bool:
	if FileAccess.file_exists(RUTA_GUARDADO):
		var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.READ)
		var json_string = archivo.get_as_text()
		archivo.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var datos = json.get_data()
			nombre_jugador = datos.get("nombre_jugador", "")
			partidas_ganadas = datos.get("partidas_ganadas", 0)
			partidas_perdidas = datos.get("partidas_perdidas", 0)
			#volumen_musica = datos.get("volumen_musica", 1.0)
			#volumen_sfx = datos.get("volumen_sfx", 1.0)
			efectos_tactiles_activos = datos.get("efectos_tactiles_activos", true)
			return true
	return false
