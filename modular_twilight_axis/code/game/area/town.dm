/area/rogue/indoors/town/Academy
	name = "Academy"
	icon_state = "magician"
	spookysounds = SPOOKY_MYSTICAL
	spookynight = SPOOKY_MYSTICAL
	droning_sound = 'sound/music/area/magiciantower.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	first_time_text = "THE ACADEMY OF ENIGMA"
	deathsight_message = "the rustle of heavy books"
	keep_area = TRUE
	detail_text = DETAIL_TEXT_UNIVERSITY_OF_AZURIA

/area/rogue/indoors/town/dwarfin/rockhill
	first_time_text = "Rockhill Guild of Crafts"

/area/rogue/indoors/town/grove
	name = "Druids grove"
	icon_state = "rtfield"
	first_time_text = "Druids grove"
	droning_sound = list('sound/ambience/riverday (1).ogg','sound/ambience/riverday (2).ogg','sound/ambience/riverday (3).ogg')
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = list ('sound/ambience/rivernight (1).ogg','sound/ambience/rivernight (2).ogg','sound/ambience/rivernight (3).ogg' )
	converted_type = /area/rogue/indoors/shelter/woods
	deathsight_message = "A sacred place of dendor, beneath the tree of Aeons.."
	warden_area = TRUE
	town_area = FALSE

/area/rogue/indoors/town/manor/rockhill
	first_time_text = "Rockhill Keep"
	deathsight_message = "those sequestered amongst Astrata's favor"

/area/rogue/indoors/town/warden
	name = "Warden Fort"
	warden_area = TRUE
	deathsight_message = "a moss covered stone redoubt, guarding against the wilds"

/area/rogue/outdoors/town/rockhill
	name = "outdoors rockhill"
	first_time_text = "The Town of Rockhill"
	deathsight_message = "the city of Rockhill and all its bustling souls"

/area/rogue/under/town/basement/tavern
	name = "tavern basement"
	icon_state = "basement"
	tavern_area = TRUE
	town_area = TRUE
	ceiling_protected = TRUE
	deathsight_message = "a room full of aging ales"
