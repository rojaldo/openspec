extends RefCounted
## Tabla de puntuaciones persistente en almacenamiento local del usuario.
## Robusta ante archivo ausente o corrupto (se trata como tabla vacia).

const MAX_ENTRIES := 10
const DEFAULT_NAME := "JUGADOR"
const DEFAULT_PATH := "user://scores.json"

var path := DEFAULT_PATH


func _init(p: String = DEFAULT_PATH) -> void:
	path = p


func load_entries() -> Array:
	if not FileAccess.file_exists(path):
		return []
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return []
	var json := JSON.new()
	if json.parse(f.get_as_text()) != OK:
		return []
	var parsed = json.data
	if typeof(parsed) != TYPE_ARRAY:
		return []
	var out: Array = []
	for item in parsed:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		if not (item.has("name") and item.has("score")):
			continue
		out.append({
			"id": int(item.get("id", 0)),
			"name": str(item["name"]),
			"score": int(item["score"]),
			"level": int(item.get("level", 0)),
		})
	return rank(out)


func save_entries(entries: Array) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(entries))


## Anade una puntuacion (con nombre por defecto si viene vacio) y devuelve
## la entrada creada y la tabla resultante. El nivel alcanzado es opcional.
func submit(raw_name: String, score: int, level: int = 0) -> Dictionary:
	var entries := load_entries()
	var entry := {
		"id": _next_id(entries),
		"name": _clean_name(raw_name),
		"score": score,
		"level": level,
	}
	entries.append(entry)
	entries = rank(entries)
	save_entries(entries)
	return {"entry": entry, "entries": entries}


## Cambia el nombre de una entrada ya registrada (por su id).
func rename(id: int, raw_name: String) -> Array:
	var entries := load_entries()
	for e in entries:
		if int(e["id"]) == id:
			e["name"] = _clean_name(raw_name)
	entries = rank(entries)
	save_entries(entries)
	return entries


static func rank(entries: Array) -> Array:
	var sorted := entries.duplicate()
	sorted.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	if sorted.size() > MAX_ENTRIES:
		sorted.resize(MAX_ENTRIES)
	return sorted


static func _clean_name(raw_name: String) -> String:
	var name := raw_name.strip_edges()
	return DEFAULT_NAME if name.is_empty() else name


static func _next_id(entries: Array) -> int:
	var top := 0
	for e in entries:
		top = maxi(top, int(e["id"]))
	return top + 1
