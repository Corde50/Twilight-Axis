/datum/erp_controller
	var/datum/erp_actor/owner
	var/client/owner_client
	var/datum/erp_actor/active_actor
	var/list/datum/erp_actor/actors = list()
	var/list/datum/erp_sex_link/links = list()
	var/datum/erp_sex_ui/ui
	var/datum/erp_actor/active_partner
	var/hidden_mode = FALSE
	var/yield_to_partner = FALSE
	var/do_until_finished = TRUE
	var/allow_user_moan = TRUE
	var/arousal_frozen = FALSE
	var/do_knot_action = FALSE
	var/last_scene_tick = 0
	var/next_scene_tick = 0
	var/scene_active = FALSE
	var/scene_started_at = 0
	var/last_scene_message_link_ref = null

/datum/erp_controller/New(atom/initial_owner, client/C = null, mob/living/effect_mob = null)
	. = ..()
	if(!initial_owner || QDELETED(initial_owner))
		qdel(src)
		return

	owner_client = C
	owner = SSerp.create_actor(initial_owner, owner_client, effect_mob)
	if(!owner)
		qdel(src)
		return

	if(owner_client)
		owner.attach_client(owner_client)

	actors += owner
	var/mob/ui_host = owner.get_control_mob(owner_client)
	if(!ui_host || !ui_host.client)
		ui_host = owner_client?.mob

	if(!ui_host || !ui_host.client)
		ui = null
	else
		ui = new(ui_host, src)

	SSerp.register_controller(src)
	if(owner.can_register_signals())
		register_actor_signals(owner)

/datum/erp_controller/Destroy()
	if(links)
		for(var/datum/erp_sex_link/L in links)
			if(L)
				L.finish()
				qdel(L)
		links.Cut()

	if(actors)
		for(var/datum/erp_actor/A in actors)
			if(A?.can_register_signals())
				unregister_actor_signals(A)

	SSerp.unregister_controller(src)
	if(ui)
		qdel(ui)
		ui = null

	var/datum/erp_actor/old_owner = owner
	owner = null
	if(actors)
		for(var/datum/erp_actor/A2 in actors)
			if(A2 && A2 != old_owner)
				qdel(A2)
		actors = null

	if(old_owner)
		qdel(old_owner)

	active_partner = null
	owner_client = null
	return ..()

/datum/erp_controller/proc/register_actor_signals(datum/erp_actor/A)
	if(!A || !A.can_register_signals())
		return

	var/mob/M = A.get_signal_mob()
	if(!M)
		return

	RegisterSignal(M, COMSIG_MOVABLE_MOVED, PROC_REF(on_pair_moved))
	RegisterSignal(M, COMSIG_ERP_GET_LINKS, PROC_REF(on_get_links))
	RegisterSignal(M, COMSIG_SEX_CLIMAX, PROC_REF(on_arousal_climax))
	RegisterSignal(M, COMSIG_SEX_AROUSAL_CHANGED, PROC_REF(on_arousal_changed))
	RegisterSignal(M, COMSIG_ERP_ANATOMY_CHANGED, PROC_REF(on_anatomy_changed))

/datum/erp_controller/proc/unregister_actor_signals(datum/erp_actor/A)
	if(!A)
		return

	var/mob/M = A.get_signal_mob()
	if(!M)
		return

	UnregisterSignal(M, COMSIG_MOVABLE_MOVED, PROC_REF(on_pair_moved))
	UnregisterSignal(M, COMSIG_ERP_GET_LINKS, PROC_REF(on_get_links))
	UnregisterSignal(M, COMSIG_SEX_CLIMAX, PROC_REF(on_arousal_climax))
	UnregisterSignal(M, COMSIG_SEX_AROUSAL_CHANGED, PROC_REF(on_arousal_changed))
	UnregisterSignal(M, COMSIG_ERP_ANATOMY_CHANGED, PROC_REF(on_anatomy_changed))

/datum/erp_controller/proc/on_anatomy_changed(datum/source)
	SIGNAL_HANDLER

	var/mob/living/M = source
	if(!istype(M))
		return

	var/datum/erp_actor/A = get_actor_by_mob(M)
	if(!A)
		return

	A.mark_organs_dirty()
	ui?.request_update()

/datum/erp_controller/proc/open_ui(mob/user = null)
	if(!ui)
		return

	var/mob/M = _get_ui_user(user)
	if(!M || !M.client)
		return

	owner_client?.prefs?.apply_erp_kinks_to_mob(M)
	ui.ui_interact(M)

/datum/erp_controller/proc/build_ui_payload()
	return ui.build_payload()

/datum/erp_controller/proc/get_partners_ui()
	var/list/L = list()
	for(var/datum/erp_actor/A in actors)
		if(!A || A == owner)
			continue
		L += list(list(
			"ref" = A.get_ref(),
			"name" = A.get_display_name()
		))
	return L

/datum/erp_controller/proc/add_partner_atom(atom/target_atom, set_active = TRUE)
	if(!target_atom || QDELETED(target_atom))
		return

	for(var/datum/erp_actor/A in actors)
		if(A && (A.physical == target_atom || A.active_actor == target_atom))
			if(set_active)
				active_partner = A
			return

	var/datum/erp_actor/NA = SSerp.create_actor(target_atom)
	if(!NA)
		return

	actors += NA
	if(NA.can_register_signals())
		register_actor_signals(NA)

	if(ismob(target_atom) && owner?.get_client())
		var/mob/M = target_atom
		if(M?.client && M.client == owner.get_client())
			NA.attach_client(M.client)

	if(set_active)
		active_partner = NA

/datum/erp_controller/proc/add_partner(atom/target)
	if(!istype(target))
		return
	add_partner_atom(target)

/datum/erp_controller/proc/handle_stop_link(link_id)
	var/datum/erp_sex_link/L = find_link(link_id)
	if(!L)
		return FALSE
	stop_link_runtime(L)
	return TRUE

/datum/erp_controller/proc/process_links()
	for(var/i = links.len; i >= 1; i--)
		var/datum/erp_sex_link/L = links[i]
		if(!L || QDELETED(L) || !L.is_valid())
			stop_link_runtime(L)

	process_scene_tick()

/datum/erp_controller/proc/get_action_by_id_or_path(action_type)
	if(!action_type)
		return null

	var/datum/erp_action/A = SSerp.get_action(action_type)
	if(A)
		return A

	for(var/k in SSerp.actions)
		var/datum/erp_action/T = SSerp.actions[k]
		if(T && T.id == action_type)
			return T

	for(var/datum/erp_action/CA in owner.custom_actions)
		if(CA.id == action_type)
			return CA

	return null

/datum/erp_controller/proc/get_active_links_ui(mob/living/carbon/human/H)
	var/list/L = list()
	for(var/datum/erp_sex_link/S in links)
		L += list(list(
			"id" = "\ref[S]",
			"name" = S.action?.name,
			"actor_org" = "[S.init_organ?.erp_organ_type]",
			"target_org" = "[S.target_organ?.erp_organ_type]",
			"speed" = S.speed,
			"force" = S.force,
			"climax_target" = S.climax_target,
			"finish_mode" = S.finish_mode
		))

	return L

/datum/erp_controller/proc/stop_link(mob/user, link_id)
	if(!_is_owner_requester(user))
		return FALSE

	var/datum/erp_sex_link/L = find_link(link_id)
	if(!L)
		return FALSE

	stop_link_runtime(L)
	return TRUE

/datum/erp_controller/proc/stop_link_runtime(datum/erp_sex_link/L)
	if(!L || QDELETED(L))
		links -= L
		return
	if(!(L in links))
		return

	_send_link_finish_message(L)
	L.finish()
	links -= L
	qdel(L)

/datum/erp_controller/proc/find_link(link_id)
	if(!link_id)
		return null

	var/key = "[link_id]"
	for(var/datum/erp_sex_link/L in links)
		if(!L || QDELETED(L))
			continue
		if("\ref[L]" == key)
			return L

	return null

/datum/erp_controller/proc/set_link_speed(mob/user, link_id, value)
	if(!_is_owner_requester(user))
		return FALSE
	var/datum/erp_sex_link/L = find_link(link_id)
	if(!L)
		return FALSE
	L.speed = clamp(round(value), SEX_SPEED_LOW, SEX_SPEED_EXTREME)
	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/set_link_force(mob/user, link_id, value)
	if(!_is_owner_requester(user))
		return FALSE
	var/datum/erp_sex_link/L = find_link(link_id)
	if(!L)
		return FALSE
	L.force = clamp(round(value), SEX_FORCE_LOW, SEX_FORCE_EXTREME)
	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/set_link_finish_mode(mob/user, link_id, mode)
	if(!_is_owner_requester(user))
		return FALSE
	var/datum/erp_sex_link/L = find_link(link_id)
	if(!L)
		return FALSE
	if(!(mode in list("until_stop","until_climax")))
		return FALSE
	L.finish_mode = mode
	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/set_penis_climax_mode(mob/living/carbon/human/H, mode)
	if(!H || H.client != owner.client)
		return FALSE
	if(!(mode in list("outside","inside")))
		return FALSE

	var/datum/erp_sex_organ/penis/P = get_owner_penis_organ()
	if(!P)
		return FALSE

	P.climax_mode = mode
	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/get_owner_penis_organ()
	for(var/datum/erp_sex_organ/O in owner.get_organs_ref())
		if(istype(O, /datum/erp_sex_organ/penis))
			return O
	return null

/datum/erp_controller/proc/get_organs_status_ui(mob/living/carbon/human/H)
	var/list/out = list()
	for(var/datum/erp_sex_organ/O in owner.get_organs_ref())
		out += list(build_organ_status_entry(O))
	return out

