extends Node2D

onready var pkmn= preload("res://Pokemon.tscn")
var opponent
var p_pkmn

var moves_labels

#locks buttons and stuff when moves are being executed
var controls_locked = true

#lets me wait for a move to finish before something else happens
signal move_finished

#another signal
signal battle_end

# for changing displays
var text_box

# for learning new move
var delete_move = true
var confirm_deletion = false
var new_move
var delete_index

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	get_child(0).get_node("Button").connect("pressed", self,"_on_Button_pressed")
	
	#connect move buttons
	get_child(1).get_child(0).get_node("Button").connect("pressed", self, "_move_1_pressed")
	get_child(1).get_child(1).get_node("Button").connect("pressed", self, "_move_2_pressed")
	get_child(1).get_child(2).get_node("Button").connect("pressed", self, "_move_3_pressed")
	get_child(1).get_child(3).get_node("Button").connect("pressed", self, "_move_4_pressed")
	
	get_node("autowin").connect("pressed", self, "_auto_win_pressed")
	
	get_node("new move panel/yes button").connect("pressed", self, "_yes_button_pressed")
	get_node("new move panel/no button").connect("pressed", self, "_no_button_pressed")
	
	get_node("new move panel/move1 button").connect("pressed", self, "_delete_move1")
	get_node("new move panel/move2 button").connect("pressed", self, "_delete_move2")
	get_node("new move panel/move3 button").connect("pressed", self, "_delete_move3")
	get_node("new move panel/move4 button").connect("pressed", self, "_delete_move4")
	get_node("new move panel/new move button").connect("pressed", self, "_delete_new_move")	
#	global = get_node("/root/global")
	
	moves_labels = get_child(1).get_children()
	
	opponent = pkmn.instance()
	opponent.setup(global.get_rand_e())
	opponent.make_opponent()
	
	p_pkmn = global.send_out_pokemon()
	
	add_child(opponent)
	add_child(p_pkmn)
	
	# need to make it scale with window size
	opponent.position = Vector2(500, 100)
	
	p_pkmn.position = Vector2(350, 400)
	setup_moves_panel()
	setup_text_box()
	

