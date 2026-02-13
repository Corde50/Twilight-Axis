#define LINK_STATE_ACTIVE     1
#define LINK_STATE_FINISHED   2

/datum/erp_sex_link
	var/datum/erp_actor/actor_active
	var/datum/erp_actor/actor_passive
	var/datum/erp_sex_organ/init_organ
	var/datum/erp_sex_organ/target_organ
	var/datum/erp_action/action

	var/force = SEX_FORCE_MID
	var/speed = SEX_SPEED_MID

	var/state = LINK_STATE_ACTIVE
	var/last_tick = 0
	var/tick_interval = 3 SECONDS
	var/pose_state = SEX_POSE_BOTH_STANDING
	var/datum/erp_controller/session

	var/finish_mode = "until_climax"
	var/finish_time = 0
	var/climax_target = "none"

/datum/erp_sex_link/New(datum/erp_actor/A, datum/erp_actor/B, datum/erp_action/Act, list/organs, datum/erp_controller/S)
	actor_active  = A
	actor_passive = B
	action = Act
	session = S

	init_organ   = organs?["init"]
	target_organ = organs?["target"]

	tick_interval = action?.tick_time || tick_interval
	if(init_organ)
		init_organ.links += src
	if(target_organ)
		target_organ.links += src

	last_tick = world.time
	. = ..()

/datum/erp_sex_link/process()
	return

/datum/erp_sex_link/proc/apply_effects()
	if(!action)
		return

	var/list/result = action.calc_effect(src)
	if(!result)
		return

	var/arousal = result["arousal"]
	var/pain    = result["pain"]

	if(actor_active)
		actor_active.apply_erp_effect(arousal, pain, TRUE)

	if(actor_passive)
		actor_passive.apply_erp_effect(arousal, pain, FALSE)

/datum/erp_sex_link/proc/finish()
	if(state == LINK_STATE_FINISHED)
		return

	state = LINK_STATE_FINISHED

	if(init_organ)
		init_organ.links -= src
	if(target_organ)
		target_organ.links -= src

/datum/erp_sex_link/proc/request_inject(datum/erp_sex_organ/source, target_mode, datum/erp_actor/who = null)
	if(!source || state != LINK_STATE_ACTIVE)
		return
	if(!session)
		return

	session.handle_inject(link = src, source = source, target_mode = target_mode, who = who)

/datum/erp_sex_link/proc/is_giving(datum/erp_actor/A)
	return actor_active == A

/datum/erp_sex_link/proc/get_force_text()
	switch(force)
		if(SEX_FORCE_LOW)     return "нежно"
		if(SEX_FORCE_MID)     return "уверенно"
		if(SEX_FORCE_HIGH)    return "грубо"
		if(SEX_FORCE_EXTREME) return "неистово"
	return "уверенно"

/datum/erp_sex_link/proc/get_speed_text()
	switch(speed)
		if(SEX_SPEED_LOW)     return "медленно"
		if(SEX_SPEED_MID)     return "ритмично"
		if(SEX_SPEED_HIGH)    return "быстро"
		if(SEX_SPEED_EXTREME) return "яростно"
	return "ритмично"

/datum/erp_sex_link/proc/get_pose_text()
	switch(pose_state)
		if(SEX_POSE_BOTH_STANDING)	return "стоя"
		if(SEX_POSE_USER_LYING)		return "снизу"
		if(SEX_POSE_TARGET_LYING)	return "нависая"
		if(SEX_POSE_BOTH_LYING)		return "лежа"
	return "стоя"

/datum/erp_sex_link/proc/is_aggressive()
	return force >= SEX_FORCE_HIGH

/datum/erp_sex_link/proc/has_big_breasts()
	return actor_passive?.has_big_breasts() || FALSE

/datum/erp_sex_link/proc/is_dullahan_scene()
	return actor_passive?.is_dullahan_scene() || FALSE

/datum/erp_sex_link/proc/get_target_zone_text()
	return actor_active?.get_target_zone_text_for(actor_passive) || "тело"