/datum/erp_controller/proc/build_organ_status_entry(datum/erp_sex_organ/O)
	var/list/toggles = list()
	if(O.has_liquid_system())
		var/current = O.allow_overflow_spill
		toggles["has_overflow"] = TRUE
		toggles["overflow"] = current

	if(istype(O, /datum/erp_sex_organ/penis))
		toggles["has_erect"] = TRUE
		toggles["erect_mode"] = get_penis_erect_mode(O)

	var/list/links = list()
	for(var/datum/erp_sex_link/L in O.get_passive_links())
		links += list(list(
			"id" = "[L]",
			"mode" = "passive",
			"action_name" = L.action?.name,
			"other_organ" = "[L.init_organ?.erp_organ_type]"
		))
	
	for(var/datum/erp_sex_link/L in O.get_active_links())
		links += list(list(
			"id" = "[L]",
			"mode" = "active",
			"action_name" = L.action?.name,
			"other_organ" = "[L.target_organ?.erp_organ_type]"
		))

	return list(
		"id" = "[O]",
		"type" = "[O.erp_organ_type]",
		"name" = get_organ_ui_name(O),
		"sensitivity" = O.sensitivity,
		"pain" = O.pain,
		"busy" = O.is_busy(),
		"storage" = build_liquid_block(O.storage),
		"producing" = build_liquid_block(O.producing),
		"links" = links,
		"toggles" = toggles
	)

/datum/erp_controller/proc/get_organ_ui_name(datum/erp_sex_organ/O)
	switch(O.erp_organ_type)
		if(SEX_ORGAN_PENIS) return "Член"
		if(SEX_ORGAN_HANDS) return "Руки"
		if(SEX_ORGAN_LEGS) return "Ноги"
		if(SEX_ORGAN_TAIL) return "Хвост"
		if(SEX_ORGAN_BODY) return "Тело"
		if(SEX_ORGAN_MOUTH) return "Рот"
		if(SEX_ORGAN_ANUS) return "Анус"
		if(SEX_ORGAN_BREASTS) return "Грудь"
		if(SEX_ORGAN_VAGINA) return "Вагина"
	return "[O.erp_organ_type]"

/datum/erp_controller/proc/get_penis_erect_mode(datum/erp_sex_organ/penis/P)
	if(!istype(P))
		return "auto"

	return P.erect_mode

/datum/erp_controller/proc/build_liquid_block(datum/erp_liquid_storage/L)
	if(!L || L.capacity <= 0)
		return list(
			"has" = FALSE,
			"pct" = 0
		)

	var/cap = max(1, L.capacity)
	var/vol = clamp(L.total_volume(), 0, cap)
	var/pct = (vol / cap) * 100
	pct = clamp(round(pct, 0.1), 0, 100)

	return list(
		"has" = TRUE,
		"pct" = pct,
		"volume" = pct
	)

/datum/erp_controller/proc/get_kinks_ui(mob/living/M, datum/erp_actor/partner)
	if(!istype(M))
		return null

	var/datum/component/kinks/K = M.ensure_kinks_component()
	var/mob/living/PM = partner?.physical
	var/datum/component/kinks/PK = null
	if(istype(PM))
		PK = PM.ensure_kinks_component()

	var/list/entries = list()
	for(var/kink_type in GLOB.available_kinks)
		var/datum/kink/KD = GLOB.available_kinks[kink_type]
		if(!KD)
			continue

		var/kink_path = KD.type
		var/self_pref = K ? K.get_pref(kink_path) : 0
		var/partner_pref = null
		var/partner_pref_known = FALSE
		if(PM && PM == M)
			partner_pref = self_pref
			partner_pref_known = TRUE
		else if(PK)
			partner_pref_known = PK.has_pref(kink_path)
			if(partner_pref_known)
				partner_pref = PK.get_pref(kink_path)

		entries += list(list(
			"type" = "[kink_path]",
			"name" = KD.name,
			"description" = KD.description,
			"category" = KD.category,
			"pref" = self_pref,
			"partner_pref" = partner_pref_known ? partner_pref : null,
			"partner_pref_known" = partner_pref_known,
		))

	return list("entries" = entries)

/datum/erp_controller/proc/get_active_partner(mob/living/carbon/human/H)
	return active_partner

/datum/erp_controller/proc/set_organ_sensitivity(mob/living/carbon/human/H, organ_id, value)
	if(!istype(H))
		return FALSE

	var/datum/erp_sex_organ/O = owner.get_organ_by_id(organ_id)
	if(!O)
		return FALSE

	value = clamp(value, 0, O.sensitivity_max)
	O.sensitivity = value
	var/datum/preferences/P = H.client?.prefs
	if(P)
		var/key = "[O.erp_organ_type]"
		var/list/prefs = P.erp_organ_prefs[key]
		if(!islist(prefs))
			prefs = P.erp_organ_prefs[key] = list()

		prefs["sensitivity"] = O.sensitivity
		P.save_preferences()

	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/toggle_organ_overflow(mob/living/carbon/human/H, organ_id)
	if(!istype(H))
		return FALSE

	var/datum/erp_sex_organ/O = owner.get_organ_by_id(organ_id)
	if(!O || !O.has_liquid_system())
		return FALSE

	var/current = O.allow_overflow_spill
	O.allow_overflow_spill = !current
	var/datum/preferences/P = H.client?.prefs
	if(P)
		var/key = "[O.erp_organ_type]"
		var/list/prefs = P.erp_organ_prefs[key]
		if(!islist(prefs))
			prefs = P.erp_organ_prefs[key] = list()

		prefs["overflow"] = O.allow_overflow_spill
		P.save_preferences()

	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/set_organ_erect_mode(mob/living/carbon/human/H, organ_id, mode)
	if(!istype(H))
		return FALSE

	var/datum/erp_sex_organ/O = owner.get_organ_by_id(organ_id)
	if(!istype(O, /datum/erp_sex_organ/penis))
		return FALSE

	var/datum/erp_sex_organ/penis/P = O
	var/obj/item/organ/penis/OP = P.source_organ
	if(!OP)
		return FALSE

	P.erect_mode = mode
	switch(mode)
		if("auto")
			OP.disable_manual_erect()
		if("none")
			OP.set_manual_erect_state(ERECT_STATE_NONE)
		if("partial")
			OP.set_manual_erect_state(ERECT_STATE_PARTIAL)
		if("hard")
			OP.set_manual_erect_state(ERECT_STATE_HARD)
		else
			return FALSE
	
	if(OP.owner)
		OP.owner.update_body_parts(TRUE)

	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/set_kink_pref(mob/living/M, kink_type, value)
	if(!istype(M))
		return FALSE

	var/kink_path = kink_type
	if(istext(kink_type))
		kink_path = text2path(kink_type)

	if(!ispath(kink_path, /datum/kink))
		return FALSE

	var/datum/component/kinks/K = M.ensure_kinks_component()
	if(!K)
		return FALSE

	K.set_pref(kink_path, value)

	var/datum/preferences/P = M.client?.prefs
	if(P)
		P.capture_erp_kinks_from_mob(M)
		P.save_preferences()

	return TRUE

/datum/erp_controller/proc/on_get_links(datum/source, list/out_links)
	SIGNAL_HANDLER
	if(!islist(out_links) || !links || !links.len)
		return

	var/mob/living/M = source
	if(!istype(M))
		return

	for(var/datum/erp_sex_link/L in links)
		if(!L || QDELETED(L))
			continue

		var/mob/living/ma = L.actor_active?.get_effect_mob()
		var/mob/living/mp = L.actor_passive?.get_effect_mob()
		if(ma == M || mp == M)
			out_links += L

/datum/erp_controller/proc/get_action_templates_editor_ui(mob/living/carbon/human/H)
	return list()

/datum/erp_controller/proc/get_custom_actions_ui(mob/living/carbon/human/H)
	return list()

/datum/erp_controller/proc/create_custom_action(mob/living/H, list/params)
	if(!H || H.client != owner.client)
		return FALSE

	var/path_txt = params["type"] || params["template"]
	if(!path_txt)
		return FALSE

	var/path = text2path(path_txt)
	if(!ispath(path, /datum/erp_action))
		return FALSE

	var/datum/erp_action/A = new path
	A.id = "custom_[world.time]_[rand(1000,9999)]"
	A.ckey = owner.client?.ckey
	A.abstract = FALSE
	var/n = params["name"] || params["display_name"] || params["title"]
	if(!isnull(n))
		A.set_field("name", n)

	var/list/fields = params["fields"]
	if(islist(fields))
		for(var/list/F in fields)
			var/fid = F["id"]
			if(fid)
				A.set_field(fid, F["value"])

	owner.custom_actions += A
	owner.save_custom_actions_to_prefs()
	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/update_custom_action(mob/living/H, list/params)
	if(!H || H.client != owner.client)
		return FALSE

	var/action_id = params["id"]
	if(!action_id)
		return FALSE

	var/changed = FALSE
	if(params["field"])
		var/f = params["field"]
		var/v = params["value"]
		if(owner.update_custom_action(action_id, f, v))
			changed = TRUE

	var/list/fields = params["fields"]
	if(islist(fields))
		for(var/list/F in fields)
			var/fid = F["id"]
			if(fid && owner.update_custom_action(action_id, fid, F["value"]))
				changed = TRUE

	var/n = params["name"] || params["display_name"] || params["title"]
	if(!isnull(n))
		if(owner.update_custom_action(action_id, "name", n))
			changed = TRUE

	if(!changed)
		return FALSE

	owner.save_custom_actions_to_prefs()
	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/delete_custom_action(mob/living/H, id)
	if(!H || H.client != owner.client)
		return FALSE

	if(owner.delete_custom_action(id))
		owner.save_custom_actions_to_prefs()
		ui?.request_update()
		return TRUE

	return FALSE

