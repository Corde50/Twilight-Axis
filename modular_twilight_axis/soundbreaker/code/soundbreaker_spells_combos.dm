// 111 — 150% dmg + slow 2 (коротко, чтобы до следующего удара)
/proc/soundbreaker_combo_echo_beat(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	soundbreaker_apply_damage(user, target, 1.5, BCLASS_PUNCH)
	sb_safe_slow(target, 2)

	user.visible_message(
		span_danger("[user]'s rhythm tightens into a punishing triplet!"),
		span_notice("You land a clean triple, briefly slowing [target]."),
	)

	soundbreaker_show_combo_icon(target, SB_COMBO_ICON_ECHO)
	soundbreaker_reset_rhythm(user)

// 62 — плевок/нотный выстрел: 50% dmg + slow, без pull/immob
/proc/soundbreaker_combo_tempo_flick(mob/living/user, mob/living/target)
	if(!user)
		return

	sb_fire_sound_note(user, 0.5, BRUTE, BODY_ZONE_CHEST)

	soundbreaker_reset_rhythm(user)

// 515 — 30% dmg + immob 2s
/proc/soundbreaker_combo_snapback(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	soundbreaker_apply_damage(user, target, 0.3, BCLASS_PUNCH)
	target.Immobilize(2 SECONDS)

	user.visible_message(
		span_danger("[user]'s quick pattern pins [target] in place!"),
		span_notice("You catch [target] on-beat and root them briefly."),
	)

	soundbreaker_show_combo_icon(target, SB_COMBO_ICON_SNAPBACK)
	soundbreaker_reset_rhythm(user)

// 4112 — двустадийка: 130% в ближней точке, 180% во второй + immob 2s при попадании
/proc/soundbreaker_combo_bass_drop(mob/living/user, mob/living/target)
	if(!user)
		return

	var/zone = sb_try_get_zone(user, user.zone_selected)

	var/turf/front1 = soundbreaker_get_front_turf(user, 1)
	var/list/wave2 = soundbreaker_get_arc_turfs(user, 2)
	if(islist(wave2))
		wave2 = wave2.Copy()

	var/mob/living/any_hit = null

	// stage 1 (front1) 130%
	if(front1)
		soundbreaker_exclaim_fx(front1)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sb_combo_4112_stage1),
			user, target, front1, zone, 1.3, any_hit), 0 SECONDS)

	// stage 2 (arc@2) 180%
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sb_combo_4112_stage2),
		user, target, wave2, zone, 1.8, any_hit), 0.35 SECONDS)

	user.visible_message(
		span_danger("[user]'s bass pattern detonates in two beats!"),
		span_notice("You slam a two-beat drop: close, then wide."),
	)

	// иконку/сброс делаем чуть позже, чтобы точно после стадий
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sb_combo_4112_finish),
		user, target), 0.6 SECONDS)

/proc/sb_combo_4112_stage1(mob/living/user, mob/living/primary, turf/front1, zone, dmg, any_hit_ref)
	if(!user || !front1)
		return

	soundbreaker_swing_fx(front1)

	var/mob/living/hit = null
	if(primary && get_turf(primary) == front1)
		if(soundbreaker_hit_specific(user, primary, dmg, BRUTE, BCLASS_PUNCH, zone))
			hit = primary
	else
		hit = soundbreaker_hit_one_on_turf(user, front1, dmg, BRUTE, BCLASS_PUNCH, zone)

	if(hit)
		hit.Immobilize(2 SECONDS)

/proc/sb_combo_4112_stage2(mob/living/user, mob/living/primary, list/wave2, zone, dmg, any_hit_ref)
	if(!user || !islist(wave2))
		return

	for(var/turf/T in wave2)
		if(!T)
			continue
		soundbreaker_swing_fx(T)

		var/mob/living/hit = null
		if(primary && get_turf(primary) == T)
			if(soundbreaker_hit_specific(user, primary, dmg, BRUTE, BCLASS_PUNCH, zone))
				hit = primary
		else
			hit = soundbreaker_hit_one_on_turf(user, T, dmg, BRUTE, BCLASS_PUNCH, zone)

		if(hit)
			hit.Immobilize(2 SECONDS)

/proc/sb_combo_4112_finish(mob/living/user, mob/living/target)
	if(!user || !target)
		return
	soundbreaker_show_combo_icon(target, SB_COMBO_ICON_BASS)
	soundbreaker_reset_rhythm(user)

