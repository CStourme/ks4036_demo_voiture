class_name KS4036Movement
extends Node

# Note à moi-même : Ces deux signaux sont mes "câbles de transmission". 
# Ils vont envoyer la vitesse finale calculée pour chaque roue directement au script "wheel_rotation.gd".
signal wheel_rotation_in_percent_left(percent: float)
signal wheel_rotation_in_percent_right(percent: float)

# Note à moi-même : Mes variables de configuration (réglables dans l'inspecteur)
@export var car_movement: CharacterBody3D
@export var speed_forward_ms: float = 0.5
@export_range(-1,1,0.1) var joystick_intensity: float = 0
@export var speed_rotate_degree: float = 90
@export_range(-1,1,0.1) var joystick_rotation_intensity: float = 0

func _ready() -> void:
	# Note à moi-même : Une sécurité au lancement du jeu. Si j'ai oublié de glisser le corps 
	# 3D de ma voiture dans la case "car_movement", Godot va m'alerter dans la console.
	if car_movement == null:
		push_warning("Character not found!")
		
# Note à moi-même : Cette fonction reçoit la puissance du mouvement (gâchettes ou joystick Y)
func set_joystick_forward(percent: float):
	joystick_intensity = percent
		
# Note à moi-même : Cette fonction reçoit la puissance du virage (gâchettes ou joystick X)
func set_joystick_rotate(percent: float):
	joystick_rotation_intensity = percent
		
# Note à moi-même : Une fonction bonus si jamais je veux lui envoyer un Vector2 complet d'un coup
func set_joystick_with_vector2(joystick: Vector2):
	joystick_rotation_intensity = joystick.x
	joystick_intensity = joystick.y

func _process(delta: float) -> void:
	# --- 1. DÉPLACEMENT ET ROTATION DE LA VOITURE ---
	# Note à moi-même : Je récupère la position actuelle de ma voiture en 3D
	var position: Vector3 = car_movement.position
	
	# Je regarde vers où pointe l'avant de ma voiture (-basis.z) et j'annule la hauteur (y = 0) pour ne pas s'envoler
	var direction_forward: Vector3 = -car_movement.basis.z
	direction_forward.y = 0
	
	# Je calcule la nouvelle position (Position + Direction * VitesseMax * ForceDonnée * TempsÉcoulé)
	position = position + direction_forward * speed_forward_ms * joystick_intensity * delta
	car_movement.position = position
	
	# Je fais tourner la voiture sur elle-même (l'axe Y) par rapport à l'intensité de rotation demandée
	car_movement.rotate_y(deg_to_rad(speed_rotate_degree) * delta * -joystick_rotation_intensity)

	# --- 2. CALCUL DE LA VITESSE DE CHAQUE ROUE ---
	# COMMENT ÇA MARCHE ? (Note à moi-même pour ne plus me faire piéger) :
	# Pour la roue GAUCHE, j'ajoute la rotation. Pour la roue DROITE, je la soustrais.
	#
	# POURQUOI LE * 0.5 ?
	# Mon script intermédiaire m'envoie une valeur de rotation deux fois plus forte que le mouvement
	# quand je n'appuie que sur un seul trigger (ex: Mouvement = 0.5, Rotation = 1.0).
	# En multipliant la rotation par 0.5, j'équilibre parfaitement les deux forces !
	#
	# Exemple concret : J'appuie UNIQUEMENT sur le Trigger Gauche à fond.
	# Mon script de pilotage calculera : joystick_intensity = 0.5  et  joystick_rotation_intensity = 1.0
	# - Roue Gauche : 0.5 + (1.0 * 0.5) = 1.0  -> Elle tourne à fond en avant. Perfect !
	# - Roue Droite : 0.5 - (1.0 * 0.5) = 0.0  -> Elle reste pile à l'arrêt, comme un vrai char !
	var vitesse_roue_gauche: float = joystick_intensity + (joystick_rotation_intensity * 0.5)
	var vitesse_roue_droite: float = joystick_intensity - (joystick_rotation_intensity * 0.5)

	# --- 3. ENVOI DES VALEURS AUX ROUES ---
	# Note à moi-même : J'envoie mes pourcentages enfin équilibrés à mes roues 3D.
	# Si la valeur calculée est négative, le script "wheel_rotation.gd" fera tourner la roue en arrière automatiquement.
	wheel_rotation_in_percent_left.emit(vitesse_roue_gauche)
	wheel_rotation_in_percent_right.emit(vitesse_roue_droite)