/datum/erp_controller/proc/get_all_actions_for_ui(datum/erp_actor/actor, datum/erp_actor/partner)
	var/list/out = list()
	var/is_self = FALSE
	if(actor && partner)
		if(actor == partner)
			is_self = TRUE
		else if(actor.physical && partner.physical && actor.physical == partner.physical)
			is_self = TRUE

	for(var/k in SSerp.actions)
		var/datum/erp_action/A = SSerp.actions[k]
		if(!A)
			continue

		if(A.abstract || A.abstract_type)
			continue

		if(is_self)
			if(!ispath(A.type, /datum/erp_action/self))
				continue
		else
			if(!ispath(A.type, /datum/erp_action/other))
				continue

		out += A

	if(!is_self)
		for(var/datum/erp_action/A2 in owner.custom_actions)
			if(!A2)
				continue
			if(A2.abstract || A2.abstract_type)
				continue
			out += A2

	return out

/datum/erp_controller/proc/get_action_list_ui(actor_type, partner_type)
	var/list/out = list()
	if(!active_partner)
		return out

	var/mob/living/actor_mob = owner?.get_mob()
	var/mob/living/partner_mob = active_partner?.get_mob()
	var/turf/tA = actor_mob ? get_turf(actor_mob) : owner.get_actor_turf()
	var/turf/tB = partner_mob ? get_turf(partner_mob) : active_partner.get_actor_turf()
	var/same_tile = (tA && tB && tA == tB)
	var/grabstate = owner.get_highest_grab_state_on(active_partner) || 0
	var/has_passive_grab = (grabstate >= GRAB_PASSIVE)
	var/has_aggr_grab = (grabstate >= GRAB_AGGRESSIVE)
	var/list/p1 = _pick_first_free_by_type(owner)
	var/list/p2 = _pick_first_free_by_type(active_partner)
	var/datum/erp_sex_organ/any_init = p1["any"]
	var/list/init_by = p1["by"]
	var/datum/erp_sex_organ/any_tgt = p2["any"]
	var/list/tgt_by = p2["by"]
	var/datum/erp_sex_organ/forced_init = null
	if(actor_type)
		forced_init = init_by[actor_type]

	var/datum/erp_sex_organ/forced_tgt = null
	if(partner_type)
		forced_tgt = tgt_by[partner_type]

	var/list/self_access = list()
	var/list/other_access = list()
	for(var/datum/erp_action/Act in get_all_actions_for_ui(owner, active_partner))
		if(!Act || Act.abstract || Act.abstract_type)
			continue

		if(actor_type && Act.required_init_organ && Act.required_init_organ != actor_type)
			continue
		if(partner_type && Act.required_target_organ && Act.required_target_organ != partner_type)
			continue

		var/is_self = FALSE
		if(owner == active_partner)
			is_self = TRUE
		else if(owner.physical && active_partner.physical && owner.physical == active_partner.physical)
			is_self = TRUE

		if(is_self)
			if(!ispath(Act.type, /datum/erp_action/self))
				continue
		else
			if(!ispath(Act.type, /datum/erp_action/other))
				continue

		var/datum/erp_sex_organ/init = forced_init
		if(!init)
			if(Act.required_init_organ)
				init = init_by[Act.required_init_organ]
			else
				init = any_init

		var/datum/erp_sex_organ/tgt = forced_tgt
		if(!tgt)
			if(Act.required_target_organ)
				tgt = tgt_by[Act.required_target_organ]
			else
				tgt = any_tgt

		if(!init || !tgt)
			continue

		var/reason = null
		if(Act.require_same_tile && !(same_tile || has_passive_grab))
			reason = "Нужно быть на одном тайле или держать партнёра."

		else if(Act.require_grab && !has_aggr_grab)
			reason = "Нужен более сильный захват."

		else if(init.get_free_slots() <= 0)
			reason = "Орган занят."

		else
			if(istype(init, /datum/erp_sex_organ/penis))
				var/datum/erp_sex_organ/penis/Pk = init
				if(Pk.have_knot)
					var/mob/living/carbon/human/topk = Pk.get_owner()
					var/datum/component/erp_knotting/Kk = _get_knotting_component(topk)
					if(Kk)
						var/unit = 0
						if(!Kk.can_start_action_with_penis(Pk, tgt, unit))
							reason = "Член заузлован."

			if(isnull(reason) && !has_aggr_grab)
				var/it = init.erp_organ_type
				if(!(it in self_access))
					self_access[it] = owner.is_organ_accessible_for(owner, it, FALSE)
				if(!self_access[it])
					reason = "Орган-инициатор закрыт одеждой."
				else
					var/tt = tgt.erp_organ_type
					if(!(tt in other_access))
						other_access[tt] = active_partner.is_organ_accessible_for(owner, tt, FALSE)
					if(!other_access[tt])
						reason = "Цель закрыта одеждой."

			if(isnull(reason) && islist(Act.action_tags) && ("testicles" in Act.action_tags))
				if(!active_partner.has_testicles())
					reason = "У цели нет тестикул."

			if(isnull(reason))
				if(Act.inject_timing != INJECT_NONE && Act.inject_target_mode == INJECT_CONTAINER)
					if(!_has_nearby_container_for_action())
						reason = "Нужен контейнер с реагентами рядом."

			if(isnull(reason) && islist(Act.required_item_tags) && Act.required_item_tags.len)
				if(!_has_required_item_tags(owner, Act.required_item_tags))
					reason = "Нужна секс-игрушка."

		out += list(list(
			"id" = Act.id,
			"name" = Act.name,
			"can" = isnull(reason),
			"reason" = reason,
			"tags" = Act.action_tags,
			"is_custom" = (Act in owner.custom_actions)
		))

	return out

/datum/erp_controller/proc/_has_required_item_tags(datum/erp_actor/A, list/required_tags)
	if(!A || !islist(required_tags) || !required_tags.len)
		return TRUE

	var/mob/living/M = A.get_effect_mob()
	if(!M)
		return FALSE

	var/obj/item/I1 = M.get_active_held_item()
	if(_item_has_any_tag(I1, required_tags))
		return TRUE

	var/obj/item/I2 = M.get_inactive_held_item()
	if(_item_has_any_tag(I2, required_tags))
		return TRUE

	return FALSE

/datum/erp_controller/proc/_item_has_any_tag(obj/item/I, list/required_tags)
	if(!istype(I) || !islist(required_tags) || !required_tags.len)
		return FALSE
	if(!islist(I.erp_item_tags) || !I.erp_item_tags.len)
		return FALSE

	for(var/t in required_tags)
		if(t in I.erp_item_tags)
			return TRUE

	return FALSE

/datum/erp_controller/proc/can_start_action(datum/erp_action/A, datum/erp_sex_organ/init, datum/erp_sex_organ/target)
	return isnull(get_action_block_reason(A, init, target))

/datum/erp_controller/proc/get_action_block_reason(datum/erp_action/A, datum/erp_sex_organ/init, datum/erp_sex_organ/target)
	if(!A)
		return "Нет действия."
	if(!init)
		return "Нет органа-инициатора."
	if(!target)
		return "Нет цели."
	if(!active_partner)
		return "Нет партнёра."

	var/turf/tA = owner?.get_actor_turf()
	var/turf/tB = active_partner?.get_actor_turf()
	var/same_tile = (tA && tB && tA == tB)

	var/grabstate = owner.get_highest_grab_state_on(active_partner) || 0
	var/has_passive_grab = (grabstate >= GRAB_PASSIVE)
	var/has_agressive_grab = (grabstate >= GRAB_AGGRESSIVE)

	if(A.require_same_tile && !(same_tile || has_passive_grab))
		return "Нужно быть на одном тайле или держать партнёра."

	if(A.require_grab && grabstate < GRAB_AGGRESSIVE)
		return "Нужен более сильный захват."

	if(A.required_init_organ && init.erp_organ_type != A.required_init_organ)
		return "Нужен другой орган-инициатор."
	if(A.required_target_organ && target.erp_organ_type != A.required_target_organ)
		return "Нужна другая цель."

	if(!(owner.is_organ_accessible_for(owner, init.erp_organ_type, has_agressive_grab) || has_agressive_grab))
		return "Орган-инициатор закрыт одеждой."

	if(!(active_partner.is_organ_accessible_for(owner, target.erp_organ_type, has_agressive_grab) || has_agressive_grab))
		return "Цель закрыта одеждой."

	if(init.get_free_slots() <= 0)
		return "Орган занят."

	if(islist(A.action_tags) && ("testicles" in A.action_tags))
		if(!active_partner.has_testicles())
			return "У цели нет тестикул."

	if(A.inject_timing != INJECT_NONE && A.inject_target_mode == INJECT_CONTAINER)
		if(!_has_nearby_container_for_action())
			return "Нужен контейнер с реагентами рядом."

	if(islist(A.required_item_tags) && A.required_item_tags.len)
		if(!_has_required_item_tags(owner, A.required_item_tags))
			return "Нужна секс-игрушка."

	if(istype(init, /datum/erp_sex_organ/penis))
		var/datum/erp_sex_organ/penis/P = init
		if(P.have_knot)
			var/mob/living/carbon/human/top = P.get_owner()
			var/datum/component/erp_knotting/K = _get_knotting_component(top)
			if(K)
				var/unit = 0
				if(!K.can_start_action_with_penis(P, target, unit))
					return "Член заузлован."

	return null

/datum/erp_controller/proc/change_hidden_mode()
	hidden_mode = !hidden_mode

/datum/erp_controller/proc/change_yield_state()
	var/mob/living/carbon/human/user = owner?.get_mob()
	if(!istype(user))
		return

	yield_to_partner = !yield_to_partner

	var/mob/living/carbon/human/partner = _get_partner_effect_mob()
	if(!istype(partner))
		return

	if(yield_to_partner)
		user.set_sex_surrender_to(partner)
	else
		user.set_sex_surrender_to(null)

