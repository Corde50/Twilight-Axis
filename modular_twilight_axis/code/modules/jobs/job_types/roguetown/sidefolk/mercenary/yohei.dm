/datum/advclass/mercenary/twilight_yohei
	name = "Yohei"
	tutorial = "Au Ra do not see shame in taking coin for war. A worthy conflict tempers the spirit, strengthens the arm, and brings prosperity to the clan waiting beyond the horizon. Above all stands family. Clan is not a memory left behind, but a presence carried with every step. Each contract you accept, each blade you draw, each wound you endure... all of it is for the home where, one day, you may lay your armor aside."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list(/datum/species/aura)
	outfit = /datum/outfit/job/roguetown/mercenary/twilight_yohei
	category_tags = list(CTAG_MERCENARY)
	class_select_category = CLASS_CAT_KAZENGUN
	maximum_possible_slots = 2
	cmode_music = 'modular_twilight_axis/sound/music/combat_yohei.ogg'
	subclass_languages = list(/datum/language/kazengunese)
	traits_applied = list(TRAIT_DODGEEXPERT)
	subclass_stats = list(
		STATKEY_SPD = 3,
		STATKEY_INT = 2,
		STATKEY_PER = 2,
		STATKEY_STR = 1
	)

	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE
	)
	extra_context = "This subclass is race-limited to: Au Ra only. Starts with a choice of two unique Kazengunese swords and a choice of two unique Kazengunese masks."

/datum/outfit/job/roguetown/mercenary/twilight_yohei/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	has_loadout = TRUE
	to_chat(H, span_warning("Au Ra do not see shame in taking coin for war. A worthy conflict tempers the spirit, strengthens the arm, and brings prosperity to the clan waiting beyond the horizon. Above all stands family. Clan is not a memory left behind, but a presence carried with every step. Each contract you accept, each blade you draw, each wound you endure... all of it is for the home where, one day, you may lay your armor aside."))

	head = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/yohei
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants2
	armor = /obj/item/clothing/suit/roguetown/armor/basiceast/yohei
	cloak = /obj/item/clothing/cloak/thief_cloak/yohei
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt1
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather/cloth
	neck = 	/obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves1
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	backpack_contents = list(
		/obj/item/roguekey/mercenary,
		/obj/item/flashlight/flare/torch/lantern,
		/obj/item/rogueweapon/huntingknife/idagger/steel/kazengun,
		/obj/item/rogueweapon/scabbard/sheath/kazengun
		)
	H.merctype = 9

/datum/outfit/job/roguetown/mercenary/twilight_yohei/choose_loadout(mob/living/carbon/human/H)
	. = ..()
	var/weapons = list("Hu Tou Gou", "Miaodao")
	var/weapon_choice = input("Choose your weapon.", "THE BLADE DECIDES.") as anything in weapons
	switch(weapon_choice) //A large selection of exotic starter options, as per the class gimmick.
		if ("Hu Tou Gou")
			ADD_TRAIT(H, TRAIT_DUALWIELDER, TRAIT_GENERIC)
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/sword, SLOT_BELT_L, TRUE)
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/sword, SLOT_BELT_R, TRUE)
			H.put_in_hands(new /obj/item/rogueweapon/sword/sabre/hook)
			H.put_in_hands(new /obj/item/rogueweapon/sword/sabre/hook)
		if ("Miaodao")
			H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/gwstrap, SLOT_BACK_R, TRUE)
			H.put_in_hands(new /obj/item/rogueweapon/greatsword/miaodao)
	var/masks = list("Half-Mask", "Oni", "Kitsune")
	var/mask_choice = input("Choose your mask.", "BEHIND THE HORN AND STEEL.") as anything in masks
	switch(mask_choice)
		if("Half-Mask")
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel/kazengun/yohei, SLOT_WEAR_MASK, TRUE)
		if("Oni")
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel/kazengun/yohei/oni, SLOT_WEAR_MASK, TRUE)
		if("Kitsune")
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel/kazengun/yohei/kitsune, SLOT_WEAR_MASK, TRUE)