#this handles the order of events for calling moves
func move_round(user_move):
	controls_locked = true

	
	var us_mv = global.moves[p_pkmn.get_move(user_move)]
	
	var op_mv_ind = opponent.get_random_move()
	var op_mv = global.moves[opponent.moves[op_mv_ind]]
	
	print("move indices")
	print(user_move)
	print(op_mv_ind)
	
	#replace with vector for multi battles
	var player_first = true
	
	#determine order of events
	#NOTE: this should probably be its own function, just for readability
	#if anyone is switching, rotating, or mega-evolving, do that
	#for now, attacking is the only option
	
	#priority trumps other things
	if us_mv["pri"] > op_mv["pri"]:
		player_first = true
	elif us_mv["pri"] > op_mv["pri"]:
		player_first = false
	else: 
		#quick claw and some other items n stuff have an effect here
		var us_speed = p_pkmn.calculate_speed()
		var op_speed = opponent.calculate_speed()
		
		if us_speed > op_speed:
			player_first = true
		elif op_speed > us_speed:
			player_first = false
		else:
			if randi()%2 == 1:
				player_first = true
			else:
				player_first = false
	
	
	if player_first:
		#execute player move
		if not us_mv["who"] == "self":
			execute_move(us_mv, p_pkmn, opponent, true, user_move)
		else:
			execute_move(us_mv, p_pkmn, p_pkmn, true, user_move)
		yield(self, "move_finished")
		
		#execute opponent move
		if not op_mv["who"] == "self":
			execute_move(op_mv, opponent, p_pkmn, false, op_mv_ind)
		else:
			execute_move(op_mv, opponent, opponent, false, op_mv_ind)
		yield(self, "move_finished")
	else:
		#execute opponent move
		if not op_mv["who"] == "self":
			execute_move(op_mv, opponent, p_pkmn, false, op_mv_ind)
		else:
			execute_move(op_mv, opponent, opponent, false, op_mv_ind)
		yield(self, "move_finished")
		
		#execute player move
		if not us_mv["who"] == "self":
			execute_move(us_mv, p_pkmn, opponent, true, user_move)
		else:
			execute_move(us_mv, p_pkmn, p_pkmn, true, user_move)
		yield(self, "move_finished")
	
	var player_fnt = false
	var opponent_fnt = false
	#apply status effects (damage from poison, burn, etc.)
	if p_pkmn.v_stat[1] == 1:
		text_box.text = str(p_pkmn.pkmn_name, " was squeezed!")
		player_fnt = p_pkmn.apply_wrap_damage()
		yield(get_tree().create_timer(1.0), "timeout")
		
		
	if p_pkmn.nv_stat == 1:
		text_box.text = str(p_pkmn.pkmn_name, " was hurt by its burn!")
		player_fnt = p_pkmn.apply_burn_damage()
		yield(get_tree().create_timer(1.0), "timeout")
	if p_pkmn.nv_stat == 4:
		text_box.text = str(p_pkmn.pkmn_name, " was hurt by poison!")
		player_fnt = p_pkmn.apply_poison_damage()
		yield(get_tree().create_timer(1.0), "timeout")
	if p_pkmn.nv_stat == 5:
		text_box.text = str(p_pkmn.pkmn_name, " was hurt by poison!")
		player_fnt = p_pkmn.apply_bad_poison_damage()
		yield(get_tree().create_timer(1.0), "timeout")
	
	if player_fnt:
		yield(get_tree().create_timer(1.0), "timeout")
		text_box.text = str(p_pkmn.pkmn_name, " fainted!")
		yield(get_tree().create_timer(1.0), "timeout")
		lose_battle()
	
	if opponent.v_stat[1] == 1:
		text_box.text = str(opponent.pkmn_name, " was squeezed by ", p_pkmn.pkmn_name, "!")
		opponent_fnt = opponent.apply_wrap_damage()
		yield(get_tree().create_timer(1.0), "timeout")
		
		
		
	if opponent.nv_stat == 1:
		text_box.text = str("Foe ", opponent.pkmn_name, " was hurt by its burn!")
		opponent_fnt = opponent.apply_burn_damage()
		yield(get_tree().create_timer(1.0), "timeout")
	if opponent.nv_stat == 4:
		text_box.text = str("Foe ", opponent.pkmn_name, " was hurt by poison!")
		opponent_fnt = opponent.apply_poison_damage()
		yield(get_tree().create_timer(1.0), "timeout")
	if opponent.nv_stat == 5:
		text_box.text = str("Foe ", opponent.pkmn_name, " was hurt by poison!")
		opponent_fnt = opponent.apply_bad_poison_damage()
		yield(get_tree().create_timer(1.0), "timeout")
		
	
	if opponent_fnt:
		yield(get_tree().create_timer(1.0), "timeout")
		text_box.text = str(opponent.pkmn_name, " fainted!")
		yield(get_tree().create_timer(1.0), "timeout")
		win_battle()
		yield(self, "battle_end")
	
	#apply item effects (leftovers, etc.)
	
	#remove transient battle/volatile statuses
	#remove flinch
	p_pkmn.remove_v_status(3)
	opponent.remove_v_status(3)
	
	#yield(get_tree().create_timer(2.0), "timeout")
	controls_locked = false
	text_box.text = "What will you do?"
	pass


