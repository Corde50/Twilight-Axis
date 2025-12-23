#define SB_MAX_VISIBLE_NOTES 5

/proc/sb_get_note_icon_state(note_id)
	switch(note_id)
		if(SOUNDBREAKER_NOTE_BEND)      return "note_strike"
		if(SOUNDBREAKER_NOTE_BARE)        return "note_wave"
		if(SOUNDBREAKER_NOTE_SLAP)       return "note_dulce"
		if(SOUNDBREAKER_NOTE_SHED)    return "note_overload"
		if(SOUNDBREAKER_NOTE_SOLO)      return "note_encore"
		if(SOUNDBREAKER_NOTE_RIFF)        return "note_solo"
	return null

/proc/soundbreaker_show_note_icon(mob/living/user, note_id)
	if(!user || !note_id)
		return

	if(!islist(user.sb_note_history))
		user.sb_note_history = list()

	user.sb_note_history += note_id

	while(user.sb_note_history.len > SB_MAX_VISIBLE_NOTES)
		user.sb_note_history.Cut(1, 2)

	soundbreaker_update_note_overlays(user)

/proc/soundbreaker_update_note_overlays(mob/living/user)
	if(!user)
		return

	if(islist(user.sb_note_overlays) && user.sb_note_overlays.len)
		for(var/mutable_appearance/old_ma as anything in user.sb_note_overlays)
			if(old_ma)
				user.cut_overlay(old_ma)
		user.sb_note_overlays.Cut()
	else
		user.sb_note_overlays = list()

	if(!islist(user.sb_note_history) || !user.sb_note_history.len)
		return

	var/base_y = 18
	var/step_x = 8
	var/offset_idx = 0
	var/start_x = 8

	for(var/i = user.sb_note_history.len, i >= 1, i--)
		var/note_id = user.sb_note_history[i]
		var/state = sb_get_note_icon_state(note_id)
		if(!state)
			continue

		var/mutable_appearance/MA = mutable_appearance(SOUNDBREAKER_NOTES_ICON, state)
		MA.layer = ABOVE_MOB_LAYER + 0.2
		MA.pixel_y = base_y

		MA.pixel_x = -(offset_idx * step_x) + start_x
		offset_idx++

		user.add_overlay(MA)
		user.sb_note_overlays += MA

/proc/soundbreaker_clear_note_icons(mob/living/user)
	if(!user)
		return

	if(islist(user.sb_note_overlays) && user.sb_note_overlays.len)
		for(var/mutable_appearance/MA as anything in user.sb_note_overlays)
			if(MA)
				user.cut_overlay(MA)
		user.sb_note_overlays.Cut()

	if(islist(user.sb_note_history) && user.sb_note_history.len)
		user.sb_note_history.Cut()

/proc/soundbreaker_show_combo_icon(mob/living/user, icon_state)
	if(!user || !icon_state)
		return

	var/duration = 0.7 SECONDS
	user.play_overhead_indicator_flick(SOUNDBREAKER_NOTES_ICON, icon_state, duration, ABOVE_MOB_LAYER + 0.3, null, 16, 0)
