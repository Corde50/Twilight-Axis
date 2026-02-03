/atom/movable/screen/alert/status_effect/emberwine
	name = "Aphrodisiac"
	desc = "The warmth is spreading through my body..."
	icon = 'modular_twilight_axis/icons/mob/screen_alert.dmi'
	icon_state = "emberwine"

/datum/status_effect/debuff/emberwine
	id = "emberwine"
	effectedstats = list(STATKEY_LCK = -1)
	duration = 1 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/emberwine

/datum/status_effect/debuff/nekoldun
	id = "Psydon's Music"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/nekoldun
	duration = 70 SECONDS

/datum/status_effect/debuff/nekoldun/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SPELLCOCKBLOCK, id)

/datum/status_effect/debuff/nekoldun/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SPELLCOCKBLOCK, id)

/atom/movable/screen/alert/status_effect/debuff/nekoldun
	name = "Psydon's Music"

/datum/status_effect/debuff/vampiric_slowdown 
	id = "vampiric_slowdown"
	duration = 120 
	alert_type = null 
	effectedstats = list(STATKEY_SPD = -4) 

/datum/status_effect/debuff/vampiric_slowdown/on_apply()
	. = ..()
	if(owner)
		to_chat(owner, span_warning("The dark link weighs heavily on my soul, slowing my movements!"))

/datum/status_effect/debuff/vampiric_slowdown/on_remove()
	if(owner)
		to_chat(owner, span_notice("The burden lifts, and I regain my speed."))
	. = ..()
