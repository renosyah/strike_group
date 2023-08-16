extends Inventory
class_name Weapon

signal weapon_reloaded(weapon)

export var fire_animation :String
export var reload_animation :String

export var unit_attack_damage :int

export var attack_damage :int
export var attack_delay :float
export var reload_delay :float

export var attack_range :float
export var spread :float
export var critical_chance :float = 0.1

export var ammo :int
export var max_ammo :int

export var ammo_pool :int
export var max_ammo_pool :int

export var projectile :PackedScene
export var barrel_position :NodePath

var is_unlimited :bool

var target # BaseUnit or BaseBuilding

var _barrel_position :Spatial
var _bullets :Array = []
var _reload_timer :Timer

var _weapon_mods :Dictionary = {}

onready var _final_damage :int = get_attack_damage()
onready var _final_crit :float = get_crit()
onready var _final_spread :float = clamp(get_spread(), 0, 5)
onready var _final_reload_delay :float = get_reload_delay()
onready var _final_max_ammo :int = get_max_ammo()

func _ready():
	_reload_timer = Timer.new()
	_reload_timer.wait_time = reload_delay
	_reload_timer.one_shot = true
	_reload_timer.connect("timeout", self, "_reload_finish")
	add_child(_reload_timer)
	
	_barrel_position = get_node_or_null(barrel_position)
	
	yield(get_tree(), "idle_frame")
	prepare_projectile()
	
func prepare_projectile():
	var last_index = get_tree().get_root().get_child_count() - 1
	
	for _i in 10:
		var bullet :Projectile = projectile.instance()
		bullet.connect("reach", self , "on_bullet_reach_target")
		get_tree().get_root().get_child(last_index).add_child(bullet)
		_bullets.append(bullet)
		
		
func on_bullet_reach_target(_projectile :Projectile, _target):
	if not is_master:
		return
		
	if not is_instance_valid(_target):
		return
		
	var modifier :int = int(_final_damage * 0.25)
	var damage :int = int(rand_range(_final_damage - modifier, _final_damage + modifier))
	damage += damage if (_final_crit > randf()) else 0
	
	if _target is BaseUnit:
		_target.take_damage(damage, _projectile.get_direction(), player_id)
		
	elif _target is BaseBuilding:
		# damage to building should be diffrent
		# latter maybe
		_target.take_damage(damage)
	
func queue_free():
	for i in _bullets:
		i.queue_free()
		
	.queue_free()
	
func fire():
	if not is_instance_valid(target):
		return
		
	if not has_ammo():
		return
		
	for i in _bullets:
		var bullet :Projectile = i
		if bullet.is_launching():
			continue
			
		bullet.target = target
		bullet.spread = _final_spread
		bullet.translation = _barrel_position.global_transform.origin
		bullet.launch()
		
		ammo -= 1
		return
		
func reload():
	if is_reloading():
		return
		
	# remain ammo back to total
	ammo_pool = ammo_pool + ammo
	
	if not can_reload():
		return
		
	ammo = 0
	
	_reload_timer.wait_time = _final_reload_delay
	_reload_timer.start()

func has_ammo() -> bool:
	return ammo > 0

func can_reload() -> bool:
	return ammo_pool > 0

func is_reloading() -> bool:
	return not _reload_timer.is_stopped()
	
func reload_time_left() -> float:
	return _reload_timer.time_left
	
func _reload_finish():
	# unlimited ammo
	if is_unlimited:
		ammo = _final_max_ammo
		emit_signal("weapon_reloaded", self)
		return
		
	# fresh new ammo
	# if ammo pool still have ammo
	if (ammo_pool - _final_max_ammo) >= 0:
		ammo = _final_max_ammo
		ammo_pool = (ammo_pool - ammo)
		emit_signal("weapon_reloaded", self)
		return
		
	ammo = ammo + ammo_pool
	ammo_pool = 0
	emit_signal("weapon_reloaded", self)
	
func add_weapon_mod(_mod :WeaponMod):
	if _weapon_mods.has(_mod.type_mod):
		return
		
	_weapon_mods[_mod.type_mod] = _mod
	apply_mod()
	
func remove_weapon_mod(_mod :WeaponMod):
	if _weapon_mods.has(_mod.type_mod):
		_weapon_mods.erase(_mod.type_mod)
		
	apply_mod()
	
func apply_mod():
	_final_damage = get_attack_damage()
	_final_crit = get_crit()
	_final_spread = clamp(get_spread(), 0, 5)
	_final_reload_delay = get_reload_delay()
	_final_max_ammo = get_max_ammo()
	
	ammo = _final_max_ammo
	
func get_spread() -> float:
	var final_value :float = spread
	if _weapon_mods.has(WeaponMod.typeMod.grip):
		var mod :WeaponMod = _weapon_mods[WeaponMod.typeMod.grip]
		final_value -= spread * mod.dec_spread_bonus
		
	return clamp(final_value, 0 , 5)
	
func get_attack_range() -> float:
	var final_value :float = attack_range
	if _weapon_mods.has(WeaponMod.typeMod.scope):
		var mod :WeaponMod = _weapon_mods[WeaponMod.typeMod.scope]
		final_value += attack_range * mod.inc_range_bonus
		
	return final_value
	
func get_crit() -> float:
	var final_value :float = critical_chance
	if _weapon_mods.has(WeaponMod.typeMod.barel):
		var mod :WeaponMod = _weapon_mods[WeaponMod.typeMod.barel]
		final_value += mod.inc_crit_bonus
		
	return clamp(final_value, 0, 8)
	
func get_attack_damage() -> int:
	var final_value :float = attack_range
	if _weapon_mods.has(WeaponMod.typeMod.receiver):
		var mod :WeaponMod = _weapon_mods[WeaponMod.typeMod.receiver]
		final_value += attack_range * mod.inc_attack_bonus
		
	final_value += unit_attack_damage
		
	return int(final_value)
	
func get_attack_delay() -> float:
	var final_value :float = attack_delay
	if _weapon_mods.has(WeaponMod.typeMod.receiver):
		var mod :WeaponMod = _weapon_mods[WeaponMod.typeMod.receiver]
		final_value -= attack_delay * mod.dec_attack_delay_bonus
		
	return clamp(final_value, 0.10, attack_delay)
	
func get_reload_delay() -> float:
	var final_value :float = reload_delay
	if _weapon_mods.has(WeaponMod.typeMod.mag):
		var mod :WeaponMod = _weapon_mods[WeaponMod.typeMod.mag]
		final_value -= reload_delay * mod.dec_reload_bonus
		
	return clamp(final_value, 0.10, reload_delay)
	
func get_max_ammo() -> int:
	var final_value :int= max_ammo
	if _weapon_mods.has(WeaponMod.typeMod.mag):
		var mod :WeaponMod = _weapon_mods[WeaponMod.typeMod.mag]
		final_value += int(max_ammo * mod.inc_ammo_bonus)
		
	return int(final_value)















