/datum/erp_vfx_service
	var/datum/erp_controller/controller

/datum/erp_vfx_service/New(datum/erp_controller/C)
	. = ..()
	controller = C

/// Gets current arousal value via COMSIG.
/datum/erp_vfx_service/proc/get_arousal_value(mob/living/carbon/human/H)
	if(!istype(H))
		return null

	var/list/data = list()
	SEND_SIGNAL(H, COMSIG_SEX_GET_AROUSAL, data)
	if(!length(data))
		return null

	return data["arousal"]

/// Builds VFX bundle for tick.
/datum/erp_vfx_service/proc/build_tick_effect_bundle(list/active_links, datum/erp_sex_link/best, dt)
	var/list/E = list()
	E["do_thrust"] = FALSE
	E["do_hearts"] = FALSE
	E["sound_slap"] = FALSE
	E["sound_suck"] = FALSE

	var/any_sucking = FALSE

	for(var/datum/erp_sex_link/L in active_links)
		if(!L || QDELETED(L) || !L.is_valid())
			continue

		var/init_t = L.init_organ?.erp_organ_type
		if(init_t && (init_t in list(SEX_ORGAN_MOUTH, SEX_ORGAN_TAIL, SEX_ORGAN_VAGINA, SEX_ORGAN_PENIS, SEX_ORGAN_ANUS)))
			E["do_thrust"] = TRUE

		if(link_is_sucking(L))
			any_sucking = TRUE

		var/list/tags = L.action?.action_tags
		if(!E["sound_slap"] && islist(tags) && ("spanking" in tags))
			E["sound_slap"] = TRUE

	if(any_sucking)
		E["sound_suck"] = TRUE

	var/mob/living/carbon/human/active_mob = best?.actor_active?.get_effect_mob()
	if(istype(active_mob))
		var/ar = get_arousal_value(active_mob)
		if(isnum(ar) && ar >= 20)
			E["do_hearts"] = TRUE

	return E

/// Plays VFX bundle for tick.
/datum/erp_vfx_service/proc/play_tick_effects(list/active_links, datum/erp_sex_link/best, dt)
	if(!best || !best.is_valid())
		return
	if(controller.hidden_mode)
		return

	var/mob/living/carbon/human/active_mob = best.actor_active?.get_effect_mob()
	if(!istype(active_mob))
		return

	var/list/E = build_tick_effect_bundle(active_links, best, dt)
	if(!islist(E))
		return

	if(E["do_thrust"])
		do_thrust_bump(best)
		do_onomatopoeia(active_mob, best)
		play_thrust_sound(active_mob, best)

	if(E["do_hearts"])
		spawn_hearts(active_mob)

	if(E["sound_slap"])
		play_slap(active_mob)

	if(E["sound_suck"])
		play_suck(active_mob, best)

/// Performs thrust bump animation.
/datum/erp_vfx_service/proc/do_thrust_bump(datum/erp_sex_link/best)
	if(!best || QDELETED(best) || !best.is_valid())
		return

	var/mob/living/user = best.actor_active?.get_effect_mob()
	var/atom/movable/target = get_best_thrust_target(best)
	if(!user || !target)
		return

	var/force = clamp(round(best.force || SEX_FORCE_MID), SEX_FORCE_LOW, SEX_FORCE_EXTREME)
	var/speed = clamp(round(best.speed || SEX_SPEED_MID), SEX_SPEED_LOW, SEX_SPEED_EXTREME)

	var/pixels = 3 + (force - SEX_FORCE_LOW)
	pixels = clamp(pixels, 2, 7)

	var/time = 3.4 - (speed * 0.35)
	time = clamp(time, 1.6, 3.6)

	do_thrust_animate(user, target, null, pixels, time)
	try_bed_break(best, user, target, time)

