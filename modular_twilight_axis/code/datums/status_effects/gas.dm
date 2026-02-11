/datum/status_effect/freon/freeze
	id = "frost"
	duration = -1 
	can_melt = FALSE 
	status_type = STATUS_EFFECT_UNIQUE
	
	mob_effect_icon_state = null 
	mob_effect_icon = null
	
	var/mutable_appearance/ice_overlay_ref
	var/ice_integrity = 20 
	var/melt_timer = 0      

/datum/status_effect/freon/freeze/on_apply()
	. = ..()
	if(!owner) return
	
	
	owner.apply_status_effect(STATUS_EFFECT_PARALYZED, 100)
	owner.apply_status_effect(STATUS_EFFECT_SLEEPING, 100)
	
	
	UnregisterSignal(owner, COMSIG_LIVING_RESIST)
	
	
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMGE, PROC_REF(handle_ice_shatter))

	
	var/mutable_appearance/ice_visual = mutable_appearance('modular_twilight_axis/icons/effects/freeze.dmi', "spike")
	ice_visual.alpha = 140 
	ice_visual.color = "#b0f0ff" 
	ice_visual.appearance_flags = RESET_ALPHA | RESET_COLOR | TILE_BOUND
	ice_overlay_ref = ice_visual
	owner.add_overlay(ice_overlay_ref)
	
	owner.add_filter("frozen_inner", 5, list("type" = "color_matrix", "matrix" = list(
		0.5, 0.5, 0.5, 0,
		0.1, 0.1, 0.1, 0,
		0.4, 0.4, 1.2, 0,
		0, 0, 0, 1
	)))
	
	to_chat(owner, span_userdanger("I am walled up in centuries-old ice..."))

/datum/status_effect/freon/freeze/tick()
	if(!owner) return

	
	if(!owner.IsSleeping())
		owner.apply_status_effect(STATUS_EFFECT_SLEEPING, 100)
	
	if(!owner.has_status_effect(STATUS_EFFECT_PARALYZED))
		owner.apply_status_effect(STATUS_EFFECT_PARALYZED, 100)

	
	if(owner.on_fire || (locate(/obj/effect/hotspot) in owner.loc))
		melt_timer++
		if(melt_timer >= 2) 
			owner.visible_message(span_notice("The ice around [owner] is melting from the heat!"))
			qdel(src)
			return
	else
		melt_timer = max(0, melt_timer - 1)

	owner.update_mobility()

/datum/status_effect/freon/freeze/proc/handle_ice_shatter(datum/source, damage, damagetype)
	if(damage <= 0) return
	
	ice_integrity -= damage
	
	if(ice_integrity > 0)
		
		owner.balloon_alert_to_viewers("The ice is cracking! ([ice_integrity])")
		new /obj/effect/temp_visual/snap_freeze(get_turf(owner))
	else
		owner.visible_message(span_danger(" Ice shell [owner] shatters into thousands of pieces!!"))
		playsound(owner, 'sound/combat/hits/onglass/glassbreak (4).ogg', 100, TRUE)
		qdel(src) 

/datum/status_effect/freon/freeze/on_remove()
	if(owner)
		if(ice_overlay_ref)
			owner.cut_overlay(ice_overlay_ref)
			ice_overlay_ref = null
		
		owner.remove_filter("frozen_inner")
		owner.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
		
		
		owner.remove_status_effect(STATUS_EFFECT_SLEEPING)
		owner.remove_status_effect(STATUS_EFFECT_PARALYZED)
		
		UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMGE)
		owner.visible_message(span_notice("[owner] finally free of ice!"))
		
		
		owner.bodytemperature = BODYTEMP_NORMAL
		
	..()

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
