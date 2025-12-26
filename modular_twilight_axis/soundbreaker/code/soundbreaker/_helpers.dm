// Глобальные точки входа, которые зовут оффы/спеллы.
// Внутри — только делегирование в компонент.

/proc/soundbreaker_get_component(mob/living/user)
	if(!isliving(user))
		return null

	var/datum/component/combo_core/soundbreaker/C = user.GetComponent(/datum/component/combo_core/soundbreaker)
	if(!C)
		// если у тебя Init-аргументы другие — подстрой
		C = user.AddComponent(/datum/component/combo_core/soundbreaker)
	return C

/proc/soundbreaker_prime_note(mob/living/user, note_id, damage_mult, damage_type, note_name)
	var/datum/component/combo_core/soundbreaker/C = soundbreaker_get_component(user)
	return C ? C.PrimeNote(note_id, damage_mult, damage_type, note_name) : FALSE

/// Биндинг bclass → armor damage flag
/proc/soundbreaker_get_damage_flag(bclass, damage_type)
	switch(bclass)
		if(BCLASS_BLUNT, BCLASS_SMASH, BCLASS_TWIST, BCLASS_PUNCH)
			return "blunt"
		if(BCLASS_CHOP, BCLASS_CUT, BCLASS_LASHING, BCLASS_PUNISH)
			return "slash"
		if(BCLASS_PICK, BCLASS_STAB, BCLASS_PIERCE)
			return "stab"

	switch(damage_type)
		if(BRUTE)
			return "blunt"
		if(BURN)
			return "fire"
		if(TOX)
			return "bio"
		if(OXY)
			return "oxy"

	return "blunt"

/proc/soundbreaker_try_consume_prepared_attack(mob/living/user, mob/living/target, zone)
	if(!isliving(user))
		return FALSE
	if(SEND_SIGNAL(user, COMSIG_SOUNDBREAKER_TRY_CONSUME_PREPARED, target, zone) & COMPONENT_SOUNDBREAKER_CONSUMED)
		return TRUE
	return FALSE

/proc/soundbreaker_riff_defense_success(mob/living/defender)
	if(!isliving(defender))
		return
	SEND_SIGNAL(defender, COMSIG_SOUNDBREAKER_RIFF_DEFENSE_SUCCESS)