/// Picks best thrust target from link.
/datum/erp_vfx_service/proc/get_best_thrust_target(datum/erp_sex_link/best)
	if(!best)
		return null

	var/mob/living/A = best.actor_active?.get_effect_mob()
	var/mob/living/B = best.actor_passive?.get_effect_mob()
	if(!A || !B)
		return null

	return B

/// Shows balloon onomatopoeia based on organ types.
/datum/erp_vfx_service/proc/do_onomatopoeia(mob/living/carbon/human/user, datum/erp_sex_link/best)
	if(!istype(user))
		return

	var/t_init = best?.init_organ?.erp_organ_type
	var/t_tgt  = best?.target_organ?.erp_organ_type

	var/msg = "Plap!"

	if(t_init == SEX_ORGAN_MOUTH && t_tgt == SEX_ORGAN_MOUTH)
		msg = pick("Mwah!", "Kiss!")
	else
		if(t_init == SEX_ORGAN_MOUTH)
			if(t_tgt == SEX_ORGAN_PENIS)
				msg = pick("Slurp!", "Suck!")
			else if(t_tgt == SEX_ORGAN_VAGINA || t_tgt == SEX_ORGAN_ANUS)
				msg = pick("Lick!", "Slurp!")
			else if(t_tgt == SEX_ORGAN_BREASTS)
				msg = pick("Suck!", "Mmm!")
			else
				msg = pick("Mwah!", "Smack!")

	user.balloon_alert_to_viewers(msg, x_offset = rand(-15, 15), y_offset = rand(0, 25))

