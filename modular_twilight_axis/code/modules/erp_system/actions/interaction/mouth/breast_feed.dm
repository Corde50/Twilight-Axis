/datum/erp_action/other/mouth/breast_feed
	name = "Облизать грудь"
	required_target_organ = SEX_ORGAN_BREASTS
	require_same_tile = FALSE
	active_arousal_coeff  = 0.3
	passive_arousal_coeff = 0.8
	inject_timing = INJECT_CONTINUOUS
	inject_source = INJECT_FROM_PASSIVE
	inject_target_mode = INJECT_ORGAN

	message_start  = "{actor} {pose} касается губами груди {target} и облизывает их языком."
	message_tick   = "{actor} {pose}, {force} и {speed} облизывает соски {target}."
	message_finish = "{actor} убирает губы от груди {target}."

	message_climax_active  = "Тёплое молоко наполняет рот {actor}."
	message_climax_passive = "{target} чувствует, как соски отзываются влажным теплом."
