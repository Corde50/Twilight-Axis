
/obj/structure/multistage/onager_unfinished
	name = "Unfinished Onager"
	desc = "An unfinished onager frame."
	icon = 'modular_twilight_axis/icons/obj/structures/siege/oneger/onager_unfinished.dmi'
	icon_state = "build_stage_0"
	
	stage_types = list(
		/datum/crafting_stage/onager_stage_1,
		/datum/crafting_stage/onager_stage_2,
		/datum/crafting_stage/onager_stage_3
	)
	
	final_product_type = /obj/structure/onager


/datum/crafting_stage/onager_stage_1
	icon_state = "build_stage_1"
	description = "\nIt needs <b>3 iron ingots</b>. Tool: <b>Hammer</b>."
	recipe = /datum/crafting_recipe/multistage/onager_1

/datum/crafting_stage/onager_stage_2
	icon_state = "build_stage_2"
	description = "\nIt needs <b>5 ropes</b> and <b>3 bronze ingots</b>. Tool: <b>Hammer</b>."
	recipe = /datum/crafting_recipe/multistage/onager_2

/datum/crafting_stage/onager_stage_3
	icon_state = "build_stage_3"
	description = "\nIt needs <b>2 steel ingots</b>. Tool: <b>Hammer</b>."
	recipe = /datum/crafting_recipe/multistage/onager_3



/datum/crafting_recipe/multistage/onager_1
	name = "Onager Stage 1"
	always_availible = FALSE
	tools = list(/obj/item/hammer = 1)
	reqs = list(/obj/item/ingot/iron = 3)
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 2 
	craftsound = 'sound/items/tools/hammer.ogg'

/datum/crafting_recipe/multistage/onager_2
	name = "Onager Stage 2"
	always_availible = FALSE
	tools = list(/obj/item/hammer = 1)
	reqs = list(
		/obj/item/rope = 5,
		/obj/item/ingot/bronze = 3
	)
	skillcraft = /datum/skill/craft/engineering
	craftdiff = 3 
	craftsound = 'sound/items/tools/ratchet.ogg'

/datum/crafting_recipe/multistage/onager_3
	name = "Onager Stage 3"
	always_availible = FALSE
	tools = list(/obj/item/hammer = 1)
	reqs = list(/obj/item/ingot/steel = 2)
	skillcraft = /datum/skill/craft/blacksmithing
	craftdiff = 3
	craftsound = 'sound/items/tools/hammer.ogg'


/datum/crafting_recipe/onager_frame
	name = "Onager Frame"
	category = "Structure" 
	reqs = list(
		/obj/item/natural/stone = 10,
		/obj/item/natural/wood/plank = 10
	)
	result = /obj/structure/multistage/onager_unfinished
	tools = list(/obj/item/hammer = 1)
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 2
	time = 50

/obj/structure/onager
	name = "Onager"
	desc = "A torsion-powered siege engine designed to throw massive projectiles."

	icon = 'icons/obj/structures/siege/onager/onager.dmi' 
	icon_state = "idle"

	anchored = TRUE
	density = TRUE
	max_integrity = 500
	layer = OBJ_LAYER
	
	
	armor = list("blunt" = 20, "slash" = 50, "stab" = 50, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = -50, "bio" = 100, "rad" = 100, "fire" = -20, "acid" = 0)

	var/min_target_distance = 5
	var/max_target_distance = 30
	var/target_distance = 15

	var/list/interactions = list("Fire!", "Set Direction", "Set Target Distance", "Pack Up")
	var/list/directions = list("NORTH", "SOUTH", "EAST", "WEST")
	
	
	var/list/launch_sounds = list('sound/weapons/sonic_jackhammer.ogg') 
	var/list/aim_sounds = list('sound/items/ratchet.ogg')

	var/idle = TRUE
	var/ready = FALSE
	var/loaded = FALSE
	var/launched = FALSE
	var/packed = FALSE
	var/being_used = FALSE

/obj/structure/onager/Initialize()
	. = ..()
	update_icon()



