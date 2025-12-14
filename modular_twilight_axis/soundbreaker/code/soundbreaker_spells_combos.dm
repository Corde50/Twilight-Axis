/proc/soundbreaker_combo_echo_beat(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	soundbreaker_apply_damage(user, target, 0.5, BCLASS_PUNCH)
	sb_safe_offbalance(target, 0.5 SECONDS)
	user.visible_message(
		span_danger("[user]'s rhythm echoes into [target], staggering them!"),
		span_notice("Your echo beat staggers [target]."),
	)

/proc/soundbreaker_combo_tempo_flick(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	soundbreaker_apply_damage(user, target, 0.5, BCLASS_PUNCH)
	sb_safe_slow(target, 2)
	user.visible_message(
		span_danger("[user] knocks [target]'s tempo off with a flick of sound!"),
		span_notice("You disrupt [target]'s movement with a sharp change in tempo."),
	)

/proc/soundbreaker_combo_snapback(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	soundbreaker_apply_damage(user, target, 0.75, BCLASS_PUNCH)
	user.visible_message(
		span_danger("[user]'s follow-up snaps back into [target]'s weak point!"),
		span_notice("You snap your follow-up into a soft spot."),
	)

/proc/soundbreaker_combo_bass_drop(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	soundbreaker_apply_damage(user, target, 1.5, BCLASS_PUNCH)
	sb_safe_offbalance(target, 1.2 SECONDS)
	playsound(target, 'sound/magic/repulse.ogg', 90, TRUE)
	user.visible_message(
		span_danger("[user]'s rhythm drops heavy on [target]!"),
		span_notice("You slam [target] with a bass drop."),
	)

/proc/soundbreaker_combo_crossfade(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	sb_small_bleed(target, 3)
	user.visible_message(
		span_danger("[user]'s passing strike leaves [target] bleeding!"),
		span_notice("Your crossfade cuts [target] open as you move through."),
	)

/proc/soundbreaker_combo_reverb_cut(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	sb_safe_slow(target, 3)
	soundbreaker_knockback(user, target, 2)
	user.visible_message(
		span_danger("[user]'s cutting reverb throws [target] back!"),
		span_notice("You send [target] reeling on the rebound."),
	)

/proc/soundbreaker_combo_syncopation(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	target.Immobilize(0.7 SECONDS)
	user.visible_message(
		span_danger("[user]'s off-beat rhythm locks [target] in place!"),
		span_notice("Your syncopated pattern roots [target] for a moment."),
	)

/proc/soundbreaker_combo_ritmo(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	soundbreaker_apply_damage(user, target, 0.75, BCLASS_PUNCH)
	user.visible_message(
		span_danger("[user]'s flurry of strikes peaks in a sharp hit on [target]!"),
		span_notice("Your ritmo peaks in a stronger hit."),
	)

/proc/soundbreaker_combo_crescendo(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	soundbreaker_apply_damage(user, target, 1.5, BCLASS_PUNCH)
	target.Stun(0.5 SECONDS)
	sb_safe_offbalance(target, 1.5 SECONDS)
	user.visible_message(
		span_danger("[user]'s crescendo crashes down on [target] in a brutal finale!"),
		span_notice("Your crescendo finale crushes [target]'s guard."),
	)

/proc/soundbreaker_combo_overture(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	for(var/i in 1 to 2)
		for(var/mob/living/L in view(1, target))
			if(L == user)
				continue
			if(L.stat == DEAD)
				continue
			soundbreaker_apply_damage(user, L, 0.75, BCLASS_PUNCH)
			sb_safe_offbalance(L, 0.4 SECONDS)
		sleep(0.4 SECONDS)

	user.visible_message(
		span_danger("[user]'s overture explodes around [target] in ringing pulses!"),
		span_notice("Your overture ripples outward from [target]."),
	)

/proc/soundbreaker_combo_blade_dancer(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	sb_small_bleed(target, 5)
	soundbreaker_apply_damage(user, target, 0.75, BCLASS_PUNCH)
	user.visible_message(
		span_danger("[user] dances around [target], leaving deep cuts in their wake!"),
		span_notice("Your blade dancer combo carves into [target]."),
	)

/proc/soundbreaker_combo_harmonic_burst(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	for(var/mob/living/L in view(1, target))
		if(L == user)
			continue
		if(L.stat == DEAD)
			continue
		soundbreaker_apply_damage(user, L, 1.25, BCLASS_PUNCH)
		sb_safe_offbalance(L, 1 SECONDS)
		L.Knockdown(0.7 SECONDS)

	playsound(target, 'sound/combat/ground_smash1.ogg', 90, TRUE)

	user.visible_message(
		span_danger("[user]'s harmonic burst crashes out from [target] in a shockwave!"),
		span_notice("Your harmonic burst rattles everyone around [target]."),
	)
