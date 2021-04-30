extends Node2D

var names = ["maxhp", "atk", "def", "spatk", "spdef", "speed"]

#stored values

#IV's are between 0 and 31, immutable after pokemon is generated
var IV = [0, 0, 0, 0, 0, 0]

#EV's are between 0 and 252 (no more than 510 total)
#changed via training and items
var EV = [0, 0, 0, 0, 0, 0]

var current_hp
var level = 5

#stages raised or lower due to status effects
#NOTE: hp replaced by accuracy in this array
var stage = [0, 0, 0, 0, 0, 0]

#REALLY need to get this in a better state, but it'll do for now
var evasion_stage = 0

var is_fainted = false

#calculated whenever the pokemon is accessed
var stats = [0, 0, 0, 0, 0, 0]

#pokemon base stats (need to move to other storage system)
var species_stats
var base = [0, 0, 0, 0, 0, 0]

#unused for now, need to make happen later
var nature = [1, 1, 1, 1, 1, 1]
var exp_group
var experience

#MOVES

#moves known
var moves = [0, 0, 0, 0]

#current pp
var c_pp = [0, 0, 0, 0]

#max pp
var max_pp = [0, 0, 0, 0]

var is_players = false

# non-volatile status (poisoned, burned, etc.)
# turns till end describes how many turns sleep will last
var nv_stat_names = [" ", "burned", "frozen", "paralyzed", "poisoned", "badly poisoned", "sleeping"]
var nv_stat = 0
var nv_tte = 0


var pkmn_name
var species

# volatile status conditions (confused, etc.
# turns till end describes how many turns status will last
# (set to -1 if status lasts indefinitely)

#for now, nv statuses are: confused, wrapped, can't escape, and flinch
var v_stat = [0, 0, 0, 0]
var v_tte = [0, 0, 0, 0]


# volatile battle statuses are self-inflicted
# also have a timer
#for now, options are bracing, protection, and substitute
var vb_stat = [0, 0, 0]
var vb_tte = [0, 0, 0]

#view stuff

func _ready():
	#need to decide to load a previous pokemon or generate a new one
	#generate stats
	#global = get_node("/root/global")
	pass

func change_stage(amt, st):
	stage[st] = stage[st] + amt
	
	if stage[st] < -6:
		stage[st] == -6
		print("Stat can't go any lower!")
	elif stage[st] > 6:
		stage[st] == 6
		print("Stat can't go any higher!")
	elif amt < 0:
		if is_players:
			print(str(pkmn_name, "'s ", names[st], " fell!"))
		else:
			print(str("Enemy's ", names[st], " fell!"))
	else:
		if is_players:
			print(str(pkmn_name, "'s ", names[st], " rose!"))
		else:
			print(str("Enemy's ", names[st], " rose!"))
	
	print(stage[st])

func change_evasion(amt):
	evasion_stage = evasion_stage + amt
	
	if evasion_stage < -6:
		evasion_stage == -6
		print("Stat can't go any lower!")
	elif evasion_stage > 6:
		evasion_stage == 6
		print("Stat can't go any higher!")
	elif amt < 0:
		if is_players:
			print(str(pkmn_name, "'s evasion fell!"))
		else:
			print(str("Enemy's evasion fell!"))
	else:
		if is_players:
			print(str(pkmn_name, "'s evasion rose!"))
		else:
			print(str("Enemy's evasion rose!"))
	
	print(evasion_stage)

