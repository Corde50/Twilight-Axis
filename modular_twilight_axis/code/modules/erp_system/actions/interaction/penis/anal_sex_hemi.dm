/datum/erp_action/other/penis/hemi/anal_double
	abstract_type = FALSE

	name = "Геми-анальный секс"
	required_target_organ = SEX_ORGAN_ANUS
	armor_slot_target = BODY_ZONE_PRECISE_GROIN

	affects_self_arousal = 2.0
	affects_arousal = 1.25
	affects_self_pain = 0.04
	affects_pain = 0.01
	can_knot = TRUE

		can_be_custom = FALSE

	message_start = "{actor} {pose} прижимает оба ствола к анусу {partner}."
	message_tick = "{actor} {pose}, {force} и {speed} сношает в попку {partner} двумя стволами."
	message_finish =  "{actor} вытаскивает члены из влагалища {partner}."
	message_climax_active = "{actor} кончает в попку {partner}."
	message_climax_passive = "{partner} кончает сжимая анус вокруг членов {actor}."
	climax_liquid_mode_active = "into"
	
/datum/erp_action/other/penis/hemi/anal_double/get_knot_count()
	return 1