/obj/structure/onager/proc/reset_state()
	idle = FALSE
	ready = FALSE
	loaded = FALSE
	launched = FALSE
	packed = FALSE

/obj/structure/onager/proc/set_idle()
	reset_state()
	anchored = TRUE
	idle = TRUE
	update_icon()

/obj/structure/onager/proc/set_ready()
	reset_state()
	ready = TRUE
	update_icon()

/obj/structure/onager/proc/set_loaded()
	reset_state()
	ready = TRUE
	loaded = TRUE
	update_icon()

/obj/structure/onager/proc/set_launched()
	reset_state()
	launched = TRUE
	update_icon()

/obj/structure/onager/proc/set_packed()
	reset_state()
	anchored = FALSE
	packed = TRUE
	update_icon()

/obj/structure/onager/update_icon()
	cut_overlays()
	if(idle || ready)
		icon_state = "idle"
	if(loaded)
		icon_state = "idle"
		add_overlay(mutable_appearance(icon, "boulder_overlay"), HIGH_OBJ_LAYER)
	if(launched)
		icon_state = "launched"
	if(packed)
		icon_state = "packed" 


/obj/structure/onager/attack_hand(mob/living/carbon/user)
	if(packed)
		to_chat(user, span_warning("The onager is packed. Alt-click to unpack."))
		return 
	if(being_used)
		to_chat(user, span_warning("Someone else is using it."))
		return 
	if(!ready)
		ready(user)
		return

	var/choice = input(user, "Onager Actions", "Onager") as null|anything in interactions
	if(!choice || !user.canUseTopic(src, be_close=TRUE))
		return
	
	switch(choice)
		if("Fire!")
			try_fire(user)
		if("Set Direction")
			set_direction(user)
		if("Set Target Distance")
			set_target_distance(user)
		if("Pack Up")
			pack(user)

/obj/structure/onager/attackby(obj/item/I, mob/living/carbon/user)

	if(I.tool_behaviour == TOOL_HAMMER)
		if(obj_integrity < max_integrity)
			I.play_tool_sound(src)
			user.visible_message(span_notice("[user] repairs [src]."), span_notice("You repair [src]."))
			obj_integrity = min(obj_integrity + 50, max_integrity)
			if(obj_integrity >= max_integrity)
				obj_broken = FALSE 
			return
	
	if(!ready)
		to_chat(user, span_warning("Draw the arm back first."))
		return
	if(loaded)
		to_chat(user, span_warning("It's already loaded."))
		return

	try_load(I, user)

/obj/structure/onager/MouseDrop(over_object, src_location, over_location)
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) && (packed) || usr.contents.Find(src)))
		if(ishuman(usr))
			unpack(usr)
	else
		return ..()



/obj/structure/onager/proc/ready(mob/user)
	user.visible_message(span_notice("[user] cranks the arm back."))
	playsound(src, pick(aim_sounds), 50, TRUE)
	if(do_after(user, 30, target = src))
		set_ready()
		user.visible_message(span_notice("The onager is ready."))

/obj/structure/onager/proc/try_fire(mob/user)
	if(is_obstructed())
		to_chat(user, span_warning("Obstructed from above!"))
		return 
	if(!loaded)
		to_chat(user, span_warning("Not loaded."))
		return
	if(target_distance <= 0)
		to_chat(user, span_warning("Aim it first."))
		return
	fire(user)

/obj/structure/onager/proc/fire(mob/user)
	var/turf/target = get_ranged_target_turf(src, dir, target_distance)

	if(target)
		var/x_off = rand(-2, 2)
		var/y_off = rand(-2, 2)
		var/turf/scatter = locate(clamp(target.x + x_off, 1, world.maxx), clamp(target.y + y_off, 1, world.maxy), target.z)
		if(scatter) target = scatter

	playsound(src, pick(launch_sounds), 60, TRUE)
	user.visible_message(span_danger("[user] fires the onager!"))
	
	set_launched()
	

	var/turf/spawn_loc = get_turf(src)

	var/turf/upper = locate(spawn_loc.x, spawn_loc.y, spawn_loc.z + 1)
	if(upper && !is_obstructed())
		spawn_loc = upper

	var/obj/item/boulder/P = new /obj/item/boulder(spawn_loc)
	P.launched = TRUE
	P.travel_time = target_distance 
	P.throw_at(target, target_distance, 1, user) 

