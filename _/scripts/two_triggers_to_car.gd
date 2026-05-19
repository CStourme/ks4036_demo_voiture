extends Node

@export var car: KS4036Movement

# Note à moi-même : Je crée mes boîtes pour stocker la position des gâchettes
var l_trigger: float = 0.0
var r_trigger: float = 0.0

# Note à moi-même : Je crée mes boîtes pour stocker la position des joysticks
var l_joystick: Vector2 = Vector2.ZERO
var r_joystick: Vector2 = Vector2.ZERO

# --- FONCTIONS DE RÉCEPTION (Mes signaux VR viennent brancher les valeurs ici) ---
func set_trigger_left(percent: float):
	l_trigger = percent
		
func set_trigger_right(percent: float):
	r_trigger = percent

func set_joystick_left(vector: Vector2):
	l_joystick = vector

func set_joystick_right(vector: Vector2):
	r_joystick = vector


# --- LE COEUR DU PILOTAGE ---
func _process(delta: float) -> void:
	# Note à moi-même : Sécurité importante ! Si j'ai oublié de relier la voiture dans l'inspecteur,
	# j'arrête tout de suite pour éviter que le jeu ne plante (Crash).
	if car == null:
		return

	# Je prépare mes variables "résultat" à 0. Elles changeront selon mon mode de pilotage.
	var mouvement_final: float = 0.0
	var rotation_final: float = 0.0

	# Je regarde si mes doigts touchent aux gâchettes (avec une petite zone morte de 0.1)
	var g_gachette_presse: bool = l_trigger > 0.1
	var d_gachette_presse: bool = r_trigger > 0.1

	# --- MODE 1 : LE MODE TANK PROPORTIONNEL (Prioritaire) ---
	if g_gachette_presse or d_gachette_presse:
		
		# VITESSE :
		# Je fais la moyenne des deux gâchettes. 
		# Exemple : Si j'écrase la gauche à fond (1.0) et la droite à moitié (0.6),
		# le calcul fait : (1.0 + 0.6) / 2 = 0.8. La voiture avance à 80% de sa vitesse !
		mouvement_final = (l_trigger + r_trigger) / 2.0
		
		# ROTATION :
		# Je soustrais la gâchette droite de la gâchette gauche.
		# Reprenons l'exemple : Gauche (1.0) moins Droite (0.6) = 0.4.
		# Le résultat est positif, donc la voiture va glisser doucement vers la droite tout en avançant !
		# Si j'avais fait l'inverse, le résultat aurait été négatif (-0.4), faisant tourner la voiture à gauche.
		# Si j'appuie à fond sur les deux (1.0 - 1.0 = 0), la voiture fonce tout droit sans tourner.
		rotation_final = l_trigger - r_trigger

	# --- MODE 2 : LE MODE CLASSIQUE (Si je lâche les gâchettes) ---
	else:
		# Si je pousse le joystick gauche, il devient le maître à bord
		if l_joystick.length() > 0.1:
			mouvement_final = l_joystick.y  # L'axe Y (haut/bas) fait avancer/reculer
			rotation_final = l_joystick.x   # L'axe X (gauche/droite) fait tourner
			
		# Sinon, si je pousse le joystick droit, c'est lui qui pilote
		elif r_joystick.length() > 0.1:
			mouvement_final = r_joystick.y
			rotation_final = r_joystick.x

	# --- L'ENVOI UNIQUE ---
	# Une fois que mes calculs au-dessus sont prêts, j'envoie la décision finale à ma voiture.
	# Comme ça, pas de conflit entre les joysticks et les gâchettes, un seul ordre est donné !
	car.set_joystick_forward(mouvement_final)
	car.set_joystick_rotate(rotation_final)
