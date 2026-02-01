/obj/effect/proc_holder/spell/invoked/vampiric_drain
	name = "Vampiric Drain"
	desc = "Channels a dark link to steal life from a target over 10 seconds. Higher arcane skill increases the potency."
	overlay_state = "bloodlightning"
	releasedrain = 40
	chargedrain = 1
	chargetime = 30
	range = 2
	cost = 6
	spell_tier = 3
	recharge_time = 40 SECONDS
	warnie = "spellwarning"
	invocations = list("Sakra!")
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	invocation_type = "shout"
	glow_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_HIGH
	gesture_required = TRUE
	ignore_los = FALSE

	var/drain_duration = 10 SECONDS 
	var/tick_delay = 5 
	var/damage_per_tick = 6 
	var/heal_multiplier = 1.5 
	var/wound_heal_potency = 1.2
	var/blood_drain_per_tick = 10

/obj/effect/proc_holder/spell/invoked/vampiric_drain/cast(list/targets, mob/living/user = usr)
	if(!isliving(targets[1]))
		revert_cast()
		return FALSE

	var/mob/living/target = targets[1]

	if(target == user)
		revert_cast()
		return FALSE


	var/datum/beam/vamp_beam = user.Beam(target, icon_state="blood", time=drain_duration)

	user.visible_message(span_danger("[user] begins to siphon life from [target]!"), \
						 span_notice("You establish a dark link with [target]..."))

	
	var/skill_mod = user.get_skill_level(associated_skill)
	var/final_damage = damage_per_tick + (skill_mod * 1)
	var/final_heal = (final_damage * heal_multiplier) + (skill_mod * 0.5)
	var/final_wound_heal = wound_heal_potency + (skill_mod * 0.5)
	var/final_blood_drain = blood_drain_per_tick + (skill_mod * 2) 


	var/end_time = world.time + drain_duration
	
	while(world.time < end_time)
		
		if(QDELETED(user) || QDELETED(target) || user.stat || target.stat)
			break
		
		if(get_dist(user, target) > range + 1)
			to_chat(user, span_warning("The link has been broken!"))
			break

		
		playsound(target, 'sound/magic/bloodheal.ogg', 40, TRUE)

		
		target.apply_damage(final_damage, BRUTE)
		
	
		user.adjustBruteLoss(-(final_heal / 2))
		user.adjustFireLoss(-(final_heal / 2))
		user.heal_wounds(final_wound_heal)
		
		
		if(iscarbon(target))
			var/mob/living/carbon/C_target = target
			
			if(!(NOBLOOD in C_target.dna?.species?.species_traits))
				
				var/actually_drained = min(C_target.blood_volume, final_blood_drain)
				C_target.blood_volume -= actually_drained
				
				
				if(iscarbon(user))
					var/mob/living/carbon/C_user = user
					C_user.blood_volume = min(C_user.blood_volume + actually_drained, BLOOD_VOLUME_NORMAL)
				
				if(prob(20))
					to_chat(target, span_danger("You feel your lifeblood being pulled out of your veins!"))

		
		stoplag(tick_delay)


	if(vamp_beam)
		vamp_beam.End()

	return TRUE