/obj/structure/onager/proc/is_obstructed()
	var/turf/T = get_turf(src)
	var/turf/above = locate(T.x, T.y, T.z + 1)
	if(above && above.density) return TRUE
	return FALSE

/obj/structure/onager/proc/try_load(obj/item/I, mob/living/carbon/user)
	if(istype(I, /obj/item/boulder))
		if(!user.dropItemToGround(I)) return
		qdel(I) 
		user.visible_message(span_notice("[user] loads [I]."))
		playsound(src, 'sound/foley/gravel_footstep.ogg', 70, TRUE)
		set_loaded()
	else
		to_chat(user, span_warning("You need a boulder."))

/obj/structure/onager/proc/set_direction(mob/user)
	var/direction = input(user, "Direction", "Set Direction") as null|anything in directions
	if(!direction) return
	var/new_dir = text2dir(direction)
	if(new_dir == dir) return

	being_used = TRUE
	playsound(src, pick(aim_sounds), 50, TRUE)
	if(do_after(user, 30, target = src))
		dir = new_dir
		user.visible_message(span_notice("[user] turns the onager."))
	being_used = FALSE

/obj/structure/onager/proc/set_target_distance(mob/user)
	var/dist = input(user, "Distance ([min_target_distance]-[max_target_distance])", "Set Distance") as num|null
	if(!dist) return
	if(dist < min_target_distance || dist > max_target_distance)
		to_chat(user, span_warning("Invalid distance."))
		return

	being_used = TRUE
	playsound(src, pick(aim_sounds), 50, TRUE)
	if(do_after(user, 30, target = src))
		target_distance = dist
		user.visible_message(span_notice("[user] sets distance to [dist]."))
	being_used = FALSE

/obj/structure/onager/proc/pack(mob/user)
	being_used = TRUE
	user.visible_message(span_notice("[user] starts packing the onager..."))
	if(do_after(user, 50, target = src))
		set_packed()
		user.visible_message(span_notice("[user] packs the onager."))
	being_used = FALSE

/obj/structure/onager/proc/unpack(mob/user)
	user.visible_message(span_notice("[user] starts unpacking..."))
	if(do_after(user, 50, target = src))
		set_idle()
		user.visible_message(span_notice("[user] unpacks the onager."))


/obj/item/boulder
	name = "boulder"
	desc = "A massive rock."
	icon = 'icons/obj/structures/siege/onager/onager.dmi'
	icon_state = "boulder"
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 50
	var/launched = FALSE
	var/travel_time = 0


/obj/item/boulder/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(launched)
		
		if(hit_atom.density || isliving(hit_atom))
			explode()
			return
	return ..()


/obj/item/boulder/proc/explode()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/bang.ogg', 100, TRUE) 
	
	
	explosion(T, 0, 1, 3) 
	
	
	create_shrapnel(T)
	
	
	for(var/mob/living/L in range(6, T))
		if(!L.stat)
			shake_camera(L, 3, 1)
			L.Knockdown(20)
	
	qdel(src)

// Ручное создание осколков
/obj/item/boulder/proc/create_shrapnel(turf/T)
	for(var/i in 1 to 8) 
		var/obj/projectile/rock_shard/S = new(T)
		var/turf/target = locate(T.x + rand(-3,3), T.y + rand(-3,3), T.z)
		if(target)
			S.preparePixelProjectile(target, T)
			S.fire()

// Сами осколки
/obj/projectile/rock_shard
	name = "rock shard"
	icon_state = "bullet" 
	damage = 15
	range = 5
	pass_flags = PASSTABLE | PASSGRILLE
	armor_penetration = 15
	damage_type = BRUTE
	flag = "bullet"
	speed = 2
