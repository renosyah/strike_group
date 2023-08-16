extends Inventory
class_name WeaponMod

enum typeMod {  barel, grip, mag, receiver, scope }

export(typeMod) var type_mod

# mag
export(float, 0, 1) var inc_ammo_bonus :float
export(float, 0, 1) var dec_reload_bonus :float

# grip
export(float, 0, 1) var dec_spread_bonus :float

# receiver
export(float, 0, 1) var inc_attack_bonus :float
export(float, 0, 1) var dec_attack_delay_bonus :float

# scope
export(float, 0, 1) var inc_range_bonus :float

# barel
export(float, 0, 1) var inc_crit_bonus :float