/datum/erp_controller/proc/change_freeze_arousal()
	var/mob/living/actor_object = _get_owner_effect_mob()
	if(!istype(actor_object))
		return

	SEND_SIGNAL(actor_object, COMSIG_SEX_FREEZE_AROUSAL)
	var/list/ad = list()
	SEND_SIGNAL(actor_object, COMSIG_SEX_GET_AROUSAL, ad)
	arousal_frozen = !!ad["frozen"]

/datum/erp_controller/proc/change_moaning()
	allow_user_moan = !allow_user_moan

/datum/erp_controller/proc/change_direction()
	var/mob/living/carbon/human/user = _get_owner_effect_mob()
	if(!istype(user))
		return

	if(!islist(user.mob_timers))
		user.mob_timers = list()

	var/last = user.mob_timers["sexpanel_flip"] || 0
	if(world.time < last + 1 SECONDS)
		return FALSE

	user.mob_timers["sexpanel_flip"] = world.time
	if(user.lying)
		if(user.lying == 270)
			user.lying = 90
		else
			user.lying = 270
		user.update_transform()
		user.lying_prev = user.lying

/datum/erp_controller/proc/full_stop()
	if(!links || !links.len)
		return 0

	var/list/to_stop = links.Copy()
	var/stopped = 0
	for(var/datum/erp_sex_link/L in to_stop)
		if(!L || QDELETED(L))
			continue
		if(!L.is_valid())
			stop_link_runtime(L)
			continue

		stop_link_runtime(L)
		stopped++

	ui?.request_update()
	return stopped

/datum/erp_controller/proc/get_actor_arousal_ui(mob/user)
	var/mob/living/A = _get_owner_effect_mob()
	if(!istype(A))
		return 0
	var/list/data = _get_arousal_data(A)
	return data ? (data["arousal"] || 0) : 0

/datum/erp_controller/proc/get_partner_arousal_ui(mob/user)
	var/mob/living/B = _get_partner_effect_mob()
	if(!istype(B))
		return 0

	if(is_partner_arousal_hidden(B))
		return null

	var/list/data = _get_arousal_data(B)
	return data ? (data["arousal"] || 0) : 0

/datum/erp_controller/proc/_get_arousal_data(mob/living/carbon/human/H)
	if(!istype(H))
		return null

	var/list/data = list()
	SEND_SIGNAL(H, COMSIG_SEX_GET_AROUSAL, data)

	if(!length(data))
		return null

	return data

/datum/erp_controller/proc/set_active_partner_by_ref(ref)
	if(!ref)
		return FALSE

	for(var/datum/erp_actor/A in actors)
		if(!A || A == owner)
			continue
		if(A.get_ref() == ref)
			active_partner = A
			return TRUE

	return FALSE

/datum/erp_controller/proc/is_partner_arousal_hidden(actor)
	if(!active_partner)
		return TRUE
	if(actor != active_partner)
		return TRUE
	return FALSE

/datum/erp_controller/proc/set_actor_arousal(actor, value = 0)
	var/mob/living/carbon/human/owner_mob = owner?.physical
	if(!istype(owner_mob) || !owner_mob.client)
		return FALSE

	var/mob/living/carbon/human/H = null
	if(istype(actor, /datum/erp_actor))
		var/datum/erp_actor/A = actor
		H = A.physical
	else if(istype(actor, /mob/living/carbon/human))
		H = actor
	else if(istext(actor))
		if("[owner_mob]" == actor)
			H = owner_mob

	if(H != owner_mob)
		return FALSE

	var/n = isnum(value) ? value : text2num("[value]")
	if(!isnum(n))
		return FALSE

	n = clamp(round(n), 0, MAX_AROUSAL)
	SEND_SIGNAL(owner_mob, COMSIG_SEX_SET_AROUSAL, n, TRUE)
	return TRUE

/datum/erp_controller/proc/send_message(text)
	if(!text)
		return

	var/mob/living/A = _get_owner_effect_mob()
	var/mob/living/B = _get_partner_effect_mob()

	if(hidden_mode)
		var/atom/center = A || owner?.physical || owner?.active_actor
		if(!center)
			if(A) to_chat(A, text)
			if(B) to_chat(B, text)
			return

		var/turf/CT = get_turf(center)
		if(!CT)
			if(A) to_chat(A, text)
			if(B) to_chat(B, text)
			return

		for(var/mob/M in viewers(2, CT))
			if(!M || QDELETED(M))
				continue
			to_chat(M, text)

		return

	if(A)
		A.visible_message(text)
	else if(B)
		B.visible_message(text)

