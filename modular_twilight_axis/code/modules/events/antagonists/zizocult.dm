#define ZIZO_CULT_BLACKLISTED_ROLES list(\
		"Grand Duke",\
		"Marshal",\
		"Merchant",\
		"Bishop",\
		"Martyr",\
		"Hand",\
		"Steward",\
		"Knight Captain",\
		"Knight",\
		"Templar",\
		"Sergeant",\
		"Inquisitor",\
		"Absolver",\
		"Veteran",\
		"Bathmaster",\
		"Bandit",\
		"Guildmaster",\
		"Court Magician",\
		"Keeper",\
		"Orthodoxist",\
		"Druid",\
		"Acolyte",\
		"Man at Arms",\
		"Squire",\
		"Prince",\
	)

/datum/round_event_control/antagonist/solo/zizo_cult
	name = "Zizo cult"
	tags = list(
		TAG_COMBAT,
		TAG_HAUNTED,
		TAG_VILLIAN,
	)
	roundstart = TRUE
	antag_flag = ROLE_CULT
	shared_occurence_type = SHARED_HIGH_THREAT

	base_antags = 1
	maximum_antags = 2

	weight = 2
	max_occurrences = 1

	earliest_start = 0 SECONDS

	typepath = /datum/round_event/antagonist/solo/zizo_cult
	antag_datum = /datum/antagonist/zizocultist/leader

	restricted_roles = ZIZO_CULT_BLACKLISTED_ROLES

/datum/round_event_control/antagonist/solo/zizo_cult/trim_candidates(list/candidates)
    . = ..()

    for(var/mob/living/candidate as anything in .)
        if(istype(candidate.patron, /datum/patron/inhumen/zizo))
            continue

        . -= candidate

/datum/round_event/antagonist/solo/zizo_cult

/datum/storyteller/proc/on_set()
    return

/datum/storyteller/zizo/on_set()
    . = ..()

    SSgamemode.current_roundstart_event = new /datum/round_event_control/antagonist/solo/zizo_cult

#undef ZIZO_CULT_BLACKLISTED_ROLES
