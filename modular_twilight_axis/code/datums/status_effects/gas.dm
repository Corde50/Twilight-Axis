
/obj/item/rope/chain/fake/ice
	name = "ice chains"
	desc = "Magical ice freezing your wrists together."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "chain"
	item_flags = ABSTRACT | DROPDEL 
	breakouttime = 600 SECONDS 



/datum/status_effect/freon/freeze
	id = "frozen"
	duration = 120 SECONDS 
	status_type = STATUS_EFFECT_UNIQUE
	mob_effect_icon_state = null 
	mob_effect_icon = null
	
	var/mutable_appearance/ice_overlay
	var/ice_integrity = 50 
	var/melt_timer = 0
	
	
	var/obj/item/rope/chain/fake/ice/magic_chains

/datum/status_effect/freon/freeze/on_apply()
	. = ..()
	if(!owner) return
	
	owner.apply_status_effect(STATUS_EFFECT_PARALYZED, duration)
	
	
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		if(!C.handcuffed)
			
			var/obj/item/rope/chain/fake/ice/I = new /obj/item/rope/chain/fake/ice(C)
			magic_chains = I
			C.handcuffed = magic_chains
			C.update_inv_handcuffed() 
			C.update_inv_hands()

	RegisterSignal(owner, COMSIG_ATOM_ATTACK_HAND, PROC_REF(block_interaction))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMGE, PROC_REF(handle_ice_shatter))

	
	ice_overlay = mutable_appearance('modular_twilight_axis/icons/effects/freeze.dmi', "spike")
	ice_overlay.alpha = 150 
	ice_overlay.color = "#b0f0ff"
	ice_overlay.appearance_flags = RESET_COLOR | RESET_ALPHA | TILE_BOUND
	
	owner.add_overlay(ice_overlay)
	owner.add_atom_colour(rgb(50, 150, 255), ADMIN_COLOUR_PRIORITY)
	
	
	owner.lying = 0
	if(hasvar(owner, "lying_prev"))
		owner:lying_prev = 0
	owner.transform = matrix() 
	owner.update_transform()

/datum/status_effect/freon/freeze/tick()
	if(!owner) return
	if(owner.stat == DEAD)
		qdel(src) 
		return

	owner.adjustOxyLoss(0.8) 


	if(owner.lying != 0)
		owner.lying = 0
		owner.transform = matrix()

	if(owner.on_fire || (locate(/obj/effect/hotspot) in owner.loc))
		melt_timer++
		if(melt_timer >= 3)
			qdel(src)
	else
		melt_timer = max(0, melt_timer - 1)

/datum/status_effect/freon/freeze/on_remove()
	if(owner)
	
		owner.cut_overlay(ice_overlay)
		owner.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
		
		
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			if(C.handcuffed == magic_chains)
				C.handcuffed = null
				qdel(magic_chains)
				magic_chains = null
				C.update_inv_handcuffed()
				C.update_inv_hands()

	
		owner.remove_status_effect(STATUS_EFFECT_PARALYZED)
		
		if(owner.stat != DEAD)
			owner.setOxyLoss(0)
			owner.lying = 0
			if(hasvar(owner, "lying_prev"))
				owner:lying_prev = 0 
			owner.transform = matrix() 
			owner.update_transform()
			owner.emote("gasp")
		else
			
			owner.transform = matrix()
			if(hasvar(owner, "lying_prev"))
				owner:lying_prev = 0
			owner.update_transform()

		UnregisterSignal(owner, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_MOB_APPLY_DAMGE))
		owner.bodytemperature = BODYTEMP_NORMAL
		owner.update_mobility()
	..()

/datum/status_effect/freon/freeze/proc/handle_ice_shatter(datum/source, damage, damagetype)
	if(damage <= 0 || damagetype == OXY || damagetype == TOX) return
	ice_integrity -= damage
	if(ice_integrity > 0)
		owner.balloon_alert_to_viewers("Ice cracks! ([ice_integrity])")
		new /obj/effect/temp_visual/snap_freeze(get_turf(owner))
	else
		playsound(owner, 'sound/combat/hits/onglass/glassbreak (4).ogg', 100, TRUE)
		qdel(src) 

/datum/status_effect/freon/freeze/proc/block_interaction(datum/source, mob/user)
	SIGNAL_HANDLER
	if(user == owner) return
	if(user.a_intent != INTENT_HARM)
		to_chat(user, span_warning("The ice is too thick!"))
		return COMPONENT_NO_ATTACK_HAND
/datum/pollutant/cold_mist
	name = "cold mist"
	pollutant_flags = POLLUTANT_APPEARANCE | POLLUTANT_TOUCH_ACT | POLLUTANT_BREATHE_ACT
	thickness = 5
	alpha = 200

/datum/pollutant/cold_mist/touch_act(mob/living/carbon/victim, amount, total_amount)
	if(HAS_TRAIT(victim, TRAIT_RESISTCOLD)) return
	
	
	victim.apply_status_effect(/datum/status_effect/stacking/hypothermia, 1)
	
	
	victim.bodytemperature = max(victim.bodytemperature - 15, 50)

/datum/pollutant/cold_mist/breathe_act(mob/living/carbon/victim, amount, total_amount)
	if(HAS_TRAIT(victim, TRAIT_RESISTCOLD)) return
	
	
	victim.apply_status_effect(/datum/status_effect/stacking/hypothermia, 1)
