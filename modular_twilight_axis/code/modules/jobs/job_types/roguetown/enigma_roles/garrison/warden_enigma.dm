/datum/job/roguetown/warden_enigma
	title = "Warden(Enigma)"
	flag = WARDENENIGMA
	department_flag = VANGUARD
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = JCOLOR_VANGUARD
	allowed_races = RACES_TOLERATED_UP
	allowed_ages = list(AGE_MIDDLEAGED, AGE_OLD)
	display_order = JDO_WARDENENIGMA
	tutorial = "Вам, как опытному солдату из свиты герцога, поручено наблюдать за недавно построенным Бастионом. \
				Вы подчиняетесь маршалу и его советникам,\
				и ваша задача - держать авангард в строю и следить за тем, чтобы пути в город оставались безопасными.\
				Бастион не должен пасть."
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/warden_enigma
	advclass_cat_rolls = list(CTAG_WARDEN_ENIGMA = 2)
	give_bank_account = TRUE
	min_pq = 10
	max_pq = null
	always_show_on_latechoices = TRUE

	cmode_music = 'modular_twilight_axis/sound/music/combat/combat_vanguard.ogg'
	job_subclasses = list(
		/datum/job/roguetown/warden_enigma,
	)

/datum/job/roguetown/warden_enigma/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		title = "Warden"
		display_title = "Warden"
		var/mob/living/carbon/human/H = L
		if(istype(H.wear_armor, /obj/item/clothing/cloak/wardencloak/enigma))
			var/obj/item/clothing/S = H.wear_armor
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "warden's cloak ([index])"

/datum/advclass/warden_enigma
	name = "Warden"
	tutorial = "Вам, как опытному солдату из свиты герцога, поручено наблюдать за недавно построенным Бастионом. \
				Вы подчиняетесь маршалу и его советникам,\
				и ваша задача - держать авангард в строю и следить за тем, чтобы пути в город оставались безопасными.\
				Бастион не должен пасть."
	outfit = /datum/outfit/job/roguetown/warden_enigma

	category_tags = list(CTAG_WARDEN_ENIGMA)
	traits_applied = list(TRAIT_MEDIUMARMOR, TRAIT_WOODSMAN, TRAIT_STEELHEARTED)
	subclass_stats = list(
		STATKEY_STR = 3,
		STATKEY_PER = 2,
		STATKEY_CON = 2,
		STATKEY_WIL = 2,
		STATKEY_INT = 1,
	)
	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/crossbows = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/twilight_firearms = SKILL_LEVEL_APPRENTICE
	)

/datum/outfit/job/roguetown/warden_enigma
	job_bitflag = BITFLAG_VANGUARD
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/antler/warden_enigma
	pants = /obj/item/clothing/under/roguetown/chainlegs
	armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass	
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	backl = /obj/item/rogueweapon/shield/tower
	backr = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/rogueweapon/scabbard/sword
	beltr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick
	cloak = /obj/item/clothing/cloak/wardencloak
	backpack_contents = list(/obj/item/storage/keyring/warden_enigma = 1, /obj/item/signal_hornn/green = 1, /obj/item/rogueweapon/scabbard/sheath = 1, /obj/item/rogueweapon/huntingknife/idagger/steel = 1)

/datum/outfit/job/roguetown/warden_enigma/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		SStreasury.give_money_account(ECONOMIC_UPPER_MIDDLE_CLASS, H, "Savings.")
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/movemovemove)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/takeaim)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/hold)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/onfeet)
	H.verbs |= list(/mob/proc/haltyell, /mob/living/carbon/human/mind/proc/setorders)

/obj/item/clothing/head/roguetown/helmet/bascinet/antler/warden_enigma
	desc = "A beastly snouted armet with the large horns of an elder saiga protruding from it."

/obj/item/clothing/cloak/wardencloak/enigma
	desc = "Плащ, который носит смотритель Авангарда."