/obj/item/clothing/suit/roguetown/armor/basiceast/yohei
	icon = 'modular_twilight_axis/icons/roguetown/clothing/armor.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/roguetown/clothing/onmob/armor.dmi'
	icon_state = "yoheisuit"
	armor = ARMOR_LEATHER_STUDDED
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 25

/obj/item/clothing/head/roguetown/roguehood/shalal/hijab/yohei
	max_integrity = 100
	armor = ARMOR_SPELLSINGER
	color = CLOTHING_BLACK
	desc = "A traditional Kazengunese hood, dyed in dark colors."

/obj/item/clothing/cloak/thief_cloak/yohei
	name = "shadowed cloak"
	desc = "A dark cloak favored by Kazengunese mercenaries."
	color = CLOTHING_BLACK

/obj/item/clothing/mask/rogue/facemask/steel/kazengun/yohei
	name = "steel mempo"
	desc = "\"The first article: Forget nothing, forgive nothing.\""
	icon = 'modular_twilight_axis/icons/roguetown/clothing/masks.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/roguetown/clothing/onmob/masks.dmi'
	icon_state = "steelmempo"
	body_parts_covered = NECK|MOUTH|NOSE

/obj/item/clothing/mask/rogue/facemask/steel/kazengun/yohei/oni
	name = "steel oni mempo"
	desc = "\"The second article: Endure in silence, speak only through steel.\""
	icon_state = "steelonimempo"
	armor = ARMOR_PLATE
	body_parts_covered = NECK|FACE

/obj/item/clothing/mask/rogue/facemask/steel/kazengun/yohei/kitsune
	name = "steel kitsune mempo"
	desc = "\"The third article: Mercy is a luxury the wise cannot afford.\""
	icon_state = "steelkitsunemempo"

/datum/intent/sword/cut/miaodao
	reach = 2
	swingdelay = 4
	penfactor = 20

/datum/intent/sword/cut/miaodao/fast
	clickcd = 9

/datum/intent/sword/peel/miaodao
	name = "long sword armor peel"
	peel_divisor = 4
	reach = 2

/obj/item/rogueweapon/greatsword/miaodao
	name = "steel miaodao"
	icon = 'modular_twilight_axis/icons/roguetown/weapons/64.dmi'
	icon_state = "odachi"
	desc = "An unusually long saber of Lingyunese origin. The lighter blade lends itself to one-handed use better than a zweihander, but maintaining edge alignment is tricky and requires experience."
	force = 24
	force_wielded = 30
	minstr = 8
	wdefense = 6
	wdefense_wbonus = 1
	max_blade_int = 150 
	wbalance = WBALANCE_SWIFT
	possible_item_intents = list(/datum/intent/sword/cut/miaodao/fast, /datum/intent/sword/strike)
	gripped_intents = list(/datum/intent/sword/cut/miaodao, /datum/intent/sword/thrust/zwei, /datum/intent/sword/peel/miaodao, /datum/intent/rend/reach)
	alt_intents = null

/obj/item/rogueweapon/greatsword/miaodao/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen") return list("shrink" = 0.5, "sx" = -14, "sy" = -8, "nx" = 15, "ny" = -7, "wx" = -10, "wy" = -5, "ex" = 7, "ey" = -6, "northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0, "nturn" = -13, "sturn" = 110, "wturn" = -60, "eturn" = -30, "nflip" = 1, "sflip" = 1, "wflip" = 8, "eflip" = 1)
			if("wielded") return list("shrink" = 0.6,"sx" = 9,"sy" = -4,"nx" = -7,"ny" = 1,"wx" = -9,"wy" = 2,"ex" = 10,"ey" = 2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 5,"sturn" = -190,"wturn" = -170,"eturn" = -10,"nflip" = 8,"sflip" = 8,"wflip" = 1,"eflip" = 0)
			if("onback") return list("shrink" = 0.5, "sx" = -1, "sy" = 2, "nx" = 0, "ny" = 2, "wx" = 2, "wy" = 1, "ex" = 0, "ey" = 1, "nturn" = 0, "sturn" = 0, "wturn" = 70, "eturn" = 15, "nflip" = 1, "sflip" = 1, "wflip" = 1, "eflip" = 1, "northabove" = 1, "southabove" = 0, "eastabove" = 0, "westabove" = 0)
