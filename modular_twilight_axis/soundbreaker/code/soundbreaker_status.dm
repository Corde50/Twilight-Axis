#define SOUNDBREAKER_COMBO_FILTER "soundbreaker_combo_glow"

/atom/movable/screen/alert/status_effect/buff/soundbreaker_combo
	name = "Rhythmic Combo"
	desc = "My blows follow the rhythm. Consecutive hits build up to 5 stacks, sharpening your strikes."
	icon_state = "buff"

/datum/status_effect/buff/soundbreaker_combo
	id = "soundbreaker_combo"
	status_type = STATUS_EFFECT_REFRESH
	duration = SB_PREP_WINDOW
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

		SEND_SIGNAL(owner, COMSIG_SOUNDBREAKER_COMBO_CLEARED)

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

	owner.regenerate_icons()

/datum/status_effect/buff/soundbreaker_combo/proc/clear_visuals()
	if(owner)
		owner.remove_filter(SOUNDBREAKER_COMBO_FILTER)
		owner.regenerate_icons()

#undef SOUNDBREAKER_COMBO_FILTER

/datum/status_effect/buff/soundbreaker_prepared
	id = "soundbreaker_prepared"
	status_type = STATUS_EFFECT_REPLACE
	duration = SB_COMBO_WINDOW
	alert_type = /atom/movable/screen/alert/status_effect/buff/soundbreaker_prepared

	var/note_id = 0
	var/damage_mult = 1
	var/damage_type = BRUTE
	var/note_name = "Prepared Note"

/datum/status_effect/buff/soundbreaker_prepared/on_apply(note_to_prime, mult_to_prime, type_to_prime, note_name_to_prime)
	. = ..()
	note_id = note_to_prime
	damage_mult = mult_to_prime
	damage_type = type_to_prime
	if(note_name_to_prime)
		note_name = note_name_to_prime
	update_alert()
	return TRUE

/datum/status_effect/buff/soundbreaker_prepared/refresh(note_to_prime, mult_to_prime, type_to_prime, note_name_to_prime)
	. = ..()
	if(QDELETED(src))
		return
	note_id = note_to_prime
	damage_mult = mult_to_prime
	damage_type = type_to_prime
	if(note_name_to_prime)
		note_name = note_name_to_prime
	update_alert()

/datum/status_effect/buff/soundbreaker_prepared/proc/set_payload(new_note_id, new_damage_mult, new_damage_type, new_note_name)
	note_id = new_note_id
	damage_mult = new_damage_mult
	damage_type = new_damage_type
	if(new_note_name)
		note_name = new_note_name
	update_alert()

/datum/status_effect/buff/soundbreaker_prepared/proc/update_alert()
	if(!owner)
		return
	linked_alert.name = "Prepared: [note_name]"
	linked_alert.desc = "Your next strike will play this note."
	linked_alert.icon_state = soundbreaker_note_icon_state(note_id)

/datum/status_effect/buff/soundbreaker_prepared/proc/soundbreaker_note_icon_state(note_id)
	switch(note_id)
		if(SOUNDBREAKER_NOTE_BEND) return "sb_note_bend"
		if(SOUNDBREAKER_NOTE_BARE) return "sb_note_bare"
		if(SOUNDBREAKER_NOTE_SLAP) return "sb_note_slap"
		if(SOUNDBREAKER_NOTE_SHED) return "sb_note_shed"
		if(SOUNDBREAKER_NOTE_SOLO) return "sb_note_solo"
		if(SOUNDBREAKER_NOTE_RIFF) return "sb_note_riff"
	return "buff"

/atom/movable/screen/alert/status_effect/buff/soundbreaker_prepared
	name = "Prepared Note"
	desc = "A note is primed."
	icon_state = "buff"

/datum/status_effect/buff/soundbreaker_riff
	id = "soundbreaker_riff"
	status_type = STATUS_EFFECT_REFRESH
	duration = 4 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/buff/soundbreaker_riff

/datum/status_effect/buff/soundbreaker_riff/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_GUIDANCE, "soundbreaker_riff")
	return TRUE

/datum/status_effect/buff/soundbreaker_riff/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GUIDANCE, "soundbreaker_riff")
	. = ..()

/atom/movable/screen/alert/status_effect/buff/soundbreaker_riff
	name = "Riff Guard"
	desc = "A defensive riff is active. A successful defense may grant combo."
	icon_state = "buff"
