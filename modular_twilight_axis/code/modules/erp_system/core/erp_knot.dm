/datum/component/erp_knotting
	var/list/active_links
	var/decay_timer_id
	var/movement_signals_registered = FALSE

/datum/component/erp_knotting/Initialize(...)
	. = ..()
	active_links = list()

/datum/component/erp_knotting/Destroy(force)
	stop_decay()
	unregister_movement_signals()

	if(active_links)
		active_links.Cut()

	. = ..()

/datum/component/erp_knotting/RegisterWithParent()
	. = ..()
	if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved), override = TRUE)

/datum/component/erp_knotting/UnregisterFromParent()
	. = ..()
	if(ismob(parent))
		UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	unregister_movement_signals()

/datum/component/erp_knotting/proc/start_decay()
	if(decay_timer_id)
		return
	decay_timer_id = addtimer(CALLBACK(src, PROC_REF(process_decay)), ERP_KNOT_DECAY_TICK, TIMER_STOPPABLE)

/datum/component/erp_knotting/proc/stop_decay()
	if(decay_timer_id)
		deltimer(decay_timer_id)
		decay_timer_id = null

/datum/component/erp_knotting/proc/process_decay()
	decay_timer_id = null

	if(!active_links || !active_links.len)
		stop_decay()
		return

	for(var/i = active_links.len, i >= 1, i--)
		var/datum/erp_knot_link/L = active_links[i]
		if(!istype(L) || !L.is_valid())
			active_links.Cut(i, i + 1)
			continue
		L.decay_tick()

	if(active_links.len)
		start_decay()

/datum/component/erp_knotting/proc/unregister_movement_signals()
	if(!movement_signals_registered)
		return

	for(var/datum/erp_knot_link/L as anything in active_links)
		if(!istype(L))
			continue
		if(istype(L.btm))
			UnregisterSignal(L.btm, COMSIG_MOVABLE_MOVED)

	movement_signals_registered = FALSE

/datum/component/erp_knotting/proc/register_movement_signals()
	if(movement_signals_registered)
		return

	for(var/datum/erp_knot_link/L as anything in active_links)
		if(!istype(L) || !L.is_valid())
			continue
		if(istype(L.btm))
			RegisterSignal(L.btm, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved), override = TRUE)

	movement_signals_registered = TRUE

/datum/component/erp_knotting/proc/has_knot_link(datum/erp_sex_organ/penis/penis_org, penis_unit_id = 0)
	return !!get_link_for_penis_unit(penis_org, penis_unit_id)

/datum/component/erp_knotting/proc/get_link_for_penis_unit(datum/erp_sex_organ/penis/penis_org, penis_unit_id = 0)
	if(!active_links || !active_links.len)
		return null
	for(var/datum/erp_knot_link/L as anything in active_links)
		if(!istype(L) || !L.is_valid())
			continue
		if(L.penis_org == penis_org && L.penis_unit_id == penis_unit_id)
			return L
	return null

/datum/component/erp_knotting/proc/get_forced_inject_target(datum/erp_sex_organ/penis/penis_org, penis_unit_id = 0)
	var/datum/erp_knot_link/L = get_link_for_penis_unit(penis_org, penis_unit_id)
	if(!L || !L.is_valid())
		return null
	return L.receiving_org

/datum/component/erp_knotting/proc/note_activity_between(datum/erp_sex_organ/penis/penis_org, datum/erp_sex_organ/other_org, penis_unit_id = 0)
	var/datum/erp_knot_link/L = get_link_for_penis_unit(penis_org, penis_unit_id)
	if(!L || !L.is_valid())
		return FALSE

	if(L.receiving_org != other_org)
		return FALSE

	L.note_activity()
	return TRUE

/datum/component/erp_knotting/proc/can_start_action_with_penis(datum/erp_sex_organ/penis/penis_org, datum/erp_sex_organ/target_org, penis_unit_id = 0)
	var/datum/erp_knot_link/L = get_link_for_penis_unit(penis_org, penis_unit_id)
	if(!L || !L.is_valid())
		return TRUE

	return (L.receiving_org == target_org)

