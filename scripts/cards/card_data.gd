class_name CardData
extends Resource

enum Rarity { COMMON, RARE, EPIC, LEGENDARY }
enum State { LOCKED, UNLOCKED, OWNED_IN_RUN }

@export var id := ""
@export var display_name := ""
@export_multiline var description := ""
@export var rarity := Rarity.COMMON
@export var icon: Texture2D
@export var tags: Array[String] = []
@export var effect: CardEffect
@export var is_boss_card := false
@export var boss_id := ""