// 51146 — 30% dmg + stun 2s
/proc/soundbreaker_combo_crossfade(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	soundbreaker_apply_damage(user, target, 0.3, BCLASS_PUNCH)
	target.Stun(2 SECONDS)

	user.visible_message(
		span_danger("[user] catches [target] in a nasty cross-beat stun!"),
		span_notice("You interrupt [target] hard with a short stun."),
	)

	soundbreaker_show_combo_icon(target, SB_COMBO_ICON_CROSSFADE)
	soundbreaker_reset_rhythm(user)

// 1423 — “стена волны” (как старая wave), отталкивает
/proc/soundbreaker_combo_reverb_cut(mob/living/user, mob/living/target)
	if(!user)
		return

	var/list/turfs = soundbreaker_get_arc_turfs(user, 1)
	var/zone = sb_try_get_zone(user, user.zone_selected)

	var/mob/living/any = null
	for(var/turf/T in turfs)
		if(!T)
			continue

		soundbreaker_swing_fx(T)

		var/mob/living/hit = soundbreaker_hit_one_on_turf(user, T, 0.75, BRUTE, BCLASS_PUNCH, zone)
		if(hit)
			any = hit
			soundbreaker_knockback(user, hit, 1)

	if(any)
		user.visible_message(
			span_danger("[user] drives a wall of sound forward!"),
			span_notice("You shove foes back with a resonant wall."),
		)
		soundbreaker_show_combo_icon(any, SB_COMBO_ICON_REVERB)
	else
		playsound(user, 'sound/combat/sp_whip_whiff.ogg', 40, TRUE)

	soundbreaker_reset_rhythm(user)

// 1216 — immob 1.5s + offbalance 3s; если цель уже была “под контролем” -> падение
/proc/soundbreaker_combo_syncopation(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	var/was_off = sb_is_offbalanced(target)

	soundbreaker_apply_damage(user, target, 0.5, BCLASS_PUNCH)
	target.Immobilize(1.5 SECONDS)
	sb_safe_offbalance(target, 3 SECONDS)

	if(was_off)
		target.Knockdown(1.5 SECONDS)

	user.visible_message(
		span_danger("[user]'s pattern locks [target]—and if they were already shaken, it drops them!"),
		span_notice("You bind [target] in rhythm; if they were already off, they fall."),
	)

	soundbreaker_show_combo_icon(target, SB_COMBO_ICON_SYNC)
	soundbreaker_reset_rhythm(user)

// 213 — 70% aoe вокруг + блиды
/proc/soundbreaker_combo_harmonic_burst(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	for(var/mob/living/L in view(1, user))
		if(L == user)
			continue
		if(L.stat == DEAD)
			continue
		soundbreaker_apply_damage(user, L, 0.7, BCLASS_PUNCH)
		sb_small_bleed(L, 3)

	playsound(get_turf(user), 'sound/combat/ground_smash1.ogg', 90, TRUE)

	user.visible_message(
		span_danger("[user]'s harmonic pulse tears at everyone nearby!"),
		span_notice("You burst outward with a bleeding harmonic pulse."),
	)

	soundbreaker_show_combo_icon(target, SB_COMBO_ICON_HARMONIC)
	soundbreaker_reset_rhythm(user)

// 364 — 60% dmg + slow 5s
/proc/soundbreaker_combo_ritmo(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	soundbreaker_apply_damage(user, target, 0.6, BCLASS_PUNCH)
	sb_safe_slow(target, 5)

	user.visible_message(
		span_danger("[user] drags [target]'s tempo down into a heavy slow!"),
		span_notice("You slow [target] hard with a dragging rhythm."),
	)

	soundbreaker_show_combo_icon(target, SB_COMBO_ICON_RITMO)
	soundbreaker_reset_rhythm(user)

// 12155 — 90% dmg + bleed 5
/proc/soundbreaker_combo_blade_dancer(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	soundbreaker_apply_damage(user, target, 0.9, BCLASS_PUNCH)
	sb_small_bleed(target, 5)

	user.visible_message(
		span_danger("[user] carves [target] in a shredding sequence!"),
		span_notice("You leave [target] bleeding from the shred."),
	)

	soundbreaker_show_combo_icon(target, SB_COMBO_ICON_BLADE)
	soundbreaker_reset_rhythm(user)

// 13211 — 170% dmg + offbalance 5s (апперкот по смыслу)
/proc/soundbreaker_combo_crescendo(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	soundbreaker_apply_damage(user, target, 1.7, BCLASS_PUNCH)
	sb_safe_offbalance(target, 5 SECONDS)

	user.visible_message(
		span_danger("[user] uppercuts [target] with a crushing crescendo!"),
		span_notice("You launch [target] off-balance with a heavy uppercut beat."),
	)

	soundbreaker_show_combo_icon(target, SB_COMBO_ICON_CRESCENDO)
	soundbreaker_reset_rhythm(user)

// 63114 — если цель уже offbalance -> knockdown 1s (+10% урона), иначе 200% урона
/proc/soundbreaker_combo_overture(mob/living/user, mob/living/target)
	if(!user || !target)
		return

	if(sb_is_offbalanced(target))
		soundbreaker_apply_damage(user, target, 1.1, BCLASS_PUNCH)
		target.Knockdown(1 SECONDS)
	else
		soundbreaker_apply_damage(user, target, 2.0, BCLASS_PUNCH)

	user.visible_message(
		span_danger("[user] ends the phrase with a brutal finisher!"),
		span_notice("You finish hard—either dropping them if they're shaken, or crushing them outright."),
	)

	soundbreaker_show_combo_icon(target, SB_COMBO_ICON_OVERTURE)
	soundbreaker_reset_rhythm(user)