func execute_move(move, attacker, defender, isplayers, mv_ind):
	#if pokemon is frozen
	if attacker.nv_stat == 2:
		var r = randi()%10
		if r >= 2:
			text_box.text = str(attacker.pkmn_name, " is frozen solid!")
			yield(get_tree().create_timer(1.0), "timeout")
			emit_signal("move_finished")
			return null
		else:
			text_box.text = str(attacker.pkmn_name, " thawed out!")
			attacker.remove_nv_status()
			yield(get_tree().create_timer(1.0), "timeout")
	
	#if pokemon is paralyzed
	if attacker.nv_stat == 3:
		var r = randi()%4
		text_box.text = str(attacker.pkmn_name, " is paralyzed.")
		yield(get_tree().create_timer(1.0), "timeout")
		if r == 0:
			text_box.text = "It can't move!"
			yield(get_tree().create_timer(1.0), "timeout")
			emit_signal("move_finished")
			return null
	
	#if pokemon is asleep
	if attacker.nv_stat == 6:
		attacker.nv_tte = attacker.nv_tte - 1
		if attacker.nv_tte == 0:
			text_box.text = str(attacker.pkmn_name, " woke up!")
			yield(get_tree().create_timer(1.0), "timeout")
			attacker.remove_nv_status()
		else:
			text_box.text = str(attacker.pkmn_name, " is fast asleep!")
			yield(get_tree().create_timer(1.0), "timeout")
			emit_signal("move_finished")
			return null
	
	#if pokemon is wrapped
	if attacker.v_stat[1] == 1:
		attacker.v_tte[1] = attacker.v_tte[1] - 1
		if attacker.v_tte[1] == 0:
			text_box.text = str(attacker.pkmn_name, " was freed from wrap!")
			yield(get_tree().create_timer(1.0), "timeout")
			attacker.remove_v_status(1)
	
	if attacker.v_stat[3] == 1:
		text_box.text = str(attacker.pkmn_name, " flinched!")
		yield(get_tree().create_timer(1.0), "timeout")
		emit_signal("move_finished")
		return null
	
	if isplayers:
		text_box.text = str(attacker.pkmn_name, ", use ", move["name"], "!")
	else:
		text_box.text = str(attacker.pkmn_name, " used ", move["name"], "!")
	
	attacker.use_move(mv_ind)
	change_moves_panel()
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	#determine accuracy
	var hits = false

	var calc_acc = attacker.calculate_accuracy(move, defender.evasion_stage)
		
	#100 if is 100% accurate, 0 if is guaranteed to hit
	if(calc_acc >= 100 or calc_acc == 0):
		hits = true
	else :
		var rand = randi()%100
		if calc_acc >= rand:
			hits = true
		else:
			hits = false
		
	
	if not hits:
		#print("move doesn't hit!")
		text_box.text = "It missed!"
		yield(get_tree().create_timer(2.0), "timeout")
		
		if move["eff"] == "crash":
			text_box.text = "It kept going and crashed!"
			var damage = attacker.stats[0]/2
			#should be an integer
			damage = floor(damage)
			var has_fainted = attacker.apply_damage(damage)
			yield(get_tree().create_timer(2.0), "timeout")
			
			if has_fainted:
				text_box.text = str(attacker.pkmn_name, " fainted!")
				yield(get_tree().create_timer(1.0), "timeout")
				if not attacker.is_players:
					win_battle()
					yield(self, "battle_end")
				else:
					lose_battle()
		
		emit_signal("move_finished")
		return null
	
	# Runs multiple times for a multiattack move!
	var times = 1
	if move["eff"] == "multi":
		if move["mag"] == 2:
			times = 2
		elif move["mag"] == 5:
			var rand = randi()%6
			if rand <2:
				times = 2
			elif rand < 4:
				times = 3
			elif rand == 4:
				times = 4
			elif rand == 5:
				times = 5
		else:
			print("Number of multiattacks not recognized")
	
	print(times)
	
	var counter = 0
	
	while counter < times:
		#determine critical hit
		var c_r = attacker.calculate_crit_ratio(move)
	
		# move has a different critical hit ratio
		if move["eff"] == "crit":
			c_r = c_r + move["mag"]
			print("move c_r")
			print(c_r)
	
		# NOTE: check opponent for abilities that might prevent critical hits
	
		var crit = false
		var rand = randi()%global.crit_stage[c_r]
	
		if(rand == 0):
			crit = true
			#text_box.tex = str(text_box.text, "\nCritical hit!")
	
		var damage = 0
		#calculate damage
		if move["ps"] == "p":
			damage = floor(floor(floor(2 * attacker.level / 5 + 2) * attacker.calculate_attack(crit) * move["bp"] / defender.calculate_def(crit)) / 50) + 2
		elif move["ps"] == "s":
			damage = floor(floor(floor(2 * attacker.level / 5 + 2) * attacker.calculate_spatk(crit) * move["bp"] / defender.calculate_def(crit)) / 50) + 2
		else:
			print("not a damaging move")
	
	
		if crit:
			damage = damage * 1.5
	
		#type advantages
		var effectiveness = 1
	
		effectiveness = global.type_effect[move["type"]][global.psd[defender.species]["type_1"]]
		print(move["type"])
		print(global.psd[defender.species]["type_1"])
		if not global.psd[defender.species]["type_1"] == global.psd[defender.species]["type_2"]: #dual type pokemon
			effectiveness = effectiveness * global.type_effect[move["type"]][global.psd[defender.species]["type_2"]]
		damage = damage * effectiveness
		
		print("effectiveness")
		print(effectiveness)
		
		#STAB bonus
		if move["type"] == global.psd[attacker.species]["type_1"] or move["type"] == global.psd[attacker.species]["type_2"]:
			damage = damage * 1.5
			print("STAB bonus")
	
		#should be an integer
		damage = floor(damage)
		
		#one hit KO move -> damage equals remaining hp of enemy
		if move["eff"] == "ohko":
			damage = opponent.current_hp
			
			
		# apply damage
		if  not move["ps"] == "t":
			print(str("Damage: ", damage))
			var has_fainted = defender.apply_damage(damage)
		
			var txt = ""
			if crit:
				txt = "Critical hit!"
			if effectiveness > 1:
				txt = str(txt, "\nIt's supereffective!")
			elif effectiveness < 1 and not effectiveness == 0:
				txt = str(txt, "\nIt's not very effective...")
			elif effectiveness == 0:
				txt = "It doesn't affect the foe..."
		
			text_box.text = txt
			yield(get_tree().create_timer(1.0), "timeout")

			
			if has_fainted:
				#NOTE: IF MULTIATTACK, PRINT NUMBER OF TIMES EXECUTED
				
				yield(get_tree().create_timer(1.0), "timeout")
				text_box.text = str(defender.pkmn_name, " fainted!")
				yield(get_tree().create_timer(1.0), "timeout")
				
				if move["eff"] == "recoil":
					text_box.text = str(attacker.pkmn_name, " was hit by recoil!")
					var recoil = floor(damage/4)
					if recoil == 0:
						recoil == 1
					var attacker_has_fainted = attacker.apply_damage(recoil)
					yield(get_tree().create_timer(1.0), "timeout")
					
					if attacker_has_fainted:
						text_box.text = str(attacker.pkmn_name, " fainted!")
						yield(get_tree().create_timer(1.0), "timeout")
						lose_battle()
					if not defender.is_players:
						win_battle()
						yield(self, "battle_end")
					else:
						lose_battle()
				if attacker.is_players:
					win_battle()
					yield(self, "battle_end")
				else:
					lose_battle()
			else:
				#BROKEN: prints win condition twice 
				if move["eff"] == "recoil":
					text_box.text = str(attacker.pkmn_name, " was hit by recoil!")
					var recoil = floor(damage/4)
					if recoil == 0:
						recoil == 1
					var attacker_has_fainted = attacker.apply_damage(recoil)
					yield(get_tree().create_timer(1.0), "timeout")
					
					if attacker_has_fainted:
						text_box.text = str(attacker.pkmn_name, " fainted!")
						yield(get_tree().create_timer(1.0), "timeout")
						if not attacker.is_players():
							win_battle()
							yield(self, "battle_end")
						else:
							lose_battle()
	
	
		#determine effects
		if not move["eff"] == "none":
			#print("should have an extra effect")
			var effect_hits = false
		
			if move["ea"] == 100:
				effect_hits = true
			else:
				rand = randi()%100
				if move["ea"] >= rand:
					effect_hits = true

			if effect_hits:
				print("effect hits!")
				var en = move["eff"]
			
				#non-volatile status effects
				if en == "burn":
					defender.apply_nv_status(1)
				elif en == "freeze":
					defender.apply_nv_status(2)
				elif en == "paralyze":
					defender.apply_nv_status(3)
				elif en == "poison":
					defender.apply_nv_status(4)
				elif en == "bad poison":
					defender.apply_nv_status(5)
				elif en == "sleep":
					defender.apply_nv_status(6)
			
				#stat stage changes
				var mg = move["mag"]
			
				if en == "attack":
					defender.change_stage(mg, 1)
				elif en == "defense":
					defender.change_stage(mg, 2)
				elif en == "spattack":
					defender.change_stage(mg, 3)
				elif en == "spdefense":
					defender.change_stage(mg, 4)
				elif en == "speed":
					defender.change_stage(mg, 5)
				elif en == "accuracy":
					defender.change_stage(mg, 0)
				elif en == "evasion":
					defender.change_evasion(mg)
				
				#volatile status effects
				#wrapping move: deals fixed amount of damage relative to defender's health
				if en == "wrap":
					if damage > 0:
						var ran = randi()%6
						var tms = 0
						if ran <2:
							tms = 3
						elif ran < 4:
							tms = 4
						elif ran == 4:
							tms = 5
						elif ran == 5:
							tms = 6
						defender.apply_v_status(1, tms)
						text_box.text = str(defender.pkmn_name, "was squeezed by ", attacker.pkmn_name, "!")
						print("wrap duration")
						print(tms)
						yield(get_tree().create_timer(1.0), "timeout")
				elif en == "flinch":
					defender.apply_v_status(3, 0)
				
				# other effects
				if move["eff"] == "switch":
					# NOTE: when trainer battles happen, switch not end
					text_box.text = str(defender.pkmn_name, " was blown away!")
					yield(get_tree().create_timer(1.0), "timeout")
					end_battle()
				
					
					
		counter = counter + 1
		yield(get_tree().create_timer(1.0), "timeout")
	
	if move["eff"] == "multi":
		text_box.text = str("Hit ", times, " times!")
		yield(get_tree().create_timer(2.0), "timeout")
	
	
	emit_signal("move_finished")
	return null
	

