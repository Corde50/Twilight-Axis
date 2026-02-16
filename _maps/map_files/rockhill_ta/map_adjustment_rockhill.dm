/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/template/rockhill
	map_file_name = "rockhill_ta.dmm"
	realm_name = "Rockhill"
	blacklist = list(/datum/job/roguetown/manorguard)
	slot_adjust = list(
	/datum/job/roguetown/squire = 2
	)
	title_adjust = list(
		/datum/job/roguetown/physician = list(display_title = "Court Physician"),
		/datum/job/roguetown/manorguard_enigma = list(display_title = "Man At Arms"),
	)
	tutorial_adjust = list(
		/datum/job/roguetown/physician = "You are a master physician, trusted by the Duke themself to administer expert care to the Royal family, the court, \
		its protectors and its subjects. While primarily a resident of the keep in the manors medical wing, you also have access \
		 to the local hightown clinic, where lesser licensed apothecaries ply their trade under your occasional passing tutelage."
	)
	threat_regions = list(
		THREAT_REGION_ROCKHILL_BASIN,
		THREAT_REGION_ROCKHILL_BOG_NORTH,
		THREAT_REGION_ROCKHILL_BOG_WEST,
		THREAT_REGION_ROCKHILL_BOG_SOUTH,
		THREAT_REGION_ROCKHILL_BOG_SUNKMIRE,
		THREAT_REGION_ROCKHILL_WOODS_NORTH,
		THREAT_REGION_ROCKHILL_WOODS_SOUTH
	)