/datum/erp_controller/proc/_find_nearby_container(mob/living/carbon/human/H, turf/center)
	if(!istype(H) || !center)
		return null

	var/obj/item/I = H.get_active_held_item()
	if(istype(I, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/C1 = I
		if(C1.reagents)
			return C1

	I = H.get_inactive_held_item()
	if(istype(I, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/C2 = I
		if(C2.reagents)
			return C2

	for(var/obj/item/reagent_containers/C3 in center)
		if(C3.reagents)
			return C3

	for(var/turf/T in orange(1, center))
		if(T == center)
			continue
		for(var/obj/item/reagent_containers/C4 in T)
			if(C4.reagents)
				return C4

	return null

/datum/erp_controller/proc/handle_inject(datum/erp_sex_link/link, datum/erp_sex_organ/source, target_mode, mob/living/carbon/human/who = null)
	if(!link || !source || QDELETED(source))
		return

	var/amount = 5
	var/datum/reagents/R = source.extract_reagents(amount)
	if(!R)
		return

	var/inject_mode = target_mode
	if(who && who == link.actor_active?.physical)
		if(link.climax_target == "outside" && source.erp_organ_type == SEX_ORGAN_PENIS)
			inject_mode = INJECT_GROUND

	var/target = null
	switch(inject_mode)
		if(INJECT_ORGAN)
			if(source == link.init_organ)
				target = link.target_organ
			else if(source == link.target_organ)
				target = link.init_organ
			else
				target = link.target_organ

		if(INJECT_CONTAINER)
			var/mob/living/carbon/human/H = null
			if(istype(who))
				H = who

			if(!H)
				H = source.get_owner()

			if(!H)
				H = link.actor_active?.physical

			var/turf/center = get_turf(H) || get_turf(link.actor_passive?.physical) || get_turf(link.actor_active?.physical)
			var/obj/item/reagent_containers/C = _find_nearby_container(H, center)
			if(!(C && C.reagents))
				var/mob/living/carbon/human/H2 = (H == link.actor_active?.physical) ? link.actor_passive?.physical : link.actor_active?.physical
				var/turf/center2 = get_turf(H2) || center
				C = _find_nearby_container(H2, center2)

			if(C && C.reagents)
				target = C
			else
				inject_mode = INJECT_GROUND

		if(INJECT_GROUND)
			target = get_turf(link.actor_passive?.physical) || get_turf(link.actor_active?.physical)

	if(!target)
		inject_mode = INJECT_GROUND
		target = get_turf(link.actor_passive?.physical) || get_turf(link.actor_active?.physical)

	source.route_reagents(R, inject_mode, target)

/datum/erp_controller/proc/get_organ_type_ui_name(type)
	switch(type)
		if(SEX_ORGAN_PENIS) return "Член"
		if(SEX_ORGAN_HANDS) return "Руки"
		if(SEX_ORGAN_LEGS) return "Ноги"
		if(SEX_ORGAN_TAIL) return "Хвост"
		if(SEX_ORGAN_BODY) return "Тело"
		if(SEX_ORGAN_MOUTH) return "Рот"
		if(SEX_ORGAN_ANUS) return "Анус"
		if(SEX_ORGAN_BREASTS) return "Грудь"
		if(SEX_ORGAN_VAGINA) return "Вагина"
	return "[type]"

/datum/erp_controller/proc/get_actor_type_filters_ui()
	var/list/L = owner?.get_organ_type_filters_ui() || list()
	for(var/list/E in L)
		E["name"] = get_organ_type_ui_name(E["type"])
	return L

/datum/erp_controller/proc/get_partner_type_filters_ui()
	if(!active_partner)
		return list()
	var/list/L = active_partner.get_organ_type_filters_ui() || list()
	for(var/list/E in L)
		E["name"] = get_organ_type_ui_name(E["type"])
	return L

/datum/erp_controller/proc/get_actor_nodes_by_filter_ui(type_filter)
	var/list/out = list()
	if(!type_filter)
		return out

	for(var/datum/erp_sex_organ/O in owner.get_organs_ref(type_filter))
		out += list(list(
			"id" = "[O]",
			"name" = get_organ_ui_name(O),
			"busy" = O.is_busy(),
			"free" = O.get_free_slots(),
			"total" = O.get_total_slots()
		))
	return out

/datum/erp_controller/proc/get_partner_nodes_by_filter_ui(type_filter)
	var/list/out = list()
	if(!active_partner || !type_filter)
		return out

	for(var/datum/erp_sex_organ/O in active_partner.get_organs_ref(type_filter))
		out += list(list(
			"id" = "[O]",
			"name" = get_organ_ui_name(O),
			"busy" = O.is_busy(),
			"free" = O.get_free_slots(),
			"total" = O.get_total_slots()
		))
	return out

/datum/erp_controller/proc/start_action_by_types(mob/living/carbon/human/H, action_id)
	if(!H || H.client != owner.client)
		return FALSE
	if(!active_partner)
		return FALSE

	var/datum/erp_action/A = get_action_by_id_or_path(action_id)
	if(!A)
		return FALSE

	var/mob/living/carbon/human/actor_object = owner?.physical
	var/mob/living/carbon/human/partner_object = active_partner?.physical
	if(!actor_object || !partner_object)
		return FALSE

	var/list/p1 = _pick_first_free_by_type(owner)
	var/list/p2 = _pick_first_free_by_type(active_partner)
	var/list/init_by = p1["by"]
	var/list/tgt_by  = p2["by"]
	var/datum/erp_sex_organ/any_init = p1["any"]
	var/datum/erp_sex_organ/any_tgt  = p2["any"]
	var/datum/erp_sex_organ/init = null
	if(A.required_init_organ)
		init = init_by[_normalize_organ_type(A.required_init_organ)]
	else
		init = any_init

	var/datum/erp_sex_organ/target = null
	if(A.required_target_organ)
		target = tgt_by[_normalize_organ_type(A.required_target_organ)]
	else
		target = any_tgt

	if(!init || !target)
		return FALSE

	var/reason = get_action_block_reason(A, init, target)
	if(!isnull(reason))
		return FALSE

	if(istype(init, /datum/erp_sex_organ/penis))
		var/datum/erp_sex_organ/penis/P = init
		if(P.have_knot)
			var/mob/living/carbon/human/top = P.get_owner()
			var/datum/component/erp_knotting/K = _get_knotting_component(top)
			if(K && !K.can_start_action_with_penis(P, target, 0))
				return FALSE

	var/list/organs = list("init" = init, "target" = target)
	var/datum/erp_sex_link/L = new(owner, active_partner, A, organs, src)
	links += L

	_send_link_start_message(L)

	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/on_pair_moved(atom/movable/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	if(!links || !links.len)
		return

	var/mob/living/mover = source
	if(!istype(mover))
		return

	var/list/to_stop = null

	for(var/datum/erp_sex_link/L in links)
		if(!L || QDELETED(L))
			continue

		var/mob/living/A = L.actor_active?.physical
		var/mob/living/B = L.actor_passive?.physical
		if(!A || !B)
			LAZYADD(to_stop, L)
			continue

		if(mover != A && mover != B)
			continue

		var/dist = get_dist(A, B)
		if(dist > 1)
			if(dist < 3 && _is_knot_pair_link(L))
				continue

			LAZYADD(to_stop, L)
			continue

		var/datum/erp_action/ACT = L.action
		if(!ACT || !ACT.allow_sex_on_move)
			LAZYADD(to_stop, L)

	if(!to_stop)
		return

	for(var/datum/erp_sex_link/L2 in to_stop)
		stop_link_runtime(L2)

	ui?.request_update()

/datum/erp_controller/proc/stop_pair_links(mob/living/A, mob/living/B, break_only_no_move = TRUE)
	if(!A || !B)
		return

	var/list/to_stop = null

	for(var/datum/erp_sex_link/L in links)
		if(!L || QDELETED(L))
			continue

		var/mob/living/la = L.actor_active?.physical
		var/mob/living/lb = L.actor_passive?.physical
		if(!la || !lb)
			continue

		if(!((la == A && lb == B) || (la == B && lb == A)))
			continue

		if(break_only_no_move)
			var/datum/erp_action/ACT = L.action
			if(ACT && ACT.allow_sex_on_move)
				continue

		LAZYADD(to_stop, L)

	if(!to_stop)
		return

	for(var/datum/erp_sex_link/L2 in to_stop)
		stop_link_runtime(L2)

/datum/erp_controller/proc/_pick_first_free_by_type(datum/erp_actor/A)
	var/list/by = list()
	var/datum/erp_sex_organ/any = null

	for(var/datum/erp_sex_organ/O in A.get_organs_ref())
		if(!O || O.get_free_slots() <= 0)
			continue
		if(!any) 
			any = O
		if(!by[O.erp_organ_type])
			by[O.erp_organ_type] = O

	return list("any" = any, "by" = by)

/datum/erp_controller/proc/_normalize_organ_type(v)
	if(isnull(v))
		return null
	if(isnum(v))
		return v

	var/t = "[v]"
	t = trim(t)
	if(!length(t) || t == "null")
		return null

	var/n = text2num(t)
	if(isnum(n) && "[n]" == t)
		return n

	return t

/datum/erp_controller/proc/process_scene_tick()
	var/list/active = list()
	if(links && links.len)
		for(var/datum/erp_sex_link/L in links)
			if(L && !QDELETED(L) && L.is_valid())
				active += L

	if(scene_active && !active.len)
		var/datum/erp_sex_link/last_best = last_scene_message_link_ref
		on_scene_ended(last_best)
		last_scene_message_link_ref = null
		next_scene_tick = 0
		last_scene_tick = 0
		return

	if(!active.len)
		return

	var/datum/erp_sex_link/best = pick_best_message_link(active)
	last_scene_message_link_ref = best

	if(!scene_active)
		on_scene_started(active, best)
		last_scene_tick = world.time
		next_scene_tick = world.time + calc_scene_interval(active)
		return

	if(!next_scene_tick)
		last_scene_tick = world.time
		next_scene_tick = world.time + calc_scene_interval(active)
		return

	if(world.time < next_scene_tick)
		return

	var/dt = max(1, world.time - last_scene_tick)
	last_scene_tick = world.time
	next_scene_tick = world.time + calc_scene_interval(active)

	apply_scene_effects(active, best, dt)
	var/msg = null
	if(best?.action)
		msg = best.action.build_tick(best)

	if(msg)
		var/list/fs = get_scene_force_speed_avg(active)
		var/avg_force = fs ? (fs["force"] || SEX_FORCE_MID) : SEX_FORCE_MID
		var/stam_cost = 0.5 * avg_force
		best?.actor_active?.stamina_add(-stam_cost)
		play_tick_effects(active, best, dt)
		send_message(best.spanify_sex(msg))

/datum/erp_controller/proc/calc_scene_interval(list/active_links)
	var/total = 0
	var/n = 0

	for(var/datum/erp_sex_link/L in active_links)
		var/t = L.get_effective_interval()
		if(!isnum(t) || t <= 0)
			continue
		total += t
		n++

	if(!n)
		return 3 SECONDS

	return round(total / n)

/datum/erp_controller/proc/pick_best_message_link(list/active_links)
	var/datum/erp_sex_link/best = null
	var/best_w = -1

	for(var/datum/erp_sex_link/L in active_links)
		var/w = L.get_message_weight()
		if(!isnum(w))
			w = 0
		if(L.is_aggressive())
			w += 0.25
		if(w > best_w)
			best_w = w
			best = L

	return best

/datum/erp_controller/proc/apply_scene_effects(list/active_links, datum/erp_sex_link/best, dt)
	var/n = active_links?.len || 0
	if(n <= 0)
		return

	var/a_arousal = 0
	var/a_pain    = 0
	var/p_arousal = 0
	var/p_pain    = 0

	var/avg_force = 0
	var/avg_speed = 0

	for(var/datum/erp_sex_link/L in active_links)
		if(!L || QDELETED(L) || !L.is_valid())
			continue

		_note_knot_activity_from_link(L)
		avg_force += (L.force || 0)
		avg_speed += (L.speed || 0)

		var/list/r = L.action?.calc_effect(L)
		if(!r)
			continue


		var/arA = r["active_arousal"]
		var/paA = r["active_pain"]
		var/arP = r["passive_arousal"]
		var/paP = r["passive_pain"]

		if(!isnum(arA)) arA = r["arousal"] || 0
		if(!isnum(arP)) arP = r["arousal"] || 0
		if(!isnum(paA)) paA = r["pain"]   || 0
		if(!isnum(paP)) paP = r["pain"]   || 0

		a_arousal += arA
		a_pain    += paA
		p_arousal += arP
		p_pain    += paP

		if(L.action && L.action.inject_timing == INJECT_CONTINUOUS)
			L.action.handle_inject(L, null)

	avg_force = clamp(round(avg_force / n), SEX_FORCE_LOW, SEX_FORCE_EXTREME)
	avg_speed = clamp(round(avg_speed / n), SEX_SPEED_LOW, SEX_SPEED_EXTREME)

	a_arousal /= n
	a_pain    /= n
	p_arousal /= n
	p_pain    /= n

	var/init_id = best?.init_organ?.erp_organ_type
	var/tgt_id  = best?.target_organ?.erp_organ_type

	var/mob/living/ma = best?.actor_active?.get_effect_mob()
	var/mob/living/mp = best?.actor_passive?.get_effect_mob()

	if(best?.actor_active)
		var/multA = _rel_mult_for(ma, mp)
		best.actor_active.apply_erp_effect(a_arousal * multA, a_pain, TRUE, avg_force, avg_speed, init_id)

	if(best?.actor_passive)
		var/multP = _rel_mult_for(mp, ma)
		best.actor_passive.apply_erp_effect(p_arousal * multP, p_pain, FALSE, avg_force, avg_speed, tgt_id)

/datum/erp_controller/proc/spanify_scene_text(text, force, speed, intensity = null)
	if(!text)
		return null

	var/level = clamp((force || 0) + (speed || 0), 1, 8)
	var/span_class = "love_mid"
	switch(level)
		if(1 to 2) span_class = "love_low"
		if(3 to 4) span_class = "love_mid"
		if(5 to 6) span_class = "love_high"
		if(7 to 8) span_class = "love_extreme"

	if(!isnull(intensity))
		var/i = clamp(round(intensity), 1, 5)
		switch(i)
			if(1) span_class = "love_low"
			if(2) span_class = "love_mid"
			if(3) span_class = "love_high"
			if(4 to 5) span_class = "love_extreme"
		text = "<b>[text]</b>"

	return "<span class='[span_class]'>[text]</span>"


/datum/erp_controller/proc/get_scene_force_speed_avg(list/active_links)
	var/n = 0
	var/sum_force = 0
	var/sum_speed = 0

	for(var/datum/erp_sex_link/L in active_links)
		if(!L || QDELETED(L) || !L.is_valid())
			continue
		n++
		sum_force += (L.force || 0)
		sum_speed += (L.speed || 0)

	if(!n)
		return list("force" = SEX_FORCE_MID, "speed" = SEX_SPEED_MID)

	return list(
		"force" = clamp(round(sum_force / n), SEX_FORCE_LOW, SEX_FORCE_EXTREME),
		"speed" = clamp(round(sum_speed / n), SEX_SPEED_LOW, SEX_SPEED_EXTREME),
	)

/datum/erp_controller/proc/on_scene_started(list/active_links, datum/erp_sex_link/best)
	scene_active = TRUE
	scene_started_at = world.time

	var/text = null
	if(best?.action)
		text = best.action.build_start(best)
	if(!text)
		text = "Сцена начинается."

	send_message(spanify_scene_start_end(text))

/datum/erp_controller/proc/on_scene_ended(datum/erp_sex_link/last_best)
	scene_active = FALSE
	scene_started_at = 0

	var/text = null
	if(last_best?.action)
		text = last_best.action.build_finish(last_best)
	if(!text)
		text = "Сцена заканчивается."

	send_message(spanify_scene_start_end(text))

/datum/erp_controller/proc/on_arousal_changed(datum/source)
	SIGNAL_HANDLER
	ui?.request_update()

/datum/erp_controller/proc/on_arousal_climax(datum/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/who = source
	if(!istype(who))
		return

	var/list/active = list()
	if(links && links.len)
		for(var/datum/erp_sex_link/L in links)
			if(L && !QDELETED(L) && L.is_valid())
				active += L

	if(!active.len)
		return

	var/datum/erp_sex_link/best = pick_best_climax_link(who, active)
	if(!best || !best.action)
		return

	var/datum/erp_actor/as_actor = null
	if(best.actor_active?.physical == who)
		as_actor = best.actor_active
	else if(best.actor_passive?.physical == who)
		as_actor = best.actor_passive

	var/text = best.action.build_climax(best, as_actor)
	if(text)
		send_message(spanify_scene_climax(text))

	INVOKE_ASYNC(src, PROC_REF(_handle_arousal_climax_effects), who, best)

	if(links && links.len)
		for(var/i = links.len; i >= 1; i--)
			var/datum/erp_sex_link/Lx = links[i]
			if(!Lx || QDELETED(Lx) || !Lx.is_valid())
				continue
			if(Lx.finish_mode != "until_climax")
				continue
			if(Lx.actor_active?.physical != who)
				continue

			stop_link_runtime(Lx)

/datum/erp_controller/proc/_handle_arousal_climax_effects(mob/living/carbon/human/who, datum/erp_sex_link/best)
	if(!istype(who) || !best || QDELETED(best) || !best.is_valid())
		return

	do_climax_effects(who, best)
	ui?.request_update()

/datum/erp_controller/proc/spanify_scene_start_end(text)
	if(!text)
		return null
	return "<span style='color:[ERP_SCENE_START_END_COLOR]; font-size:80%; font-weight:bold;'>[text]</span>"

/datum/erp_controller/proc/spanify_scene_climax(text)
	if(!text)
		return null
	return "<span style='color:[ERP_SCENE_CLIMAX_COLOR]; font-size:105%; font-weight:bold; letter-spacing:0.2px;'>[text]</span>"

/datum/erp_controller/proc/get_actor_by_mob(mob/living/M)
	if(!M)
		return null

	for(var/datum/erp_actor/A in actors)
		if(A?.physical == M)
			return A

	for(var/datum/erp_actor/A2 in actors)
		if(A2 && A2.get_signal_mob() == M)
			return A2

	return null

/datum/erp_controller/proc/pick_best_climax_link(mob/living/carbon/human/who, list/active_links)
	if(!who || !active_links || !active_links.len)
		return null

	var/datum/erp_sex_link/best = null
	var/best_score = -1
	for(var/datum/erp_sex_link/L in active_links)
		if(!L || QDELETED(L) || !L.is_valid())
			continue
		var/sc = L.get_climax_score(who)
		if(sc > best_score)
			best_score = sc
			best = L

	return best

/datum/erp_controller/proc/get_orgasm_context(mob/living/carbon/human/who, datum/erp_sex_link/best)
	if(!who || !best)
		return null

	var/is_active = (best.actor_active?.physical == who)
	var/datum/erp_sex_organ/base_org = is_active ? best.init_organ : best.target_organ
	var/datum/erp_sex_organ/other_org = is_active ? best.target_organ : best.init_organ
	var/mob/living/carbon/human/partner = is_active ? best.actor_passive?.physical : best.actor_active?.physical
	var/datum/erp_sex_organ/org = base_org
	if(org)
		var/t = org.erp_organ_type
		if(!(t in list(SEX_ORGAN_PENIS, SEX_ORGAN_VAGINA, SEX_ORGAN_BREASTS)))
			var/can_use_other = FALSE
			if(other_org)
				if(other_org.host == who)
					var/t2 = other_org.erp_organ_type
					if(t2 in list(SEX_ORGAN_PENIS, SEX_ORGAN_VAGINA, SEX_ORGAN_BREASTS))
						can_use_other = TRUE

			if(can_use_other)
				org = other_org

	return list(
		"is_active" = is_active,
		"organ" = org,
		"partner" = partner
	)


/datum/erp_controller/proc/apply_coating(mob/living/carbon/human/target, zone, datum/reagents/R, capacity = 30)
	if(!istype(target) || !R || R.total_volume <= 0)
		return FALSE

	var/datum/status_effect/erp_coating/E = null

	switch(zone)
		if("groin")
			E = target.has_status_effect(/datum/status_effect/erp_coating/groin)
			if(!E)
				E = target.apply_status_effect(/datum/status_effect/erp_coating/groin, capacity)

		if("chest")
			E = target.has_status_effect(/datum/status_effect/erp_coating/chest)
			if(!E)
				E = target.apply_status_effect(/datum/status_effect/erp_coating/chest, capacity)

		else
			E = target.has_status_effect(/datum/status_effect/erp_coating/body)
			if(!E)
				E = target.apply_status_effect(/datum/status_effect/erp_coating/body, capacity)

	if(!E)
		return FALSE

	E.add_from(R, R.total_volume)
	return TRUE

/datum/erp_controller/proc/apply_coating_and_puddle(datum/erp_sex_organ/source_organ, mob/living/carbon/human/coat_mob, zone, mob/living/carbon/human/feet_mob, amount, capacity = 30)
	if(!source_organ || QDELETED(source_organ))
		return FALSE
	if(!istype(coat_mob) || !istype(feet_mob))
		return FALSE
	if(!amount || amount <= 0)
		return FALSE

	var/bodyzone = _zone_key_to_bodyzone(zone)
	if(bodyzone && !get_location_accessible(coat_mob, bodyzone))
		var/datum/reagents/Rwaste = source_organ.extract_reagents(amount * 2)
		if(Rwaste)
			Rwaste.clear_reagents()
			qdel(Rwaste)
		return TRUE

	var/datum/reagents/Rcoat = source_organ.extract_reagents(amount)
	if(Rcoat)
		apply_coating(coat_mob, zone, Rcoat, capacity)
		qdel(Rcoat)

	var/datum/reagents/Rpuddle = source_organ.extract_reagents(amount)
	if(!Rpuddle)
		return TRUE

	var/turf/T = get_turf(feet_mob)
	if(!T)
		Rpuddle.clear_reagents()
		qdel(Rpuddle)
		return TRUE

	var/obj/effect/decal/cleanable/coom/C = null
	for(var/obj/effect/decal/cleanable/coom/existing in T)
		C = existing
		break

	if(!C)
		C = new /obj/effect/decal/cleanable/coom(T)

	if(!C.reagents)
		C.reagents = new /datum/reagents(C.reagents_capacity)
		C.reagents.my_atom = C

	Rpuddle.trans_to(C, Rpuddle.total_volume, 1, TRUE, TRUE)
	Rpuddle.clear_reagents()
	qdel(Rpuddle)

	return TRUE

#define ERP_CLIMAX_AMOUNT_SINGLE 10
#define ERP_CLIMAX_AMOUNT_COATING 12
#define ERP_CLIMAX_AMOUNT_INSIDE 8

/datum/erp_controller/proc/do_climax_effects(mob/living/carbon/human/who, datum/erp_sex_link/best)
	if(!istype(who) || !best)
		return FALSE
	if(!best.is_valid())
		return FALSE

	var/list/ctx = get_orgasm_context(who, best)
	if(!islist(ctx))
		return FALSE

	var/is_active = ctx["is_active"] ? TRUE : FALSE
	var/datum/erp_sex_organ/orgasm_organ = ctx["organ"]
	if(!orgasm_organ)
		return FALSE

	var/mob/living/carbon/human/active_mob  = best.actor_active?.physical
	var/mob/living/carbon/human/passive_mob = best.actor_passive?.physical
	var/two_actors = (istype(active_mob) && istype(passive_mob) && active_mob != passive_mob)

	var/organ_type = orgasm_organ.erp_organ_type
	if(!(organ_type in list(SEX_ORGAN_PENIS, SEX_ORGAN_VAGINA, SEX_ORGAN_BREASTS)))
		return FALSE

	if(!two_actors)
		if(organ_type == SEX_ORGAN_VAGINA)
			return apply_coating_and_puddle(orgasm_organ, who, "groin", who, ERP_CLIMAX_AMOUNT_COATING, 30)

		if(organ_type == SEX_ORGAN_BREASTS)
			if(!orgasm_organ.producing || !orgasm_organ.producing.producing_reagent)
				return FALSE
			return apply_coating_and_puddle(orgasm_organ, who, "chest", who, ERP_CLIMAX_AMOUNT_COATING, 30)

		if(organ_type == SEX_ORGAN_PENIS)
			if(!orgasm_organ.producing || !orgasm_organ.producing.producing_reagent)
				return FALSE
			return apply_coating_and_puddle(orgasm_organ, who, "groin", who, ERP_CLIMAX_AMOUNT_COATING, 30)

		return FALSE

	if(organ_type == SEX_ORGAN_VAGINA)
		return apply_coating_and_puddle(orgasm_organ, who, "groin", who, ERP_CLIMAX_AMOUNT_COATING, 30)

	if(organ_type == SEX_ORGAN_BREASTS)
		if(!orgasm_organ.producing || !orgasm_organ.producing.producing_reagent)
			return FALSE
		return apply_coating_and_puddle(orgasm_organ, who, "chest", who, ERP_CLIMAX_AMOUNT_COATING, 30)

	if(organ_type == SEX_ORGAN_PENIS)
		if(!orgasm_organ.producing || !orgasm_organ.producing.producing_reagent)
			return FALSE

		var/datum/erp_sex_organ/penis/Pk = orgasm_organ
		var/mob/living/carbon/human/topk = Pk.get_owner()
		if(!istype(topk))
			return FALSE

		var/datum/component/erp_knotting/Kk = _get_knotting_component(topk)
		if(!Kk && Pk.have_knot)
			Kk = topk.AddComponent(/datum/component/erp_knotting)

		if(do_knot_action && Pk.have_knot && Kk)
			var/datum/erp_sex_organ/receiving = is_active ? best.target_organ : best.init_organ
			if(receiving && (receiving.erp_organ_type in list(SEX_ORGAN_VAGINA, SEX_ORGAN_ANUS, SEX_ORGAN_MOUTH)))
				var/mob/living/carbon/human/btm = passive_mob
				if(istype(btm))
					if(!Kk.get_forced_inject_target(Pk, 0))
						Kk.try_knot_link(btm, Pk, receiving, 0, best.force)

		var/datum/erp_sex_organ/forced_knot_target = null
		if(Kk && Pk.have_knot)
			forced_knot_target = Kk.get_forced_inject_target(Pk, 0)

		if(forced_knot_target)
			var/datum/reagents/Rk = orgasm_organ.extract_reagents(ERP_CLIMAX_AMOUNT_INSIDE)
			if(!Rk)
				return TRUE

			orgasm_organ.route_reagents(Rk, INJECT_ORGAN, forced_knot_target)
			qdel(Rk)

			if(istype(forced_knot_target, /datum/erp_sex_organ/vagina))
				var/datum/erp_sex_organ/vagina/Vk = forced_knot_target
				Vk.on_climax(who, 0, 0)

			return TRUE

		var/list/tags = best.action?.action_tags
		var/force_inside = FALSE
		var/force_outside = FALSE
		var/blocks_inside = FALSE

		if(islist(tags))
			if("inject_inside_only" in tags)  force_inside = TRUE
			if("inject_outside_only" in tags) force_outside = TRUE
			if("no_internal_climax" in tags)  blocks_inside = TRUE
		
		var/mode = "outside"
		if(force_inside)
			mode = "inside"
		else if(force_outside)
			mode = "outside"

		if(mode == "inside" && blocks_inside)
			mode = "outside"

		var/datum/erp_sex_organ/inside_target_organ = null
		if(mode == "inside")
			inside_target_organ = is_active ? best.target_organ : best.init_organ

		if(mode == "inside")
			if(!inside_target_organ)
				mode = "outside"
			else
				var/it = inside_target_organ.erp_organ_type
				if(!(it in list(SEX_ORGAN_VAGINA, SEX_ORGAN_ANUS, SEX_ORGAN_MOUTH)))
					mode = "outside"

		if(mode == "inside" && inside_target_organ)
			var/datum/reagents/Rin = orgasm_organ.extract_reagents(ERP_CLIMAX_AMOUNT_INSIDE)
			if(!Rin)
				return TRUE

			orgasm_organ.route_reagents(Rin, INJECT_ORGAN, inside_target_organ)
			qdel(Rin)

			if(istype(inside_target_organ, /datum/erp_sex_organ/vagina))
				var/datum/erp_sex_organ/vagina/V = inside_target_organ
				V.on_climax(who, 0, 0)

			return TRUE

		var/mob/living/carbon/human/coating_target = null
		if(is_active)
			coating_target = passive_mob
		else
			coating_target = active_mob

		if(!istype(coating_target))
			return apply_coating_and_puddle(orgasm_organ, who, "groin", who, ERP_CLIMAX_AMOUNT_COATING, 30)

		return apply_coating_and_puddle(orgasm_organ, coating_target, "groin", coating_target, ERP_CLIMAX_AMOUNT_COATING, 30)

	return FALSE

#undef ERP_CLIMAX_AMOUNT_SINGLE
#undef ERP_CLIMAX_AMOUNT_COATING
#undef ERP_CLIMAX_AMOUNT_INSIDE

/datum/erp_controller/proc/_get_knotting_component(mob/living/carbon/human/H)
	if(!istype(H))
		return null
	return H.GetComponent(/datum/component/erp_knotting)

/datum/erp_controller/proc/_get_penis_unit_id_for_link(datum/erp_sex_link/L)
	return 0

/datum/erp_controller/proc/_is_knot_pair_link(datum/erp_sex_link/L)
	if(!L || QDELETED(L) || !L.is_valid())
		return FALSE

	var/datum/erp_sex_organ/init = L.init_organ
	var/datum/erp_sex_organ/tgt  = L.target_organ

	var/datum/erp_sex_organ/penis/P = null
	var/datum/erp_sex_organ/other = null

	if(istype(init, /datum/erp_sex_organ/penis))
		P = init
		other = tgt
	else if(istype(tgt, /datum/erp_sex_organ/penis))
		P = tgt
		other = init
	else
		return FALSE

	if(!P || !other)
		return FALSE

	var/mob/living/carbon/human/top = P.get_owner()
	var/datum/component/erp_knotting/K = _get_knotting_component(top)
	if(!K)
		return FALSE

	var/unit = _get_penis_unit_id_for_link(L)
	var/datum/erp_sex_organ/forced = K.get_forced_inject_target(P, unit)
	if(!forced)
		return FALSE

	return (forced == other)

/datum/erp_controller/proc/_note_knot_activity_from_link(datum/erp_sex_link/L)
	if(!L || QDELETED(L) || !L.is_valid())
		return

	var/datum/erp_sex_organ/init = L.init_organ
	var/datum/erp_sex_organ/tgt  = L.target_organ

	var/datum/erp_sex_organ/penis/P = null
	var/datum/erp_sex_organ/other = null

	if(istype(init, /datum/erp_sex_organ/penis))
		P = init
		other = tgt
	else if(istype(tgt, /datum/erp_sex_organ/penis))
		P = tgt
		other = init
	else
		return

	if(!P || !other)
		return

	var/mob/living/carbon/human/top = P.get_owner()
	var/datum/component/erp_knotting/K = _get_knotting_component(top)
	if(!K)
		return

	var/unit = _get_penis_unit_id_for_link(L)
	K.note_activity_between(P, other, unit)

/datum/erp_controller/proc/set_do_knot_action(mob/living/carbon/human/H, value)
	if(!H || H.client != owner.client)
		return FALSE

	var/datum/erp_sex_organ/penis/P = get_owner_penis_organ()
	if(!P || !P.have_knot)
		do_knot_action = FALSE
		ui?.request_update()
		return FALSE

	var/new_state
	if(isnull(value))
		new_state = !do_knot_action
	else
		new_state = value ? TRUE : FALSE

	do_knot_action = new_state
	ui?.request_update()
	return TRUE

/datum/erp_controller/proc/get_penis_knot_ui_state(mob/living/carbon/human/H)
	var/list/out = list(
		"has_knotted_penis" = FALSE,
		"can_knot_now" = FALSE,
	)

	if(!H || H.client != owner.client)
		return out

	var/datum/erp_sex_organ/penis/P = get_owner_penis_organ()
	if(!P || !P.have_knot)
		do_knot_action = FALSE
		return out

	var/mob/living/carbon/human/top = P.get_owner()
	var/datum/component/erp_knotting/K = _get_knotting_component(top)
	if(!K)
		return out

	var/unit = 0
	var/datum/erp_sex_organ/forced = K.get_forced_inject_target(P, unit)
	out["has_knotted_penis"] = forced ? TRUE : FALSE
	if(forced)
		out["can_knot_now"] = FALSE
		return out

	for(var/datum/erp_sex_link/L in links)
		if(!L || QDELETED(L) || !L.is_valid())
			continue
		if(L.actor_active != owner)
			continue

		var/datum/erp_sex_organ/other = null
		if(L.init_organ == P)
			other = L.target_organ
		else if(L.target_organ == P)
			other = L.init_organ
		else
			continue

		if(!other)
			continue

		if(K.can_start_action_with_penis(P, other, unit))
			out["can_knot_now"] = TRUE
			return out

	out["can_knot_now"] = FALSE
	return out

/datum/erp_controller/proc/should_show_penis_panel(mob/living/carbon/human/H, actor_type_filter)
	var/datum/erp_sex_organ/penis/P = get_owner_penis_organ()
	if(!P)
		return FALSE

	if(_normalize_organ_type(actor_type_filter) == SEX_ORGAN_PENIS)
		return TRUE

	if(!links || !links.len)
		return FALSE

	for(var/datum/erp_sex_link/L in links)
		if(!L || QDELETED(L) || !L.is_valid())
			continue
		if(L.actor_active != owner)
			continue

		if(L.init_organ == P || L.target_organ == P)
			return TRUE

	return FALSE

/datum/erp_controller/proc/_send_link_start_message(datum/erp_sex_link/L)
	if(!L || QDELETED(L) || !L.action)
		return
	var/text = L.action.build_start(L)
	if(!text)
		text = "Начинается: [L.action.name]."
	send_message(spanify_scene_start_end(text))

/datum/erp_controller/proc/_send_link_finish_message(datum/erp_sex_link/L)
	if(!L || QDELETED(L) || !L.action)
		return
	var/text = L.action.build_finish(L)
	if(!text)
		text = "Заканчивается: [L.action.name]."
	send_message(spanify_scene_start_end(text))

/datum/erp_controller/proc/_get_arousal_value(mob/living/carbon/human/H)
	if(!istype(H))
		return null
	var/list/data = list()
	SEND_SIGNAL(H, COMSIG_SEX_GET_AROUSAL, data)
	if(!length(data))
		return null
	return data["arousal"]

#define ERP_AROUSAL_HEARTS_THRESHOLD 20
#define ERP_TICK_EFFECT_COOLDOWN 2

/datum/erp_controller/proc/build_tick_effect_bundle(list/active_links, datum/erp_sex_link/best, dt)
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

		if(_link_is_sucking(L))
			any_sucking = TRUE

		var/list/tags = L.action?.action_tags
		if(!E["sound_slap"] && islist(tags) && ("spanking" in tags))
			E["sound_slap"] = TRUE

	if(any_sucking)
		E["sound_suck"] = TRUE

	var/mob/living/carbon/human/active_mob = best?.actor_active?.get_effect_mob()
	if(istype(active_mob))
		var/ar = _get_arousal_value(active_mob)
		if(isnum(ar) && ar >= ERP_AROUSAL_HEARTS_THRESHOLD)
			E["do_hearts"] = TRUE

	return E

/datum/erp_controller/proc/play_tick_effects(list/active_links, datum/erp_sex_link/best, dt)
	if(!best || !best.is_valid())
		return
	if(hidden_mode)
		return

	var/mob/living/carbon/human/active_mob = best.actor_active?.get_effect_mob()
	if(!istype(active_mob))
		return

	var/list/E = build_tick_effect_bundle(active_links, best, dt)
	if(!islist(E))
		return

	if(E["do_thrust"])
		erp_do_thrust_bump(best)
		erp_do_onomatopoeia(active_mob)
		erp_play_thrust_sound(active_mob, best)

	if(E["do_hearts"])
		erp_spawn_hearts(active_mob)

	if(E["sound_slap"])
		erp_play_slap(active_mob)

	if(E["sound_suck"])
		erp_play_suck(active_mob, best)

/datum/erp_controller/proc/erp_do_thrust_bump(datum/erp_sex_link/best)
	if(!best || QDELETED(best) || !best.is_valid())
		return

	var/mob/living/user = best.actor_active?.get_effect_mob()
	var/atom/movable/target = _get_best_thrust_target(best)
	if(!user || !target)
		return

	var/force = clamp(round(best.force || SEX_FORCE_MID), SEX_FORCE_LOW, SEX_FORCE_EXTREME)
	var/speed = clamp(round(best.speed || SEX_SPEED_MID), SEX_SPEED_LOW, SEX_SPEED_EXTREME)
	var/pixels = 3 + (force - SEX_FORCE_LOW)
	pixels = clamp(pixels, 2, 7)

	var/time = 3.4 - (speed * 0.35)
	time = clamp(time, 1.6, 3.6)
	do_thrust_animate(user, target, pixels, time, null)
	_erp_try_bed_break(best, user, target, time)

/datum/erp_controller/proc/_get_best_thrust_target(datum/erp_sex_link/best)
	if(!best)
		return null

	var/mob/living/A = best.actor_active?.get_effect_mob()
	var/mob/living/B = best.actor_passive?.get_effect_mob()
	if(!A || !B)
		return null

	return B

/datum/erp_controller/proc/erp_do_onomatopoeia(mob/living/carbon/human/user)
	if(!istype(user))
		return
	user.balloon_alert_to_viewers("Plap!", x_offset = rand(-15, 15), y_offset = rand(0, 25))

/datum/erp_controller/proc/erp_play_slap(mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/sound = pick('sound/foley/slap.ogg', 'sound/foley/smackspecial.ogg')
	playsound(user, sound, 50, TRUE, -2, ignore_walls = FALSE)

/datum/erp_controller/proc/_link_is_sucking(datum/erp_sex_link/L)
	if(!L || QDELETED(L) || !L.is_valid())
		return FALSE

	var/datum/erp_sex_organ/init = L.init_organ
	var/datum/erp_sex_organ/tgt  = L.target_organ
	if(!init || !tgt)
		return FALSE

	if(init.erp_organ_type != SEX_ORGAN_MOUTH)
		return FALSE

	return (tgt.erp_organ_type in list(
		SEX_ORGAN_VAGINA,
		SEX_ORGAN_BREASTS,
		SEX_ORGAN_PENIS,
		SEX_ORGAN_ANUS
	))

/datum/erp_controller/proc/erp_play_suck(mob/living/carbon/human/user, datum/erp_sex_link/best)
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

/datum/erp_controller/proc/erp_play_thrust_sound(mob/living/carbon/human/user, datum/erp_sex_link/best)
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

/datum/erp_controller/proc/erp_spawn_hearts(mob/living/carbon/human/user)
	if(!istype(user))
		return

	for(var/i in 1 to rand(1, 3))
		if(!user.cmode)
			new /obj/effect/temp_visual/heart/sex_effects(get_turf(user))
		else
			new /obj/effect/temp_visual/heart/sex_effects/red_heart(get_turf(user))

/datum/erp_controller/proc/_zone_key_to_bodyzone(zone)
	switch(zone)
		if("groin") return BODY_ZONE_PRECISE_GROIN
		if("chest") return BODY_ZONE_CHEST
		if("mouth") return BODY_ZONE_PRECISE_MOUTH
	return null

/datum/erp_controller/proc/_erp_try_bed_break(datum/erp_sex_link/L, mob/living/user, atom/movable/target, time)
	if(!L || QDELETED(L) || !L.is_valid())
		return
	if(!user || !target)
		return

	var/force = clamp(round(L.force || SEX_FORCE_MID), SEX_FORCE_LOW, SEX_FORCE_EXTREME)
	if(force <= SEX_FORCE_MID)
		return

	var/obj/structure/bed/rogue/bed = _erp_find_bed_for_thrust(L, user, target)
	if(!bed || QDELETED(bed))
		return

	var/oldy = bed.pixel_y
	var/target_y = oldy - 1
	var/t = max(1, round(time / 2))
	animate(bed, pixel_y = target_y, time = t)
	animate(pixel_y = oldy, time = t)
	bed.damage_bed(force > SEX_FORCE_HIGH ? 0.5 : 0.25)

/datum/erp_controller/proc/_erp_find_bed_for_thrust(datum/erp_sex_link/L, mob/living/user, atom/movable/target)
	var/mob/living/A = L.actor_active?.physical
	var/mob/living/B = L.actor_passive?.physical

	var/turf/tB = get_turf(B) || get_turf(target)
	var/turf/tA = get_turf(A) || get_turf(user)

	var/obj/structure/bed/rogue/bed = null

	if(tB)
		bed = _erp_find_bed_on_turf(tB)
		if(bed) return bed

	if(tA)
		bed = _erp_find_bed_on_turf(tA)
		if(bed) return bed

	if(tB)
		for(var/turf/T in orange(1, tB))
			bed = _erp_find_bed_on_turf(T)
			if(bed) return bed

	return null


/datum/erp_controller/proc/_erp_find_bed_on_turf(turf/T)
	if(!T)
		return null
	for(var/obj/structure/bed/rogue/B in T)
		return B
	return null

/datum/erp_controller/proc/_is_owner_requester(mob/user)
	return user?.client && owner_client && user.client == owner_client

/datum/erp_controller/proc/_get_ui_user(mob/user = null)
	if(user && _is_owner_requester(user))
		return user

	var/mob/cm = owner?.get_control_mob(owner_client)
	if(cm && cm.client == owner_client)
		return cm

	var/mob/M = owner_client?.mob
	if(M && M.client == owner_client)
		return M

	return null

/datum/erp_controller/proc/_get_owner_effect_mob()
	return owner?.get_effect_mob()

/datum/erp_controller/proc/_get_partner_effect_mob()
	return active_partner?.get_effect_mob()

/datum/erp_controller/proc/_rel_mult_for(mob/living/who, mob/living/partner)
	if(!who || !partner)
		return 1

	var/datum/component/relationships/R = who.GetComponent(/datum/component/relationships)
	if(!R)
		return 1

	var/m = R.get_sex_multiplier(partner)
	if(!isnum(m))
		return 1

	return clamp(m, 0.05, 5)

/datum/erp_controller/proc/_has_nearby_container_for_action()
	var/mob/living/carbon/human/H1 = owner?.get_effect_mob()
	var/mob/living/carbon/human/H2 = active_partner?.get_effect_mob()

	if(!istype(H1) && !istype(H2))
		return FALSE

	var/turf/c1 = H1 ? get_turf(H1) : null
	var/turf/c2 = H2 ? get_turf(H2) : null

	if(istype(H1))
		var/obj/item/reagent_containers/C = _find_nearby_container(H1, c1 || c2)
		if(C && C.reagents)
			return TRUE

	if(istype(H2))
		var/obj/item/reagent_containers/C2 = _find_nearby_container(H2, c2 || c1)
		if(C2 && C2.reagents)
			return TRUE

	return FALSE
