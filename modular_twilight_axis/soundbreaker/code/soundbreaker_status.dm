#define SOUNDBREAKER_COMBO_FILTER "soundbreaker_combo_glow"

/atom/movable/screen/alert/status_effect/buff/soundbreaker_combo
	name = "Rhythmic Combo"
	desc = "My blows follow the rhythm. Consecutive hits build up to 5 stacks, sharpening your strikes."
	icon_state = "buff"

/datum/status_effect/buff/soundbreaker_combo
	id = "soundbreaker_combo"
	status_type = STATUS_EFFECT_REFRESH
	duration = 3 SECONDS
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/buff/soundbreaker_combo

	var/stacks = 0
	var/max_stacks = 5
	var/mutable_appearance/aura_overlay

/datum/status_effect/buff/soundbreaker_combo/on_apply()
	. = ..()
	if(stacks <= 0)
		stacks = 1
	update_visuals()
	if(owner)
		to_chat(owner, span_notice("Your rhythm begins to build."))
	return TRUE

/datum/status_effect/buff/soundbreaker_combo/refresh()
	. = ..()
	if(QDELETED(src))
		return

	stacks = min(stacks + 1, max_stacks)
	update_visuals()
	if(owner)
		to_chat(owner, span_notice("Your rhythm surges ([stacks]/[max_stacks])."))

/datum/status_effect/buff/soundbreaker_combo/on_remove()
	clear_visuals()
	if(owner)
		if(aura_overlay)
			owner.cut_overlay(aura_overlay)
		aura_overlay = null

		soundbreaker_clear_note_icons(owner)

		if(owner.soundbreaker_combo)
			var/datum/soundbreaker_combo_tracker/T = owner.soundbreaker_combo
			if(T && islist(T.history))
				T.history.Cut()

	. = ..()

/datum/status_effect/buff/soundbreaker_combo/proc/update_visuals()
	if(!owner)
		return

	clear_visuals()

	var/colour
	switch(stacks)
		if(1) colour = "#44aaff"
		if(2) colour = "#55dd77"
		if(3) colour = "#ffdd66"
		if(4) colour = "#ff8844"
		if(5) colour = "#ff4444"
		else colour = "#888888"

	owner.add_filter(SOUNDBREAKER_COMBO_FILTER, 2, list(
		"type" = "outline",
		"color" = colour,
		"alpha" = 80,
		"size" = 1,
	))

/datum/status_effect/buff/soundbreaker_combo/proc/clear_visuals()
	if(owner)
		owner.remove_filter(SOUNDBREAKER_COMBO_FILTER)

#undef SOUNDBREAKER_COMBO_FILTER

/datum/status_effect/buff/soundbreaker_prepared
	id = "soundbreaker_prepared"
	status_type = STATUS_EFFECT_REPLACE
	duration = SB_PREP_WINDOW

	var/note_id = 0
	var/damage_mult = 1
	var/damage_type = BRUTE

/datum/status_effect/buff/soundbreaker_prepared/on_apply(note_to_prime, mult_to_prime, type_to_prime)
	. = ..()
	note_id = note_to_prime
	damage_mult = mult_to_prime
	damage_type = type_to_prime
	return TRUE

/datum/status_effect/buff/soundbreaker_prepared/refresh(note_to_prime, mult_to_prime, type_to_prime)
	. = ..()
	if(QDELETED(src))
		return
	note_id = note_to_prime
	damage_mult = mult_to_prime
	damage_type = type_to_prime

/datum/status_effect/buff/soundbreaker_prepared/proc/set_payload(new_note_id, new_damage_mult, new_damage_type)
	note_id = new_note_id
	damage_mult = new_damage_mult
	damage_type = new_damage_type

/datum/status_effect/buff/soundbreaker_riff
	id = "soundbreaker_riff"
	status_type = STATUS_EFFECT_REFRESH
	duration = 1 SECONDS
	var/bonus = 20

/datum/status_effect/buff/soundbreaker_riff/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_GUIDANCE, "soundbreaker_riff")
	return TRUE

/datum/status_effect/buff/soundbreaker_riff/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GUIDANCE, "soundbreaker_riff")
	. = ..()