func setup(rand_e):
	#print(global.get_psd()[rand_e[0]])
	species = rand_e[0]
	species_stats = global.get_psd()[rand_e[0]]
	level = rand_e[1]
	
	#setup experience
	
	exp_group = global.get_psd()[species]["level_type"]
	experience = global.get_exp()[exp_group]["exp"][level-1]
	print("Experience:")
	print(experience)
	
	
	if exp_group == 0: # medium fast
		pass
	elif exp_group == 1: # erratic
		pass
	elif exp_group == 2: # fluctuating
		pass
	elif exp_group == 3: # medium slow
		pass
	elif exp_group == 4: # fast
		pass
	elif exp_group == 5: # slow
		pass
	
	
	#there's probably a better way to do this...
	base[0] = species_stats["base_hp"]
	base[1] = species_stats["base_atk"]
	base[2] = species_stats["base_def"]
	base[3] = species_stats["base_spatk"]
	base[4] = species_stats["base_spdef"]
	base[5] = species_stats["base_speed"]
	
	gen_stats()
	gen_moves(rand_e)
	gen_IVs()
	pkmn_name = species_stats["name"]
	setup_display()
	

#generates IV's for a random encounter
func gen_IVs():
	for x in range(6):
		var rand = randi()%32
		IV[x] = rand
	
	#xprint(IV)

#generate moveset for a random encounter
func gen_moves(rand_e):
	var level_moveset = global.pmd[rand_e[0]]["level"]
	
	#moveset index
	var i = level_moveset.size()-1
	print(i)
	#known moves index
	var j = 0
	
	while i>=0 and j < 4:
		var move = level_moveset[i]
		print(move)
		if move[0] <= level:
			moves[j] = move[1]
			j = j+1
		
		i = i-1
	
	
	setup_move_pp()
	#print(level_moveset)
	#print(moves)

func get_move(index):
	return moves[index]

func get_level():
	return level
	
func get_species():
	return species

func has_four_moves():
	for i in range(4):
		print(moves[i])
		if moves[i] == 0:
			print('yes')
			return i
	
	return 0

func setup_move_pp():
	#global.moves
	for x in range(4):
		var pp = global.moves[moves[x]]["pp"]
		c_pp[x] = pp
		max_pp[x] = pp
	
#fully heals the pokemon
func full_heal():
	remove_nv_status()
	for x in range(v_stat.size()):
		remove_v_status(x)
	is_fainted = false
	current_hp = stats[0]
	
	for x in len(c_pp):
		c_pp[x] = max_pp[x]
	
	change_status_display()
	change_hp_display()
	#need to remove volatile battle conditions when those are implemented
	print("healed!")
	

func apply_nv_status(st):
	#can only be applied if pkmn has no status currently
	if nv_stat == 0:
		nv_stat = st
		print(str(pkmn_name, " was ", nv_stat_names[st], "!"))
		#if status is sleep, put a countdown on it
		if st == 6:
			#sleep for 2 to 5 turns
			nv_tte = randi()%4 + 2
		elif st == 5:
			nv_tte = 1
		else:
			#NOTE: add conditions for freezing, etc. 
			nv_tte = 0
	
	change_status_display()

func apply_v_status(st, timer):
	if v_stat[st] == 1:
		print("stat is already in effect!")
		return
	
	v_stat[st] = 1
	v_tte[st] = timer

func remove_nv_status():
	nv_stat = 0
	change_status_display()

func remove_v_status(st):
	v_stat[st] = 0
	v_tte[st] = 0

func apply_burn_damage():
	var eighth = floor(stats[0]/8)
	if eighth == 0:
		eighth = 1
	return apply_damage(eighth)

func apply_poison_damage():
	var eighth = floor(stats[0]/8)
	if eighth == 0:
		eighth = 1
	return apply_damage(eighth)

func apply_bad_poison_damage():
	var sixteen = floor(stats[0]/16)
	if sixteen == 0:
		sixteen = 1
	var dmg = sixteen * nv_tte
	nv_tte = nv_tte + 1
	return apply_damage(dmg)

func apply_wrap_damage():
	var sixteen = floor(stats[0]/16)
	if sixteen == 0:
		sixteen = 1
	print("wrap damage")
	print(sixteen)
	return apply_damage(sixteen)