/datum/erp_sex_link/proc/get_target_zone(mob/living/user, mob/living/target)
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

	var/zone = user?.zone_selected
	var/ru_zone = zone_translations[zone]

	if(!ru_zone)
		return "тело"

	if(target && ishuman(target))
		var/mob/living/carbon/human/H = target

		if(zone in list(
			BODY_ZONE_R_LEG,
			BODY_ZONE_L_LEG,
			BODY_ZONE_PRECISE_R_FOOT,
			BODY_ZONE_PRECISE_L_FOOT
		))
			if(!(H.get_bodypart(BODY_ZONE_R_LEG) || H.get_bodypart(BODY_ZONE_L_LEG)))
				return "туловище"

		if(zone in list(
			BODY_ZONE_R_ARM,
			BODY_ZONE_L_ARM,
			BODY_ZONE_PRECISE_R_INHAND,
			BODY_ZONE_PRECISE_L_INHAND
		))
			if(!(H.get_bodypart(BODY_ZONE_R_ARM) || H.get_bodypart(BODY_ZONE_L_ARM)))
				return "туловище"

		if(zone in list(
			BODY_ZONE_HEAD,
			BODY_ZONE_PRECISE_SKULL,
			BODY_ZONE_PRECISE_EARS,
			BODY_ZONE_PRECISE_R_EYE,
			BODY_ZONE_PRECISE_L_EYE,
			BODY_ZONE_PRECISE_NOSE,
			BODY_ZONE_PRECISE_MOUTH,
			BODY_ZONE_PRECISE_NECK
		))
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return "туловище"

	return ru_zone

/datum/erp_sex_link/proc/is_valid()
	if(!actor_active || !actor_passive) 
		return FALSE

	if(QDELETED(actor_active) || QDELETED(actor_passive)) 
		return FALSE

	if(!actor_active.physical || !actor_passive.physical) 
		return FALSE

	if(!init_organ || !target_organ) 
		return FALSE

	if(QDELETED(init_organ) || QDELETED(target_organ)) 
		return FALSE

	if(!init_organ.host || !target_organ.host) 
		return FALSE

	return TRUE

/datum/erp_sex_link/proc/get_ui_state()
	return list(
		"active" = state == LINK_STATE_ACTIVE,
		"force" = force,
		"speed" = speed,
		"pose" = pose_state,
		"action" = action?.name,
		"actor_active" = actor_active?.get_display_name(),
		"actor_passive" = actor_passive?.get_display_name()
	)

/datum/erp_sex_link/proc/get_speed_mult()
	switch(speed)
		if(SEX_SPEED_LOW)     return 0.60
		if(SEX_SPEED_MID)     return 1.00
		if(SEX_SPEED_HIGH)    return 1.40
		if(SEX_SPEED_EXTREME) return 1.90
	return 1.00

/datum/erp_sex_link/proc/get_force_mult()
	switch(force)
		if(SEX_FORCE_LOW)     return 0.5
		if(SEX_FORCE_MID)     return 1.00
		if(SEX_FORCE_HIGH)    return 1.5
		if(SEX_FORCE_EXTREME) return 2.0
	return 1.00

/datum/erp_sex_link/proc/get_effective_interval()
	var/base = action?.tick_time || tick_interval
	var/m = get_speed_mult()
	return base / m

/datum/erp_sex_link/proc/get_message_weight()
	return get_speed_mult() + get_force_mult()

/datum/erp_action/proc/build_start(datum/erp_sex_link/L)
	return build_message(message_start, L)

/datum/erp_action/proc/build_tick(datum/erp_sex_link/L)
	return build_message(message_tick, L)

/datum/erp_action/proc/build_finish(datum/erp_sex_link/L)
	return build_message(message_finish, L)

/datum/erp_action/proc/build_climax(datum/erp_sex_link/L, datum/erp_actor/who)
	return build_message(who == L.actor_active ? message_climax_active : message_climax_passive, L)

/datum/erp_sex_link/proc/get_climax_score(datum/erp_actor/who)
	if(!who || QDELETED(who))
		return 0
	var/s = who.get_climax_score_for_link(src)

	if(actor_active == who)
		s += 15

	return s

/datum/erp_sex_link/proc/handle_climax(datum/erp_actor/who)
	if(!who || QDELETED(who))
		return null
	return who.build_climax_result(src)

/datum/erp_sex_link/proc/get_message_color()
	var/low_r = 234
	var/low_g = 200
	var/low_b = 222

	var/ext_r = 209
	var/ext_g = 70
	var/ext_b = 245

	var/fn = _norm_1_4(force)
	var/sn = _norm_1_4(speed)

	var/t = clamp((fn + sn) * 0.5, 0, 1)

	var/boost = 1.15
	t *= boost

	var/r = round(low_r + (ext_r - low_r) * t)
	var/g = round(low_g + (ext_g - low_g) * t)
	var/b = round(low_b + (ext_b - low_b) * t)

	r = clamp(r, 0, 255)
	g = clamp(g, 0, 255)
	b = clamp(b, 0, 255)

	return rgb(r, g, b)

/datum/erp_sex_link/proc/_norm_1_4(v)
	return clamp(((v || 1) - 1) / 3, 0, 1)

/datum/erp_sex_link/proc/spanify_sex(text)
	if(!text)
		return null
	var/c = get_message_color()
	return "<span style='color:[c]; font-weight:500; font-size:75%; text-shadow: 0 1px 0 rgba(0,0,0,0.35);'>[text]</span>"