func calculate_exp():
	#formula
	
	#exp = (a * t * b * e * L * p * f) / (7*s)
	
	# a: 1 if wild pokemon, 1.5 if trainer's
	# t: 1 if pkmn is original trainer, 1.5 otherwise
	# b: base experience yield of opponent
	# e: 1.5 if player pokemon is holding luck egg, 1 otherwise
	# L: level of fainted/caught pokemon
	# p: 1 if no EXP point power, varies otherwise
	# f: 1.2 if player pkmn has 2 hearts of affection or more
	# s: 1 for now, used for calculating sharing 
	
	#NOTE: will need to change these eventually
	
	var a = 1
	var t = 1
	var b = global.get_base_experience(opponent.get_species())
	var e = 1
	var L = opponent.get_level()
	var p = 1
	var f = 1
	var s = 1
	
	var experience = floor((a*t*b*e*L*p*f)/(7*s))
	
	if experience == 0:
		experience == 1
	
	return experience

# doles out exp and does other end-of-battle things
func win_battle():
	print("win battle")
	text_box.text = str(p_pkmn.pkmn_name, " gained ", calculate_exp(), " EXP!")
	yield(get_tree().create_timer(2.0), "timeout")
	
	var lvl_up = p_pkmn.gain_exp(calculate_exp())
	
	var ev_num = global.get_psd()[opponent.get_species()]["effort_yield"]
	p_pkmn.gain_EVs(ev_num)
	
	if lvl_up:
		text_box.text = str(p_pkmn.pkmn_name, " grew to level ", p_pkmn.get_level(), "!")
		yield(get_tree().create_timer(1.0), "timeout")
		
		if(p_pkmn.check_for_new_moves()):
			get_new_move()
		else:
			end_battle()
	else:
		end_battle()
	