/datum/component/erp_knotting/proc/try_knot_link(mob/living/target, datum/erp_sex_organ/penis/penis_org, datum/erp_sex_organ/receiving_org, penis_unit_id = 0, force_level = 0)
	var/mob/living/user = parent
	if(!istype(user) || !istype(target))
		return FALSE
	if(!penis_org || !receiving_org)
		return FALSE
	if(get_dist(user, target) > 1)
		return FALSE

	if(!penis_org.have_knot)
		return FALSE

	var/list/arousal_data = list()
	SEND_SIGNAL(user, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/arous = arousal_data["arousal"] || 0
	if(arous < AROUSAL_HARD_ON_THRESHOLD)
		to_chat(user, span_notice("My knot was too soft to tie."))
		return FALSE

	var/datum/erp_knot_link/existing = get_link_for_penis_unit(penis_org, penis_unit_id)
	if(existing)
		remove_single_link(existing, forceful = FALSE, who_pulled = user)

	var/datum/erp_knot_link/L = new(user, target, penis_org, receiving_org, penis_unit_id)
	active_links += L
	apply_knot_start_effects(L, force_level)
	register_movement_signals()
	start_decay()

	return TRUE

/datum/component/erp_knotting/proc/remove_all_for_penis(datum/erp_sex_organ/penis/penis_org, who_pulled = null, forceful = FALSE)
	if(!active_links || !active_links.len)
		return FALSE

	var/removed = FALSE
	for(var/i = active_links.len, i >= 1, i--)
		var/datum/erp_knot_link/L = active_links[i]
		if(!istype(L) || !L.is_valid())
			active_links.Cut(i, i + 1)
			continue
		if(L.penis_org != penis_org)
			continue

		remove_single_link(L, forceful, who_pulled)
		removed = TRUE

	if(!active_links.len)
		stop_decay()
		unregister_movement_signals()

	return removed

/datum/component/erp_knotting/proc/remove_link_for_pair(mob/living/btm, datum/erp_sex_organ/penis/penis_org, penis_unit_id = 0, who_pulled = null, forceful = FALSE)
	var/datum/erp_knot_link/L = get_link_for_penis_unit(penis_org, penis_unit_id)
	if(!L || !L.is_valid())
		return FALSE
	if(L.btm != btm)
		return FALSE

	remove_single_link(L, forceful, who_pulled)

	if(!active_links.len)
		stop_decay()
		unregister_movement_signals()

	return TRUE

/datum/component/erp_knotting/proc/try_pull_out(mob/living/actor, datum/erp_sex_organ/penis/penis_org, penis_unit_id = 0)
	var/datum/erp_knot_link/L = get_link_for_penis_unit(penis_org, penis_unit_id)
	if(!L || !L.is_valid())
		return FALSE

	var/mob/living/top = L.top
	var/mob/living/btm = L.btm

	if(!istype(actor))
		return FALSE

	var/is_owner = (actor == top)
	var/is_btm = (actor == btm)

	if(!is_owner && !is_btm)
		return FALSE

	var/chance = is_owner ? ERP_KNOT_PULL_OWNER_BASE : ERP_KNOT_PULL_BTM_BASE
	if(is_owner)
		chance += L.get_owner_bonus()

	if(is_btm)
		chance -= round((L.strength / 100) * 20)

	chance = clamp(chance, 5, 95)

	if(!prob(chance))
		L.try_increase_strength_from_movement()
		if(is_btm)
			to_chat(btm, span_warning("It's stuck... it won't budge!"))
		else
			to_chat(top, span_warning("My knot holds tight."))
		return FALSE

	if(is_owner)
		return remove_all_for_penis(penis_org, who_pulled = actor, forceful = FALSE)

	return remove_link_for_pair(btm, penis_org, penis_unit_id, who_pulled = actor, forceful = FALSE)

/datum/component/erp_knotting/proc/count_knots_on_target(mob/living/target)
	var/count = 0
	for(var/datum/erp_knot_link/L as anything in active_links)
		if(!istype(L) || !L.is_valid())
			continue
		if(L.btm == target)
			count++
	return count

/datum/component/erp_knotting/proc/apply_knot_start_effects(datum/erp_knot_link/L, force_level)
	if(!L || !L.is_valid())
		return

	var/mob/living/top = L.top
	var/mob/living/btm = L.btm
	if(!btm.has_status_effect(/datum/status_effect/knot_tied))
		btm.apply_status_effect(/datum/status_effect/knot_tied)
	if(!top.has_status_effect(/datum/status_effect/knotted))
		top.apply_status_effect(/datum/status_effect/knotted)

	top.visible_message(
		span_notice("[top] ties their knot inside of [btm]!"),
		span_notice("I tie my knot inside of [btm].")
	)

	var/k = count_knots_on_target(btm)
	if(btm.stat != DEAD)
		switch(k)
			if(1) to_chat(btm, span_userdanger("You have been knotted!"))
			if(2) to_chat(btm, span_userdanger("You have been double-knotted!"))
			if(3) to_chat(btm, span_userdanger("You have been triple-knotted!"))
			if(4) to_chat(btm, span_userdanger("You have been quad-knotted!"))
			if(5) to_chat(btm, span_userdanger("You have been penta-knotted!"))
			else to_chat(btm, span_userdanger("You have been ultra-knotted!"))

	if(force_level > SEX_FORCE_MID)
		var/datum/component/arousal/A = btm.GetComponent(/datum/component/arousal)
		if(force_level == SEX_FORCE_EXTREME)
			btm.apply_damage(30, BRUTE, BODY_ZONE_CHEST)
			A?.try_do_pain_effect(PAIN_HIGH_EFFECT, FALSE)
		else
			A?.try_do_pain_effect(PAIN_MILD_EFFECT, FALSE)
		btm.Stun(80)

/datum/component/erp_knotting/proc/remove_single_link(datum/erp_knot_link/L, forceful = FALSE, who_pulled = null)
	if(!L)
		return FALSE

	if(active_links && (L in active_links))
		active_links -= L

	if(!L.is_valid())
		if(!active_links || !active_links.len)
			stop_decay()
			unregister_movement_signals()
		qdel(L)
		return TRUE

	var/mob/living/top = L.top
	var/mob/living/btm = L.btm

	var/pain = L.get_pain_damage_on_removal()
	if(pain > 0)
		btm.apply_damage(pain, BRUTE, BODY_ZONE_CHEST)
		var/datum/component/arousal/A = btm.GetComponent(/datum/component/arousal)
		A?.try_do_pain_effect(PAIN_MILD_EFFECT, FALSE)
		btm.emote("painmoan", forced = TRUE)

	var/turf/T = get_turf(btm)
	if(T)
		new /obj/effect/decal/cleanable/coom(T)

	playsound(btm, 'sound/misc/mat/pop.ogg', 60, TRUE, -2, ignore_walls = FALSE)
	var/has_more_btm = FALSE
	for(var/datum/erp_knot_link/Other as anything in active_links)
		if(!istype(Other) || !Other.is_valid())
			continue
		if(Other.btm == btm)
			has_more_btm = TRUE
			break
	if(!has_more_btm)
		btm.remove_status_effect(/datum/status_effect/knot_tied)

	var/has_more_top = FALSE
	for(var/datum/erp_knot_link/Other2 as anything in active_links)
		if(!istype(Other2) || !Other2.is_valid())
			continue
		if(Other2.top == top)
			has_more_top = TRUE
			break
	if(!has_more_top)
		top.remove_status_effect(/datum/status_effect/knotted)

	if(!active_links || !active_links.len)
		stop_decay()
		unregister_movement_signals()

	qdel(L)
	return TRUE

/datum/component/erp_knotting/proc/on_moved(atom/movable/mover, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	if(!active_links || !active_links.len)
		return
	var/mob/living/M = mover
	if(QDELETED(mover) || !istype(M))
		return

	for(var/datum/erp_knot_link/L as anything in active_links)
		if(!istype(L) || !L.is_valid())
			continue
		if(mover != L.top && mover != L.btm)
			continue

		addtimer(CALLBACK(src, PROC_REF(handle_link_movement), L, mover), 1)

/datum/component/erp_knotting/proc/handle_link_movement(datum/erp_knot_link/L, mob/living/mover)
	if(!L || !L.is_valid())
		return

	var/mob/living/top = L.top
	var/mob/living/btm = L.btm

	#ifndef LOCALTEST
	if(isnull(top.client) || isnull(btm.client))
		remove_single_link(L, forceful = FALSE, who_pulled = null)
		return
	#endif

	L.try_increase_strength_from_movement()
	var/dist = get_dist(top, btm)
	if(dist <= 1)
		L.note_activity()
		btm.face_atom(top)
		top.set_pull_offsets(btm, GRAB_AGGRESSIVE)
		return

	if(dist < 6)
		L.note_activity()
		for(var/i in 1 to 3)
			step_towards(btm, top)
			if(get_dist(top, btm) <= 1)
				break
		btm.face_atom(top)
		top.set_pull_offsets(btm, GRAB_AGGRESSIVE)
		return

	remove_single_link(L, forceful = TRUE, who_pulled = mover)
