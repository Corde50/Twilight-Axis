/datum/erp_actor
	var/atom/active_actor
	var/atom/physical
	var/client/client
	var/list/datum/erp_sex_organ/organs = list()
	var/list/organs_by_type = list()
	var/list/action_slots = list()
	var/organs_dirty = TRUE
	var/datum/weakref/surrender_ref
	var/list/datum/erp_action/custom_actions = list()
	var/datum/weakref/effect_mob_ref

/datum/erp_actor/New(atom/A)
	. = ..()
	if(!A)
		qdel(src)
		return

	active_actor = A
	physical = A
	client = null

/datum/erp_actor/proc/post_init()
	rebuild_organs()
	load_custom_actions_from_prefs()

/datum/erp_actor/proc/rebuild_organs()
	organs.Cut()
	organs_by_type.Cut()
	action_slots.Cut()

	if(!active_actor || !physical)
		organs_dirty = FALSE
		return

	collect_organs()
	collect_species_overrides()
	sort_organs_by_ui_order()
	
	for(var/datum/erp_sex_organ/O in organs)
		var/type = O.erp_organ_type
		if(!type)
			continue

		if(!organs_by_type[type])
			organs_by_type[type] = list()
		organs_by_type[type] += O

	build_action_slots()
	organs_dirty = FALSE

/datum/erp_actor/proc/collect_organs()
	return

/datum/erp_actor/proc/collect_species_overrides()
	if(physical)
		var/datum/erp_sex_organ/body/B = get_or_create_body_organ()
		if(!(B in organs))
			add_organ(B)

		var/datum/erp_sex_organ/hand/H = get_or_create_hands_organ()
		if(!(H in organs))
			add_organ(H)

		var/datum/erp_sex_organ/legs/L = get_or_create_legs_organ()
		if(!(L in organs))
			add_organ(L)

/datum/erp_actor/proc/get_or_create_body_organ()
	for(var/datum/erp_sex_organ/O in organs)
		if(O.erp_organ_type == SEX_ORGAN_BODY)
			return O

	var/datum/erp_sex_organ/body/B = new(physical)
	B.erp_organ_type = SEX_ORGAN_BODY
	return B

/datum/erp_actor/proc/get_or_create_hands_organ()
	for(var/datum/erp_sex_organ/O in organs)
		if(O.erp_organ_type == SEX_ORGAN_HANDS)
			return O

	var/datum/erp_sex_organ/hand/H = new(physical)
	H.erp_organ_type = SEX_ORGAN_HANDS
	return H

/datum/erp_actor/proc/get_or_create_legs_organ()
	for(var/datum/erp_sex_organ/O in organs)
		if(O.erp_organ_type == SEX_ORGAN_LEGS)
			return O

	var/datum/erp_sex_organ/legs/L = new(physical)
	L.erp_organ_type = SEX_ORGAN_LEGS
	return L

/datum/erp_actor/proc/add_organ(datum/erp_sex_organ/O)
	if(!O || QDELETED(O))
		return
	if(O in organs)
		return

	organs += O
	if(client && client.prefs)
		O.apply_prefs_if_possible()

/datum/erp_actor/proc/build_action_slots()
	for(var/datum/erp_sex_organ/O in organs)
		var/t = O.erp_organ_type
		if(!t)
			continue
		if(!action_slots[t])
			action_slots[t] = list()

		var/count = max(1, O.count_to_action)
		for(var/i = 1 to count)
			action_slots[t] += O

/datum/erp_actor/proc/get_action_slots_ref(erp_organ_type)
	if(organs_dirty)
		rebuild_organs()
	return action_slots[erp_organ_type] || list()

/datum/erp_actor/proc/get_free_action_organs(erp_organ_type)
	var/list/out = list()
	var/list/slots = get_action_slots_ref(erp_organ_type)
	if(!islist(slots) || !slots.len)
		return out

	var/list/seen = list()
	for(var/datum/erp_sex_organ/O in slots)
		if(!O || QDELETED(O) || seen[O])
			continue
		seen[O] = TRUE
		if(O.get_free_slots() > 0)
			out += O

	return out

/datum/erp_actor/proc/get_organs_ref(erp_organ_type = null)
	if(organs_dirty)
		rebuild_organs()

	if(!erp_organ_type)
		return organs
	return organs_by_type[erp_organ_type] || list()

/datum/erp_actor/proc/mark_organs_dirty()
	organs_dirty = TRUE

/datum/erp_actor/proc/get_organ_by_id(id)
	if(!id)
		return null

	for(var/datum/erp_sex_organ/O in get_organs_ref())
		if("\ref[O]" == id || O == id)
			return O

	return null

/datum/erp_actor/proc/is_surrendering_to(datum/erp_actor/other)
	var/datum/erp_actor/A = surrender_ref?.resolve()
	if(!A || QDELETED(A))
		surrender_ref = null
		return FALSE
	return A == other

/datum/erp_actor/proc/is_restrained(organ_flags = null)
	return FALSE

