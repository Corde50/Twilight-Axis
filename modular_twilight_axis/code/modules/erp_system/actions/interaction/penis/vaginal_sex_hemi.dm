/datum/erp_action/other/penis/hemi/vaginal_double
	abstract_type = FALSE

	name = "Геми-вагинальный секс"
	required_target_organ = SEX_ORGAN_VAGINA
	armor_slot_target = BODY_ZONE_PRECISE_GROIN

	affects_self_arousal	= 2.0
	affects_arousal			= 1.5
	affects_self_pain		= 0.04
	affects_pain			= 0.01

		can_be_custom = FALSE

	message_start = "{actor} {pose} прижимает оба ствола к вагине {partner}."
	message_tick = "{actor} {pose}, {force} и {speed} сношает в лоно {partner} двумя стволами."
	message_finish =  "{actor}  вытаскивает члены из влагалища {partner}."
	message_climax_active = "{actor} кончает в лоно {partner}."
	message_climax_passive = "{partner} кончает сжимая киску вокруг члена {actor}."
	climax_liquid_mode_active = "into"
	
/datum/erp_action/other/penis/hemi/vaginal_double/get_knot_count()
	return 1
