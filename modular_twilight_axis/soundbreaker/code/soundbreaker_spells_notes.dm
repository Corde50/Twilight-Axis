// 1) SOUND STRIKE

/obj/effect/proc_holder/spell/invoked/soundbreaker/sound_strike
	name = "Sound Strike"
	desc = "A focused sound-empowered punch that hits up to two tiles ahead."
	note_id = SOUNDBREAKER_NOTE_STRIKE
	damage_type = BRUTE
	

/obj/effect/proc_holder/spell/invoked/soundbreaker/sound_strike/perform_attack(mob/living/user)
	var/list/hit_targets = list()

	var/turf/T = get_turf(user)
	for(var/i in 1 to 2)
		var/turf/next = get_step(T, user.dir)
		if(!next)
			break
		T = next

		soundbreaker_swing_fx(T)

		var/mob/living/target = soundbreaker_hit_one_on_turf(user, T, damage_mult, damage_type)
		if(target)
			hit_targets |= target

	if(hit_targets.len)
		user.visible_message(
			span_danger("[user] strikes forward in a resonant flurry!"),
			span_notice("You drive your rhythm into the space ahead."),
		)
	else
		user.visible_message(
			span_warning("[user] strikes forward, but hits only empty air."),
			span_warning("You lash out in rhythm, but no one is there."),
		)

	return hit_targets

// 2) RESONANT WAVE

/obj/effect/proc_holder/spell/invoked/soundbreaker/resonant_wave
	name = "Resonant Wave"
	desc = "A short wave of force that hits a small line in front of you and shoves enemies back."
	note_id = SOUNDBREAKER_NOTE_WAVE
	damage_mult = 0.75
	damage_type = BRUTE

/obj/effect/proc_holder/spell/invoked/soundbreaker/resonant_wave/perform_attack(mob/living/user)
	var/list/hit_targets = list()

	var/list/turfs = soundbreaker_get_arc_turfs(user, 1)

	for(var/turf/T in turfs)
		if(!T)
			continue

		soundbreaker_swing_fx(T)

		var/mob/living/target = soundbreaker_hit_one_on_turf(user, T, damage_mult, damage_type)
		if(target)
			soundbreaker_knockback(user, target, 1)
			hit_targets |= target

	if(hit_targets.len)
		user.visible_message(
			span_danger("[user] unleashes a resonant wave of force!"),
			span_notice("You send a rolling wave of sound before you."),
		)
	else
		user.visible_message(
			span_warning("[user] unleashes a resonant wave, but no one is caught in it."),
			span_warning("Your wave rolls forward, but hits nobody."),
		)

	return hit_targets

// 3) DULCE STEP

/obj/effect/proc_holder/spell/invoked/soundbreaker/dulce_step
	name = "Dulce Step"
	desc = "A quick step through the rhythm: rush forward and slip behind your target while striking."
	note_id = SOUNDBREAKER_NOTE_DULCE
	damage_mult = 1.25
	damage_type = BRUTE

/obj/effect/proc_holder/spell/invoked/soundbreaker/dulce_step/perform_attack(mob/living/user)
	var/list/hit_targets = list()
	if(!user)
		return hit_targets

	var/turf/start = get_turf(user)
	if(!start)
		return hit_targets

	var/turf/mid = get_step(start, user.dir)

	soundbreaker_swing_fx(start)

	if(mid)
		soundbreaker_swing_fx(mid)

	var/mob/living/target = null
	if(mid)
		target = soundbreaker_hit_one_on_turf(user, mid, damage_mult, damage_type)

	if(target)
		soundbreaker_step_behind(user, target)
		user.face_atom(target)

		hit_targets |= target
		user.visible_message(
			span_danger("[user] dances through [target], striking in passing!"),
			span_notice("You step through [target]'s guard and hit in motion."),
		)
	else
		soundbreaker_step_forward(user, 2)
		user.visible_message(
			span_warning("[user] makes a sharp rhythmic step, but finds no opening."),
			span_warning("You step into the rhythm, but no one is there."),
		)

	return hit_targets

// 4) OVERLOAD CHORD

/obj/effect/proc_holder/spell/invoked/soundbreaker/overload_chord
	name = "Overload"
	desc = "A burst of overloaded sound in a cone, shaking balance and focus."
	note_id = SOUNDBREAKER_NOTE_OVERLOAD
	damage_mult = 0.5
	damage_type = BRUTE