/datum/erp_actor/proc/has_kink_tag(kink_typepath)
	return FALSE

/datum/erp_actor/proc/apply_erp_effect(arousal_amt, pain_amt, giving, applied_force = SEX_FORCE_MID, applied_speed = SEX_SPEED_MID, organ_id = null)
	var/mob/living/M = get_effect_mob()
	if(!M)
		return

	SEND_SIGNAL(M, COMSIG_SEX_RECEIVE_ACTION, arousal_amt, pain_amt, giving, applied_force, applied_speed, organ_id)

/datum/erp_actor/proc/create_custom_action()
	var/datum/erp_action/A = new
	A.id = "custom_[world.time]_[rand(1000,9999)]"
	A.name = "Новое действие"
	A.ckey = client?.ckey
	A.abstract = FALSE
	custom_actions += A
	return A

/datum/erp_actor/proc/get_all_actions()
	var/list/out = list()
	for(var/k in SSerp.actions)
		var/datum/erp_action/A = SSerp.actions[k]
		if(!A.abstract_type)
			out += A

	for(var/datum/erp_action/A in custom_actions)
		out += A

	return out

/datum/erp_actor/proc/get_custom_actions()
	var/list/out = list()
	if(custom_actions && custom_actions.len)
		out += custom_actions
	return out

/datum/erp_actor/proc/update_custom_action(action_id, field, value)
	for(var/datum/erp_action/A in custom_actions)
		if(A.id == action_id)
			return A.set_field(field, value)
	return FALSE

/datum/erp_actor/proc/delete_custom_action(action_id)
	for(var/datum/erp_action/A in custom_actions)
		if(A.id == action_id)
			custom_actions -= A
			qdel(A)
			return TRUE
	return FALSE

/datum/erp_actor/proc/load_custom_actions_from_prefs()
	custom_actions.Cut()

	var/client/C = client
	if(!C || !C.prefs)
		return

	var/list/data = C.prefs.erp_custom_actions
	if(!islist(data))
		return

	for(var/id in data)
		var/list/action_data = data[id]
		if(!islist(action_data))
			continue

		var/datum/erp_action/A = new
		A.import_from_prefs(action_data)
		A.id = id
		A.ckey = C.ckey
		A.abstract = FALSE
		custom_actions += A

/datum/erp_actor/proc/save_custom_actions_to_prefs()
	var/client/C = client
	if(!C || !C.prefs)
		return

	var/list/out = list()
	for(var/datum/erp_action/A in custom_actions)
		out[A.id] = A.export_for_prefs()

	C.prefs.erp_custom_actions = out
	C.prefs.save_preferences()

/datum/erp_actor/proc/get_organ_type_filters_ui()
	var/list/out = list()
	if(organs_dirty)
		rebuild_organs()

	for(var/type in action_slots)
		var/list/slots = action_slots[type]
		if(!islist(slots) || !slots.len)
			continue

		var/total = slots.len
		var/free = 0
		var/list/seen = list()

		for(var/datum/erp_sex_organ/O in slots)
			if(seen[O])
				continue
			seen[O] = TRUE
			free += O.get_free_slots()

		free = clamp(free, 0, total)

		out += list(list(
			"type" = "[type]",
			"name" = "[type]",
			"total" = total,
			"free" = free,
			"busy" = (free <= 0)
		))

	return out

/mob/living/proc/get_erp_organs()
	var/list/L = list()

	var/mob/living/carbon/human/H = src
	if(!istype(H))
		return L

	for(var/obj/item/organ/O in H.internal_organs)
		if(O.sex_organ)
			L += O.sex_organ

	for(var/obj/item/bodypart/B in H.bodyparts)
		if(B.sex_organ)
			L += B.sex_organ

	return L

/datum/erp_actor/proc/has_big_breasts()
	return FALSE

/datum/erp_actor/proc/is_dullahan_scene()
	return FALSE

/datum/erp_actor/proc/get_selected_zone()
	var/atom/A = physical
	if(!A || !ismob(A))
		return null
	var/mob/M = A
	return M.zone_selected

/datum/erp_actor/proc/get_zone_text(zone)
	var/list/zone_translations = list(
		BODY_ZONE_HEAD              = "голову",
		BODY_ZONE_CHEST             = "туловище",
		BODY_ZONE_R_ARM             = "правую руку",
		BODY_ZONE_L_ARM             = "левую руку",
		BODY_ZONE_R_LEG             = "правую ногу",
		BODY_ZONE_L_LEG             = "левую ногу",
		BODY_ZONE_PRECISE_R_INHAND  = "правую ладонь",
		BODY_ZONE_PRECISE_L_INHAND  = "левую ладонь",
		BODY_ZONE_PRECISE_R_FOOT    = "правую ступню",
		BODY_ZONE_PRECISE_L_FOOT    = "левую ступню",
		BODY_ZONE_PRECISE_SKULL     = "лоб",
		BODY_ZONE_PRECISE_EARS      = "уши",
		BODY_ZONE_PRECISE_R_EYE     = "правый глаз",
		BODY_ZONE_PRECISE_L_EYE     = "левый глаз",
		BODY_ZONE_PRECISE_NOSE      = "нос",
		BODY_ZONE_PRECISE_MOUTH     = "рот",
		BODY_ZONE_PRECISE_NECK      = "шею",
		BODY_ZONE_PRECISE_STOMACH   = "живот",
		BODY_ZONE_PRECISE_GROIN     = "пах",
	)
	return zone_translations[zone] || "тело"