func lose_battle():
	print("lose battle")
	text_box.text = "Player is out of useable Pokemon!"
	yield(get_tree().create_timer(1.0), "timeout")
	text_box.text = "Player whited out!"
	yield(get_tree().create_timer(2.0), "timeout")
	end_battle()

func get_new_move():
	print("new move!")
	
	#identity of the new move(s)
	#NOTE: handle multiple new moves per level later!
	var level_moveset = global.pmd[p_pkmn.species]["level"]
	var found = false
	var counter = 0
	while not found:
		if level_moveset[counter][0] == p_pkmn.level:
			new_move = level_moveset[counter][1]
			found = true
		counter = counter + 1
		
	var move_name = global.moves[new_move]["name"]
	
	var move_index = p_pkmn.has_four_moves()
	print(move_index)
	
	
	if  move_index == 0:
		var nmp = self.get_node("new move panel")
		nmp.get_node("Label").text = p_pkmn.pkmn_name + " is trying to learn " + move_name + ", but it already knows four moves. Forget a move to make room for " + move_name + "?"
		nmp.show()
	else:
		self.get_node("text panel/text box").text = p_pkmn.pkmn_name + " learned " + move_name + "!"
		p_pkmn.moves[move_index] = new_move
		
		var pp = global.moves[new_move]["pp"]
		p_pkmn.c_pp[move_index] = pp
		p_pkmn.max_pp[move_index] = pp
		change_moves_panel()
		
		yield(get_tree().create_timer(2.0), "timeout")
		
		end_battle()
	