/obj/effect/proc_holder/spell/invoked/soundbreaker/overload_chord/perform_attack(mob/living/user)
	var/list/hit_targets = list()
	if(!user)
		return hit_targets

	var/turf/origin = get_turf(user)
	if(!origin)
		return hit_targets

	var/list/turfs = list()

	var/turf/front = get_step(origin, user.dir)
	if(front)
		turfs += front

	var/turf/side_left = get_step(origin, turn(user.dir, 90))
	var/turf/side_right = get_step(origin, turn(user.dir, -90))

	if(side_left)
		turfs += side_left
	if(side_right)
		turfs += side_right

	for(var/turf/T in turfs)
		if(!T)
			continue

		soundbreaker_swing_fx(T)

		var/mob/living/target = soundbreaker_hit_one_on_turf(user, T, damage_mult, damage_type)
		if(target)
			soundbreaker_apply_offbalance(user, target)
			hit_targets |= target

	if(hit_targets.len)
		user.visible_message(
			span_danger("[user] unleashes an overloading chord of sound around them!"),
			span_notice("You overload the air in a crushing half-circle."),
		)
	else
		user.visible_message(
			span_warning("[user] blasts the air with overload, but no one is caught in it."),
			span_warning("Your overload booms, but nobody is inside it."),
		)

	return hit_targets

// 5) ENCORE LINE

/obj/effect/proc_holder/spell/invoked/soundbreaker/encore_line
	name = "Encore"
	desc = "A lingering line of sound, most punishing at close range."
	note_id = SOUNDBREAKER_NOTE_ENCORE
	damage_mult = 0.75
	damage_type = BRUTE
	var/front_bonus = 0.5

/obj/effect/proc_holder/spell/invoked/soundbreaker/encore_line/cast(list/targets, mob/living/user)
	if(!isliving(user))
		return
	if(user.incapacitated())
		return

	if(!soundbreaker_has_music(user))
		to_chat(user, span_warning("Your fists fall silent without a song. You must be playing music to weave sound into strikes."))
		return

	var/turf/front1 = soundbreaker_get_front_turf(user, 1)
	var/list/wave2 = soundbreaker_get_arc_turfs(user, 2)

	if(front1)
		soundbreaker_exclaim_fx(front1)

	addtimer(CALLBACK(src, PROC_REF(encore_phase2), user, front1, wave2), 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(encore_phase3), user, wave2), 1 SECONDS)

	user.visible_message(
		span_danger("[user] begins a cutting encore!"),
		span_notice("You weave a lingering line of sound."),
	)

/obj/effect/proc_holder/spell/invoked/soundbreaker/encore_line/proc/encore_phase2(mob/living/user, turf/front1, list/wave2)
	if(user && front1)
		soundbreaker_swing_fx(front1)
		var/dmg_bonus = damage_mult + front_bonus
		soundbreaker_hit_one_on_turf(user, front1, dmg_bonus, damage_type)

	if(user && islist(wave2))
		for(var/turf/T in wave2)
			if(T)
				soundbreaker_exclaim_fx(T)

/obj/effect/proc_holder/spell/invoked/soundbreaker/encore_line/proc/encore_phase3(mob/living/user, list/wave2)
	if(!user || !islist(wave2))
		return

	for(var/turf/T in wave2)
		if(!T)
			continue
		soundbreaker_swing_fx(T)
		soundbreaker_hit_one_on_turf(user, T, damage_mult, damage_type)

// 6) SOLO BREAK

/obj/effect/proc_holder/spell/invoked/soundbreaker/solo_break
	name = "Solo Break"
	desc = "Lock a target in your solo and hammer the space in front of them with repeated strikes."
	note_id = SOUNDBREAKER_NOTE_SOLO
	damage_mult = 0.75
	damage_type = BRUTE

/obj/effect/proc_holder/spell/invoked/soundbreaker/solo_break/cast(list/targets, mob/living/user)
	if(!isliving(user))
		return
	if(user.incapacitated())
		return

	if(!soundbreaker_has_music(user))
		to_chat(user, span_warning("Your fists fall silent without a song. You must be playing music to weave sound into strikes."))
		return

	var/turf/front = soundbreaker_get_front_turf(user, 1)

	if(!front)
		user.visible_message(
			span_warning("[user] bursts into a brutal solo, but has nowhere to focus it."),
			span_warning("You unleash a brutal solo, but there's nothing in front of you."),
		)
		return

	soundbreaker_exclaim_fx(front)

	user.Immobilize(1.6 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(solo_hit_phase), user, front, 1), 0 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(solo_hit_phase), user, front, 2), 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(solo_hit_phase), user, front, 3), 1 SECONDS)

	user.visible_message(
		span_danger("[user] launches into a brutal solo!"),
		span_notice("You hammer your rhythm into the space before you."),
	)

/obj/effect/proc_holder/spell/invoked/soundbreaker/solo_break/proc/solo_hit_phase(mob/living/user, turf/front, phase)
	if(!user || !front)
		return

	soundbreaker_swing_fx(front)

	var/mob/living/target = soundbreaker_hit_one_on_turf(user, front, damage_mult, damage_type)

	if(target && phase == 1)
		soundbreaker_apply_short_stun(user, target)