/// Plays slap sound.
/datum/erp_vfx_service/proc/play_slap(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/sound = pick('sound/foley/slap.ogg', 'sound/foley/smackspecial.ogg')
	playsound(user, sound, 50, TRUE, -2, ignore_walls = FALSE)

/// Returns TRUE if link is mouth->(vagina/breasts/penis/anus).
/datum/erp_vfx_service/proc/link_is_sucking(datum/erp_sex_link/L)
	if(!L || QDELETED(L) || !L.is_valid())
		return FALSE

	var/datum/erp_sex_organ/init = L.init_organ
	var/datum/erp_sex_organ/tgt  = L.target_organ
	if(!init || !tgt)
		return FALSE

	if(init.erp_organ_type != SEX_ORGAN_MOUTH)
		return FALSE

	return (tgt.erp_organ_type in list(SEX_ORGAN_VAGINA, SEX_ORGAN_BREASTS, SEX_ORGAN_PENIS, SEX_ORGAN_ANUS))

/// Plays sucking sounds.
/datum/erp_vfx_service/proc/play_suck(mob/living/carbon/human/user, datum/erp_sex_link/best)
	if(!istype(user) || !best)
		return

	if(user.gender == FEMALE)
		playsound(user,
			pick('sound/misc/mat/girlmouth (1).ogg','sound/misc/mat/girlmouth (2).ogg','sound/misc/mat/oral (1).ogg','sound/misc/mat/oral (2).ogg','sound/misc/mat/oral (3).ogg','sound/misc/mat/oral (4).ogg','sound/misc/mat/oral (5).ogg','sound/misc/mat/oral (6).ogg','sound/misc/mat/oral (7).ogg'),
			25, TRUE,
			ignore_walls = FALSE
		)
	else
		playsound(user,
			pick('sound/misc/mat/guymouth (2).ogg','sound/misc/mat/guymouth (3).ogg','sound/misc/mat/guymouth (4).ogg','sound/misc/mat/guymouth (5).ogg','sound/misc/mat/oral (1).ogg','sound/misc/mat/oral (2).ogg','sound/misc/mat/oral (3).ogg','sound/misc/mat/oral (4).ogg','sound/misc/mat/oral (5).ogg','sound/misc/mat/oral (6).ogg','sound/misc/mat/oral (7).ogg'),
			35, TRUE,
			ignore_walls = FALSE
		)

	var/volume_layer = 12
	switch(clamp(round(best.force || SEX_FORCE_MID), SEX_FORCE_LOW, SEX_FORCE_EXTREME))
		if(SEX_FORCE_LOW)
			return
		if(SEX_FORCE_HIGH)
			volume_layer = 14
		if(SEX_FORCE_EXTREME)
			volume_layer = 16

	playsound(user,
		pick('sound/misc/mat/saliva (1).ogg','sound/misc/mat/saliva (2).ogg','sound/misc/mat/saliva (3).ogg'),
		volume_layer, TRUE, -2,
		ignore_walls = FALSE
	)

/// Plays thrust sound based on force.
/datum/erp_vfx_service/proc/play_thrust_sound(mob/living/carbon/human/user, datum/erp_sex_link/best)
	if(!istype(user) || !best)
		return

	var/action_force = clamp(round(best.force || SEX_FORCE_MID), SEX_FORCE_LOW, SEX_FORCE_EXTREME)
	var/sound

	switch(action_force)
		if(SEX_FORCE_LOW, SEX_FORCE_MID)
			sound = pick(SEX_SOUNDS_SLOW)
		if(SEX_FORCE_HIGH, SEX_FORCE_EXTREME)
			sound = pick(SEX_SOUNDS_HARD)

	if(sound)
		playsound(user, sound, 30, TRUE, -2, ignore_walls = FALSE)

/// Spawns hearts VFX.
/datum/erp_vfx_service/proc/spawn_hearts(mob/living/carbon/human/user)
	if(!istype(user))
		return

	for(var/i in 1 to rand(1, 3))
		if(!user.cmode)
			new /obj/effect/temp_visual/heart/sex_effects(get_turf(user))
		else
			new /obj/effect/temp_visual/heart/sex_effects/red_heart(get_turf(user))

/// Converts zone key to bodyzone const.
/datum/erp_vfx_service/proc/zone_key_to_bodyzone(zone)
	switch(zone)
		if("groin") return BODY_ZONE_PRECISE_GROIN
		if("chest") return BODY_ZONE_CHEST
		if("mouth") return BODY_ZONE_PRECISE_MOUTH
	return null

/// Tries bed break on strong thrust.
/datum/erp_vfx_service/proc/try_bed_break(datum/erp_sex_link/L, mob/living/user, atom/movable/target, time)
	if(!L || QDELETED(L) || !L.is_valid())
		return
	if(!user || !target)
		return

	var/force = clamp(round(L.force || SEX_FORCE_MID), SEX_FORCE_LOW, SEX_FORCE_EXTREME)
	if(force <= SEX_FORCE_MID)
		return

	var/obj/structure/bed/rogue/bed = find_bed_for_thrust(L, user, target)
	if(!bed || QDELETED(bed))
		return

	var/oldy = bed.pixel_y
	var/target_y = oldy - 1
	var/t = max(1, round(time / 2))
	animate(bed, pixel_y = target_y, time = t)
	animate(pixel_y = oldy, time = t)
	bed.damage_bed(force > SEX_FORCE_HIGH ? 0.5 : 0.25)

/// Finds closest bed for thrust animation.
/datum/erp_vfx_service/proc/find_bed_for_thrust(datum/erp_sex_link/L, mob/living/user, atom/movable/target)
	var/mob/living/A = L.actor_active?.physical
	var/mob/living/B = L.actor_passive?.physical

	var/turf/tB = get_turf(B) || get_turf(target)
	var/turf/tA = get_turf(A) || get_turf(user)

	var/obj/structure/bed/rogue/bed = null

	if(tB)
		bed = find_bed_on_turf(tB)
		if(bed) return bed

	if(tA)
		bed = find_bed_on_turf(tA)
		if(bed) return bed

	if(tB)
		for(var/turf/T in orange(1, tB))
			bed = find_bed_on_turf(T)
			if(bed) return bed

	return null

/// Finds bed object on a turf.
/datum/erp_vfx_service/proc/find_bed_on_turf(turf/T)
	if(!T)
		return null
	for(var/obj/structure/bed/rogue/B in T)
		return B
	return null