#use this to end the battle
func end_battle():
	p_pkmn.switch_out()
	self.remove_child(p_pkmn)
	get_tree().change_scene("res://test_overworld.tscn")

func setup_moves_panel():
	for x in range(4):
		var mv = p_pkmn.moves[x]
		if mv == 0:
			moves_labels[x].text = ""
			
		else:
			var move_name = global.moves[mv]["name"]
			var c_pp = p_pkmn.c_pp[x]
			var m_pp = p_pkmn.max_pp[x]
			moves_labels[x].text = str(move_name, ": ", c_pp, "/", m_pp)
		

func change_moves_panel():
	for x in range(4):
		var mv = p_pkmn.moves[x]
		if mv == 0:
			moves_labels[x].text = ""
		else:
			var move_name = global.moves[mv]["name"]
			var c_pp = p_pkmn.c_pp[x]
			var m_pp = p_pkmn.max_pp[x]
			moves_labels[x].text = str(move_name, ": ", c_pp, "/", m_pp)

func setup_text_box():
	text_box = get_child(2).get_child(0)
	var pkmn_name = global.get_psd()[global.get_rand_e()[0]]["name"]
	text_box.text = str("Wild ", pkmn_name, " appeared!")
	
	#replace with mechanism to click through
	yield(get_tree().create_timer(1.0), "timeout")
	controls_locked = false
	text_box.text = "What will you do?"

func _on_Button_pressed():
	end_battle()

# NOTE!: Currently unable to do anything if all moves are out of pp!
func _move_1_pressed():
	if not controls_locked:
		#print("Pokemon used move 1!")
		if p_pkmn.c_pp[0] > 0:
			move_round(0)
		else:
			print("That move is out of pp!")

func _move_2_pressed():
	if not controls_locked:
		#print("Pokemon used move 2!")
		if p_pkmn.c_pp[1] > 0:
			move_round(1)
		else:
			print("That move is out of pp!")

func _move_3_pressed():
	if not controls_locked:
		#print("Pokemon used move 3!")
		if p_pkmn.c_pp[2] > 0:
			move_round(2)
		else:
			print("That move is out of pp!")

func _move_4_pressed():
	if not controls_locked:
		#print("Pokemon used move 4!")
		if p_pkmn.c_pp[3] > 0:
			move_round(3)
		else:
			print("That move is out of pp!")
			
func _auto_win_pressed():
	win_battle()
	
func _yes_button_pressed():
	if delete_move and not confirm_deletion:
		get_node("new move panel/Label").text = "Which move should " + p_pkmn.pkmn_name + " forget?"
		get_node("new move panel/move1 button").text = global.moves[p_pkmn.moves[0]]["name"]
		get_node("new move panel/move2 button").text = global.moves[p_pkmn.moves[1]]["name"]
		get_node("new move panel/move3 button").text = global.moves[p_pkmn.moves[2]]["name"]
		get_node("new move panel/move4 button").text = global.moves[p_pkmn.moves[3]]["name"]
		get_node("new move panel/new move button").text = global.moves[new_move]["name"]
		
		get_node("new move panel/move1 button").show()
		get_node("new move panel/move2 button").show()
		get_node("new move panel/move3 button").show()
		get_node("new move panel/move4 button").show()
		get_node("new move panel/new move button").show()
		get_node("new move panel/yes button").hide()
		get_node("new move panel/no button").hide()
	elif not confirm_deletion:
		# confirmed did not want to learn new move
		get_node("new move panel").hide()
		text_box.text = p_pkmn.pkmn_name + " did not learn the new move."
		yield(get_tree().create_timer(2.0), "timeout")
		# NOTE: will have to change later, but for now, end battle
		end_battle()
	else: # confirm move to be deleted
		if delete_index >= 0:
			text_box.text = p_pkmn.pkmn_name + " forgot " + global.moves[p_pkmn.moves[delete_index]]["name"] + " and learned " + global.moves[new_move]['name'] + "!"
			p_pkmn.moves[delete_index] = new_move
			change_moves_panel()
		else:
			text_box.text = p_pkmn.pkmn_name + " did not learn " + global.moves[new_move] + "."
		get_node("new move panel").hide()
		yield(get_tree().create_timer(2.0), "timeout")
		end_battle()