func calculate_accuracy(move, op_evasion):
	#special case for Wonder Skin
	
	
	
	#get move's base accuracy
	var acc = move['acc']
	
	var fin_stage = stage[0] - op_evasion
	
	if fin_stage < -6:
		fin_stage = -6
	elif fin_stage > 6:
		fin_stage = 6
	
	acc = acc * global.acc_stage[fin_stage+6]
	
	#effect of various items and abilities
	
	return acc

func calculate_speed():
	#get pokemon's displayed speed
	var speed = stats[5]
	
	#apply stat stage 
	speed = speed * global.stat_stage[stage[5]+6]
	
	#TODO: apply paralysis penalty
	if nv_stat == 3:
		speed = speed/2
	
	#TODO: apply item and ability modifiers
	speed = int(speed)
	if speed == 0:
		speed = 1
		
	return speed

func calculate_crit_ratio(move):
	var c = 0
	#some items affect critical hit ratio
	#if move has a high critical hit ratio add 1
	#if pkmn has used certain moves it affects critical hit ratio
	return c


func calculate_attack(is_crit):
	var atk = stats[1]
	
	if not is_crit or global.stat_stage[stage[1]+6] > 1:
		atk = atk * global.stat_stage[stage[1]+6]
	# a bunch of ability modifications
	# some item modifications too
	# some move-based modifications
	if is_crit:
		atk = atk * 1.5
	
	#NOTE: does burn get applied when critical hit?
	if nv_stat == 1:
		atk = atk/2
	
	atk = int(atk)
	print(atk)
	return atk

func calculate_spatk(is_crit):
	var spatk = stats[3]
	
	if not is_crit or global.stat_stage[stage[3]+6] > 1:
		spatk = spatk * global.stat_stage[stage[3]+6]
	# a bunch of ability modifications
	# some item modifications too
	# modification for burn status
	# some move-based modifications
	if is_crit:
		spatk = spatk * 1.5
	
	return spatk

func calculate_def(is_crit):
	var def = stats[2]
	if not is_crit or global.stat_stage[stage[2]+6] < 1:
		def = def * global.stat_stage[stage[2]+6]
	# a bunch of ability modifications
	# some item modifications too
	# modification for burn status
	# some move-based modifications
	if is_crit:
		def = def * 1.5
	
	return def

func calculate_spdef(is_crit):
	var spdef = stats[4]
	
	if not is_crit or global.stat_stage[stage[4]+6] < 1:
		spdef = spdef * global.stat_stage[stage[4]+6]
	# a bunch of ability modifications
	# some item modifications too
	# modification for burn status
	# some move-based modifications
	if is_crit:
		spdef = spdef * 1.5
	
	return spdef

#NOTE: needs testing!
func get_random_move():
	if c_pp[0] == 0 and c_pp[1] == 0 and c_pp[2] == 0 and c_pp[3] == 0:
			print("Pokemon is out of useable moves!")
			return 0
			
	var mv = 0
	var ind = randi()%4 #might be broken?
	while mv==0:
		ind = randi()%4 #might be broken?
		if c_pp[ind] > 0:
			mv = moves[ind]
	return ind

func use_move(ind):
	c_pp[ind] = c_pp[ind] - 1
	
	if c_pp[ind] < 0:
		c_pp[ind] == 0

# remove volatile status conditions
# anything else that would need to happen when a pokemon is switched out or a battle ends
func switch_out():
	v_stat = [0, 0, 0, 0]
	v_tte = [0, 0, 0, 0]
	
	stage = [0, 0, 0, 0, 0, 0]
	evasion_stage = 0
	
	pass

func gain_exp(gain):
	experience = experience + gain
	print(str("Experience: ", experience))
	# if pokemon has gained enough experience to level up...
	if experience >= global.get_exp()[exp_group]["exp"][level]:
		print("Level up!")
		level = level + 1
		change_main_display()
		regen_stats()
		change_hp_display()
		return true
	else:
		print("no level up")
		return false

