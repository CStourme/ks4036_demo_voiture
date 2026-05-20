class_name KS4036Movement
extends Node

signal wheel_rotation_in_percent_left(percent: float)
signal wheel_rotation_in_percent_right(percent: float)

@export var car_movement: CharacterBody3D
@export var speed_forward_ms: float = 0.3
@export var speed_rotate_degree: float = 180

# NOUVEAU (Note à moi-même) : J'ajoute la largeur réelle de ma voiture en mètres (ex: 2.0 mètres).
# C'est cette dimension qui va permettre de calculer le pivot parfait sans glisser !
@export var car_width: float = 0.08

@export_range(-1,1,0.1) var joystick_intensity: float = 0
@export_range(-1,1,0.1) var joystick_rotation_intensity: float = 0

func _ready() -> void:
	if car_movement == null:
		push_warning("Character not found!")
		
func set_joystick_forward(percent: float):
	joystick_intensity = percent
		
func set_joystick_rotate(percent: float):
	joystick_rotation_intensity = percent
		
func set_joystick_with_vector2(joystick: Vector2):
	joystick_rotation_intensity = joystick.x
	joystick_intensity = joystick.y

func _process(delta: float) -> void:
	# --- 1. CALCUL PRÉALABLE DE LA VITESSE DES ROUES (Note à moi-même) ---
	# Je calcule la vitesse des roues AVANT de bouger la voiture.
	# Comme ça, je peux détecter si l'une d'elles est censée être immobile à l'arrêt (égale à 0).
	var vitesse_roue_gauche: float = joystick_intensity + (joystick_rotation_intensity * 0.5)
	var vitesse_roue_droite: float = joystick_intensity - (joystick_rotation_intensity * 0.5)

	# --- 2. L'AJUSTEMENT "EFFET COMPAS" (Note à moi-même) ---
	# Par défaut, j'utilise le calcul de vitesse normal.
	var vitesse_avance_reelle: float = speed_forward_ms * joystick_intensity
	
	# ASTUCE GÉOMÉTRIQUE : Si la roue droite OU la roue gauche est à 0.0 pendant qu'on tourne,
	# c'est qu'on est en train d'utiliser un seul trigger (L ou R). On veut un pivot parfait !
	var pivot_gauche_actif: bool = vitesse_roue_gauche == 0.0 and vitesse_roue_droite != 0.0
	var pivot_droit_actif: bool = vitesse_roue_droite == 0.0 and vitesse_roue_gauche != 0.0

	if pivot_gauche_actif or pivot_droit_actif:
		# Je calcule la vitesse de rotation en Radians par seconde
		var rotation_rad_s: float = deg_to_rad(speed_rotate_degree) * abs(joystick_rotation_intensity)
		# Le rayon du virage correspond exactement à la moitié de la largeur de ma voiture
		var rayon_du_pivot: float = car_width / 2.0
		
		# Formule mathématique absolue : Vitesse = Rotation * Rayon.
		# J'utilise "sign()" pour savoir si on avance (1.0) ou si on recule avec le majeur (-1.0).
		var sens_marche: float = sign(joystick_intensity)
		vitesse_avance_reelle = sens_marche * (rotation_rad_s * rayon_du_pivot)

	# --- 3. DÉPLACEMENT ET ROTATION DE LA VOITURE ---
	var position: Vector3 = car_movement.position
	var direction_forward: Vector3 = -car_movement.basis.z
	direction_forward.y = 0
	
	# J'applique ma vitesse (qui est maintenant automatiquement bridée et parfaite lors d'un pivot)
	position = position + direction_forward * vitesse_avance_reelle * delta
	car_movement.position = position
	
	car_movement.rotate_y(deg_to_rad(speed_rotate_degree) * delta * -joystick_rotation_intensity)

	# --- 4. ENVOI DES VALEURS AUX ROUES ---
	wheel_rotation_in_percent_left.emit(vitesse_roue_gauche)
	wheel_rotation_in_percent_right.emit(vitesse_roue_droite)