/datum/erp_actor/proc/normalize_target_zone(zone, datum/erp_actor/other_actor)
	return zone

/datum/erp_actor/proc/get_target_zone_text_for(datum/erp_actor/target_actor)
	var/zone = get_selected_zone()
	if(!zone)
		return "тело"
	zone = target_actor?.normalize_target_zone(zone, src) || zone
	return target_actor?.get_zone_text(zone) || get_zone_text(zone)

/datum/erp_actor/proc/get_climax_score_for_link(datum/erp_sex_link/L)
	if(!L)
		return 0
	var/s = 0
	s += (L.speed || 0) * 10
	s += (L.force || 0) * 25
	return s

/datum/erp_actor/proc/build_climax_result(datum/erp_sex_link/L)
	if(!L)
		return null

	var/is_active = (L.actor_active == src)
	if(is_active)
		var/mode = "outside"
		if(L.session)
			var/datum/erp_sex_organ/penis/P = L.session.get_owner_penis_organ()
			if(P && P.climax_mode)
				mode = "[P.climax_mode]"

		if(mode == "inside")
			return list("type" = "into", "partner" = L.actor_passive, "intimate" = TRUE)

		return list("type" = "outside", "partner" = L.actor_passive, "intimate" = FALSE)

	return list("type" = "self", "partner" = L.actor_active, "intimate" = FALSE)

/datum/erp_actor/proc/get_ref()
	return "\ref[src]"

/datum/erp_actor/proc/get_movable()
	return istype(physical, /atom/movable) ? physical : null

/datum/erp_actor/proc/get_mob()
	return ismob(physical) ? physical : null

/datum/erp_actor/proc/is_owner_client(mob/requester)
	if(!requester)
		return FALSE
	return requester.client && requester.client == get_client()

/datum/erp_actor/proc/get_actor_turf()
	var/atom/A = physical
	return A ? get_turf(A) : null

/datum/erp_actor/proc/send_visible_message(text)
	var/mob/M = get_mob()
	if(M)
		M.visible_message(text)
		return TRUE
	return FALSE

/datum/erp_actor/proc/send_private_message(text)
	var/mob/M = get_mob()
	if(M)
		to_chat(M, text)
		return TRUE
	return FALSE

/datum/erp_actor/proc/stamina_add(delta)
	return

/datum/erp_actor/proc/get_highest_grab_state_on(datum/erp_actor/other)
	return 0

/datum/erp_actor/proc/can_register_signals()
	return FALSE

/datum/erp_actor/proc/is_organ_accessible_for(datum/erp_actor/by_actor, organ_type, allow_force = FALSE)
	return TRUE

/datum/erp_actor/proc/has_testicles()
	return FALSE

/datum/erp_actor/proc/set_effect_mob(mob/living/M)
	if(M && !QDELETED(M))
		effect_mob_ref = WEAKREF(M)
	else
		effect_mob_ref = null

/datum/erp_actor/proc/get_effect_mob()
	var/mob/living/M = effect_mob_ref?.resolve()
	if(M && !QDELETED(M))
		return M
	return get_mob()

/datum/erp_actor/proc/get_signal_mob()
	return get_effect_mob()

/datum/erp_actor/proc/get_control_mob(client/C = null)
	var/mob/living/M = get_mob()
	if(M)
		return M

	M = get_effect_mob()
	if(M)
		return M

	return C?.mob

/datum/erp_actor/proc/attach_client(client/C)
	client = C

/datum/erp_actor/proc/get_display_name()
	var/atom/A = physical || active_actor
	if(A)
		return "[A]"
	return "unknown"

/datum/erp_actor/proc/is_mob()
	return ismob(physical)

/datum/erp_actor/proc/get_client()
	if(client)
		return client
	return (ismob(physical) ? (physical:client) : null)

/datum/erp_actor/proc/sort_organs_by_ui_order()
	if(!islist(organs) || !organs.len)
		return

	var/list/ordered = list()
	var/list/used = list()
	for(var/t in ERP_ORGAN_ORDER)
		for(var/datum/erp_sex_organ/O in organs)
			if(!O || QDELETED(O) || used[O])
				continue
			if(O.erp_organ_type == t)
				ordered += O
				used[O] = TRUE

	for(var/datum/erp_sex_organ/O2 in organs)
		if(!O2 || QDELETED(O2) || used[O2])
			continue
		ordered += O2
		used[O2] = TRUE

	organs = ordered
