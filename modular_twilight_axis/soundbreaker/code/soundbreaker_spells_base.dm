/obj/effect/proc_holder/spell/self/soundbreaker
	name = "Soundbreaker Ability"
	desc = "Base soundbreaking ability."
	clothes_req = FALSE
	charge_type = "recharge"
	associated_skill = /datum/skill/misc/music
	cost = 0
	xp_gain = FALSE

	releasedrain = 0
	chargedrain = 0
	chargetime = 0
	recharge_time = SB_BASE_COOLDOWN

	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	spell_tier = 1

	invocations = list()
	invocation_type = "none"
	hide_charge_effect = TRUE
	charging_slowdown = 0
	chargedloop = null
	overlay_state = null

	var/note_id = 0
	var/damage_mult = 1
	var/damage_type = BRUTE
	action_icon = 'modular_twilight_axis/soundbreaker/icons/soundspells.dmi'

/obj/effect/proc_holder/spell/self/soundbreaker/cast(list/targets, mob/living/user)
	// ВАЖНО: возвращаем механику кулдауна (раньше её съедало отсутствие ..())
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/L = user

	if(L.incapacitated())
		return

	// мгновенно заготавливаем удар на 5 секунд
	if(!soundbreaker_prime_note(L, note_id, damage_mult, damage_type, name))
		return

/obj/effect/proc_holder/spell/self/soundbreaker/proc/perform_attack(mob/living/user)
	return list()

/obj/effect/proc_holder/spell/self/soundbreaker/proc/on_successful_hit(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	soundbreaker_on_hit(user, target, note_id)

/obj/effect/proc_holder/spell/self/soundbreaker/proc/on_whiff(mob/living/user)
	if(!user)
		return
	playsound(user, 'sound/combat/sp_whip_whiff.ogg', 40, TRUE)

/obj/effect/proc_holder/spell/self/soundbreaker/proc/soundbreaker_swing_fx(turf/T)
	if(!T)
		return
	var/obj/effect/temp_visual/special_intent/fx = new(T, 0.4 SECONDS)
	fx.icon = 'icons/effects/effects.dmi'
	fx.icon_state = "sweep_fx"

/obj/effect/proc_holder/spell/self/soundbreaker/proc/soundbreaker_exclaim_fx(turf/T)
	if(!T)
		return
	var/obj/effect/temp_visual/special_intent/fx = new(T, 0.5 SECONDS)
	fx.icon = 'icons/effects/effects.dmi'
	fx.icon_state = "blip"

/obj/effect/proc_holder/spell/self/soundbreaker/proc/soundbreaker_get_front_turf(mob/living/user, distance = 1)
	if(!user)
		return null
	var/turf/T = get_turf(user)
	for(var/i in 1 to distance)
		var/turf/next = get_step(T, user.dir)
		if(!next)
			break
		T = next
	return T

/obj/effect/proc_holder/spell/self/soundbreaker/proc/soundbreaker_get_arc_turfs(mob/living/user, distance = 1)
	var/list/res = list()
	if(!user)
		return res

	var/turf/center = soundbreaker_get_front_turf(user, distance)
	if(!center)
		return res

	var/dir_left = turn(user.dir, 90)
	var/dir_right = turn(user.dir, -90)

	res += center

	var/turf/up = get_step(center, dir_left)
	if(up)
		res += up

	var/turf/down = get_step(center, dir_right)
	if(down)
		res += down

	return res

/obj/effect/proc_holder/spell/self/soundbreaker/proc/soundbreaker_step_behind(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	var/dir_to_target = get_dir(user, target)
	var/turf/behind = get_step(target_turf, dir_to_target)

	if(behind && !behind.density)
		user.forceMove(behind)

/obj/effect/proc_holder/spell/self/soundbreaker/proc/soundbreaker_step_forward(mob/living/user, tiles)
	if(!user)
		return
	var/turf/T = get_turf(user)
	for(var/i in 1 to tiles)
		var/turf/N = get_step(T, user.dir)
		if(!N || N.density)
			break
		T = N
	user.forceMove(T)

/obj/effect/proc_holder/spell/self/soundbreaker/proc/soundbreaker_apply_offbalance(mob/living/user, mob/living/target)
	if(!target)
		return
	sb_safe_offbalance(target, 1 SECONDS)

/obj/effect/proc_holder/spell/self/soundbreaker/proc/soundbreaker_apply_short_stun(mob/living/user, mob/living/target)
	if(!target)
		return
	target.Stun(0.4 SECONDS)