func gain_EVs(ev_num):
	for x in len(ev_num):
		var a = int(ev_num[x])
		EV[x] = EV[x] + a
		print(EV[x])
	
#NOTE: NOT YET COMPLETED
func check_for_new_moves():
	var level_moveset = global.get_pmd()[species]["level"]
	
	for x in len(level_moveset):
		if level_moveset[x][0] == level:
			print(level_moveset[x][1])
			
			#if the pokemon knows less than 4 moves, add this move automatically
#			if moves[0] == 0:
#				moves[0] = level_moveset[x][1]
#				var pp = global.moves[moves[0]]["pp"]
#				c_pp[0] = pp
#				max_pp[0] = pp
#
#			elif moves[1] == 0:
#				moves[1] = level_moveset[x][1]
#				var pp = global.moves[moves[1]]["pp"]
#				c_pp[1] = pp
#				max_pp[1] = pp
#
#			elif moves[2] == 0:
#				moves[2] = level_moveset[x][1]
#				var pp = global.moves[moves[2]]["pp"]
#				c_pp[2] = pp
#				max_pp[2] = pp
#
#			elif moves[3] == 0:
#				moves[3] = level_moveset[x][1]
#				var pp = global.moves[moves[3]]["pp"]
#				c_pp[3] = pp
#				max_pp[3] = pp
#
#			else:
#				print("ALLOW PLAYER TO DELETE MOVE")
			
			
			return true
	
	return false

func make_players():
	is_players = true
	var sp = self.get_child(0)
	sp.frame = 1

func make_opponent():
	is_players = false
	var sp = self.get_child(0)
	sp.frame = 0

func gen_stats():
	for x in range(6):
		#print(names[x])
		if x==0:
			stats[x] = ((base[x]*2 + IV[x] + EV[x]/4)*level)/100 + level + 10
			stats[x] = round(stats[x])
			current_hp = stats[x]
		else:
			stats[x] = ((base[x]*2 + IV[x] + EV[x]/4)*level)/100 + 5 + nature[x]
			stats[x] = round(stats[x])
		#print(stats[x])

#for leveling up and other similar things
#NOTE: current HP is not quite right at the moment
#NOTE: have not double checked that IV calculation works properly
func regen_stats():
	for x in range(6):
		#print(names[x])
		if x==0:
			stats[x] = ((base[x]*2 + IV[x] + EV[x]/4)*level)/100 + level + 10
			stats[x] = round(stats[x])
		else:
			stats[x] = ((base[x]*2 + IV[x] + EV[x]/4)*level)/100 + 5 + nature[x]
			stats[x] = round(stats[x])

func setup_display():
	var name_label = self.get_child(1).get_child(3)
	var level_label = self.get_child(1).get_child(4)
	var status_label = self.get_child(1).get_child(5)
	name_label.text = pkmn_name
	level_label.text = str("Lvl: ", level)
	status_label.text = nv_stat_names[nv_stat]
	change_hp_display()
	

func change_main_display():
	var name_label = self.get_child(1).get_child(3)
	var level_label = self.get_child(1).get_child(4)
	name_label.text = pkmn_name
	level_label.text = str("Lvl: ", level)

func change_status_display():
	var status_label = self.get_child(1).get_child(5)
	status_label.text = nv_stat_names[nv_stat]

func apply_damage(damage):
	current_hp = current_hp - damage
	
	if(current_hp <=0):
		current_hp = 0
		#print("fainted!")
		is_fainted = true
	
	change_hp_display()
	
	return is_fainted

func change_hp_display():
	var hb = self.get_child(1).get_child(1)
	var hp_label = self.get_child(1).get_child(2)
	
	var hp_percent = current_hp/stats[0]
	#print(hp_percent)
	
	hb.scale.x = hp_percent
	hp_label.text = str(current_hp, "/", stats[0])
	
	if hp_percent > .5:
		hb.frame = 0
	elif hp_percent > .25:
		hb.frame = 1
	else:
		hb.frame = 2
