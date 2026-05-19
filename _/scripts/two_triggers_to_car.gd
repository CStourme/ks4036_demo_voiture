extends Node

@export var car: KS4036Movement

# Note à moi-même : Mes boîtes pour stocker la pression de l'index (trigger) et du majeur (grip)
var l_trigger: float = 0.0
var r_trigger: float = 0.0
var l_grip: float = 0.0
var r_grip: float = 0.0

# Note à moi-même : Mes boîtes pour stocker la position des joysticks
var l_joystick: Vector2 = Vector2.ZERO
var r_joystick: Vector2 = Vector2.ZERO


# --- FONCTIONS DE RÉCEPTION (Connectées aux signaux de mes manettes Quest 3) ---
func set_trigger_left(percent: float):
	l_trigger = percent
		
func set_trigger_right(percent: float):
	r_trigger = percent

func set_grip_left(percent: float):
	l_grip = percent

func set_grip_right(percent: float):
	r_grip = percent

func set_joystick_left(vector: Vector2):
	l_joystick = vector

func set_joystick_right(vector: Vector2):
	r_joystick = vector


# --- LE COEUR DU PILOTAGE ---
func _process(delta: float) -> void:
	if car == null:
		return

	# Je prépare mes variables "résultat" à 0
	var mouvement_final: float = 0.0
	var rotation_final: float = 0.0

	# Je regarde si mes doigts touchent soit à l'index, soit au majeur (zone morte de 0.1)
	var g_gachette_presse: bool = l_trigger > 0.1 or l_grip > 0.1
	var d_gachette_presse: bool = r_trigger > 0.1 or r_grip > 0.1

	# --- MODE 1 : LE MODE TANK PROPORTIONNEL AVANT / ARRIÈRE ---
	if g_gachette_presse or d_gachette_presse:
		
		# =====================================================================
		# ÉTAPE A : CALCUL DE L'EFFORT REÇU PAR CHAQUE MANETTE (Note à moi-même)
		# =====================================================================
		# Pour chaque main, je fais : INDEX (Avancer) MOINS MAJEUR (Reculer).
		# L'index donne du positif (0.0 à 1.0), le majeur donne du négatif (0.0 à -1.0).
		#
		# Exemples de résultats pour "total_gauche" ou "total_droit" :
		# - Index à fond, Majeur lâché   ->  1.0 - 0.0 =  1.0  (Avance à fond)
		# - Index lâché, Majeur à fond   ->  0.0 - 1.0 = -1.0  (Recule à fond)
		# - Index à fond, Majeur à fond  ->  1.0 - 1.0 =  0.0  (Les forces s'annulent, la roue s'arrête)
		# - Index à moitié, Majeur lâché ->  0.5 - 0.0 =  0.5  (Avance à mi-puissance)
		var total_gauche: float = l_trigger - l_grip
		var total_droit: float = r_trigger - r_grip
		
		# =====================================================================
		# ÉTAPE B : CALCUL DE LA VITESSE GLOBALE DE LA VOITURE (Mouvement)
		# =====================================================================
		# Je fais la moyenne des forces des deux côtés. C'est ce qui décide si la 
		# voiture va globalement vers l'avant, vers l'arrière, ou si elle reste sur place.
		#
		# SIMULATION 1 : J'écrase les deux MAJEURS à fond pour reculer tout droit.
		# -> total_gauche = -1.0  |  total_droit = -1.0
		# -> mouvement_final = (-1.0 + -1.0) / 2.0 = -1.0
		# Résultat : La voiture recule à pleine vitesse.
		#
		# SIMULATION 2 : Index Gauche à fond (1.0), Majeur Droit à fond (-1.0).
		# -> mouvement_final = (1.0 + -1.0) / 2.0 = 0.0 / 2.0 = 0.0
		# Résultat : La vitesse globale est nulle car les deux manettes s'opposent. 
		# La voiture va pivoter sur place sans bouger d'un pil.
		mouvement_final = (total_gauche + total_droit) / 2.0
		
		# =====================================================================
		# ÉTAPE C : CALCUL DE LA ROTATION GLOBALE DE LA VOITURE (Rotation)
		# =====================================================================
		# Je soustrais la force droite de la force gauche. Le résultat dicte la direction :
		# Un score POSITIF fait tourner à DROITE, un score NÉGATIF fait tourner à GAUCHE.
		#
		# SIMULATION 1 : Je veux reculer tout droit (Les deux majeurs à fond).
		# -> total_gauche = -1.0  |  total_droit = -1.0
		# -> rotation_final = -1.0 - (-1.0)  ->  -1.0 + 1.0 = 0.0
		# Résultat : Rotation égale à 0, la voiture recule parfaitement droit !
		#
		# SIMULATION 2 : J'appuie sur l'Index Gauche (1.0) et le Majeur Droit (-1.0).
		# -> rotation_final = 1.0 - (-1.0)  ->  1.0 + 1.0 = 2.0
		# Résultat : Un score énorme de 2.0 ! La voiture va pivoter à droite à une vitesse 
		# fulgurante, car la chenille gauche pousse vers l'avant et la droite vers l'arrière.
		#
		# SIMULATION 3 : J'appuie uniquement sur le Majeur Gauche (-1.0) pour reculer.
		# -> total_gauche = -1.0  |  total_droit = 0.0
		# -> mouvement_final = (-1.0 + 0.0) / 2.0 = -0.5 (Recule tranquillement)
		# -> rotation_final = -1.0 - 0.0 = -1.0 (Tourne à gauche)
		# Résultat dans ks4036_movement.gd :
		# - Roue G : -0.5 + (-1.0 * 0.5) = -1.0 (Recule à fond)
		# - Roue D : -0.5 - (-1.0 * 0.5) = -0.5 + 0.5 = 0.0 (Reste immobile !)
		# C'est parfait : Seule la roue gauche s'active en arrière, faisant pivoter l'arrière vers la gauche.
		rotation_final = total_gauche - total_droit

	# --- MODE 2 : LE MODE CLASSIQUE (Si je lâche les commandes du gros bouton) ---
	else:
		if l_joystick.length() > 0.1:
			mouvement_final = l_joystick.y
			rotation_final = l_joystick.x
		elif r_joystick.length() > 0.1:
			mouvement_final = r_joystick.y
			rotation_final = r_joystick.x

	# --- L'ENVOI UNIQUE ---
	car.set_joystick_forward(mouvement_final)
	car.set_joystick_rotate(rotation_final)