func _no_button_pressed():
	if delete_move and not confirm_deletion:
		get_node("new move panel/Label").text = "Are you sure you do not want to learn the new move?"
		delete_move = false
	elif not confirm_deletion:
		delete_move = true
		var move_name = global.moves[new_move]["name"]
		var move_index = p_pkmn.has_four_moves()
		get_node("new move panel/Label").text = p_pkmn.pkmn_name + " is trying to learn " + move_name + ", but it already knows four moves. Forget a move to make room for " + move_name + "?"
	else: #confirm move to be deleted
		get_node("new move panel/Label").text = "Which move should " + p_pkmn.pkmn_name + " forget?"
		get_node("new move panel/move1 button").show()
		get_node("new move panel/move2 button").show()
		get_node("new move panel/move3 button").show()
		get_node("new move panel/move4 button").show()
		get_node("new move panel/new move button").show()
		get_node("new move panel/yes button").hide()
		get_node("new move panel/no button").hide()
		pass

func _delete_move1():
	confirm_deletion = true
	delete_index = 0
	get_node("new move panel/move1 button").hide()
	get_node("new move panel/move2 button").hide()
	get_node("new move panel/move3 button").hide()
	get_node("new move panel/move4 button").hide()
	get_node("new move panel/new move button").hide()
	get_node("new move panel/yes button").show()
	get_node("new move panel/no button").show()
	
	get_node("new move panel/Label").text = "Are you sure you want to unlearn " + global.moves[p_pkmn.moves[delete_index]]["name"] + "?"
	
func _delete_move2():
	confirm_deletion = true
	delete_index = 1
	get_node("new move panel/move1 button").hide()
	get_node("new move panel/move2 button").hide()
	get_node("new move panel/move3 button").hide()
	get_node("new move panel/move4 button").hide()
	get_node("new move panel/new move button").hide()
	get_node("new move panel/yes button").show()
	get_node("new move panel/no button").show()
	
	get_node("new move panel/Label").text = "Are you sure you want to unlearn " + global.moves[p_pkmn.moves[delete_index]]["name"] + "?"
	
	
func _delete_move3():
	confirm_deletion = true
	delete_index = 2
	get_node("new move panel/move1 button").hide()
	get_node("new move panel/move2 button").hide()
	get_node("new move panel/move3 button").hide()
	get_node("new move panel/move4 button").hide()
	get_node("new move panel/new move button").hide()
	get_node("new move panel/yes button").show()
	get_node("new move panel/no button").show()
	
	get_node("new move panel/Label").text = "Are you sure you want to unlearn " + global.moves[p_pkmn.moves[delete_index]]["name"] + "?"
	
	
func _delete_move4():
	confirm_deletion = true
	delete_index = 3
	get_node("new move panel/move1 button").hide()
	get_node("new move panel/move2 button").hide()
	get_node("new move panel/move3 button").hide()
	get_node("new move panel/move4 button").hide()
	get_node("new move panel/new move button").hide()
	get_node("new move panel/yes button").show()
	get_node("new move panel/no button").show()
	
	get_node("new move panel/Label").text = "Are you sure you want to unlearn " + global.moves[p_pkmn.moves[delete_index]]["name"] + "?"
	
	
func _delete_new_move():
	confirm_deletion = true
	delete_index = -1
	get_node("new move panel/move1 button").hide()
	get_node("new move panel/move2 button").hide()
	get_node("new move panel/move3 button").hide()
	get_node("new move panel/move4 button").hide()
	get_node("new move panel/new move button").hide()
	get_node("new move panel/yes button").show()
	get_node("new move panel/no button").show()
	
	get_node("new move panel/Label").text = "Stop learning " + global.moves[new_move]["name"] + "?"
	
	
	
	
	
