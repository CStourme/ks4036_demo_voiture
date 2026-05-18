extends Node

@export var car: KS4036Movement
@export var l_trigger: float
@export var r_trigger: float

func set_trigger_left(percent: float):
	l_trigger = percent
		
func set_trigger_right(percent: float):
	r_trigger = percent

func _process(delta: float) -> void:
	if car == null:
		return

	# 1 - j'appuies UNIQUEMENT sur la gâchette gauche, la voiture avance un peu et tourne à DROITE
	if l_trigger > 0.1 and r_trigger <= 0.1:
		car.set_joystick_forward(l_trigger * 0.5) # Avance à mi-vitesse
		car.set_joystick_rotate(l_trigger)        # Tourne à droite

	# 2 - j'appuies UNIQUEMENT sur la gâchette droite, la voiture avance un peu et tourne à GAUCHE
	elif r_trigger > 0.1 and l_trigger <= 0.1:
		car.set_joystick_forward(r_trigger * 0.5) # Avance à mi-vitesse
		car.set_joystick_rotate(-r_trigger)       # Tourne à gauche (valeur négative)

	# 3 - j'appuies sur les DEUX gâchettes en même temps, la voiture va TOUT DROIT
	elif l_trigger > 0.1 and r_trigger > 0.1:
		var moyenne: float = (l_trigger + r_trigger) / 2.0
		car.set_joystick_forward(moyenne)          # Avance à pleine puissance
		car.set_joystick_rotate(0.0)               # Ne tourne pas

	# 4 - je touches à rien, La voiture s'arrête.
	else:
		car.set_joystick_forward(0.0)
		car.set_joystick_rotate(0.0)
