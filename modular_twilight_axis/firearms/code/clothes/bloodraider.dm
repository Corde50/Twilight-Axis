/obj/item/clothing/head/roguetown/helmet/bloodhelmet
	name = "bloodraider helmet"
	desc = "A darksteel helmet that doesn't obstruct the wearer's vision. Fitted with a sharp horn for the most desperate situations."
	icon_state = "bloodhelmet"
	item_state = "bloodhelmet"
	body_parts_covered = HEAD | HAIR | EARS | EYES
	armor_class = ARMOR_CLASS_LIGHT
	max_integrity = 350
	smeltresult = /obj/item/ingot/steel
	icon = 'modular_twilight_axis/icons/clothing/bloodraider.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/clothing/onmob/bloodraider.dmi'

/obj/item/clothing/head/roguetown/helmet/bloodhelmet/ComponentInitialize()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "ARMOR")

/obj/item/clothing/head/roguetown/helmet/bloodhelmet/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/clothing/neck/roguetown/chaincoif/chainmantle/bloodraider
	name = "raiders mantle"
	desc = "A thicker and more durable piece of neck protection that also covers the mouth when pulled up."
	icon_state = "bloodchainmantle"
	item_state = "bloodchainmantle"
	armor = ARMOR_MAILLE
	body_parts_covered = NECK|MOUTH
	slot_flags = ITEM_SLOT_NECK
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	icon = 'modular_twilight_axis/icons/clothing/bloodraider.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/clothing/onmob/bloodraider.dmi'

/obj/item/clothing/neck/roguetown/chaincoif/chainmantle/bloodraider/ComponentInitialize()
	AddComponent(/datum/component/adjustable_clothing, (NECK), null, null, 'sound/foley/equip/equip_armor_chain.ogg', null, (UPD_HEAD|UPD_MASK|UPD_NECK))	//Chain coif.
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_FENCERDEXTERITY)
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_HONORBOUND)
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "ARMOR")

/obj/item/clothing/neck/roguetown/chaincoif/chainmantle/bloodraider/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/clothing/suit/roguetown/armor/plate/cuirass/bloodraider
	slot_flags = ITEM_SLOT_ARMOR
	name = "raiders cuirass"
	desc = "An elegant cuirass that doesn't restrict movement, intimidates enemies, and is simply beautiful. What more could you need?"
	body_parts_covered = COVERAGE_ALL_BUT_HANDLEGS
	icon_state = "bloodcuirass"
	item_state = "bloodcuirass"
	allowed_race = list(/datum/species/human/halfelf,/datum/species/elf/dark,/datum/species/elf/dark/raider,/datum/species/elf/wood,/datum/species/elf/sun)
	armor = ARMOR_PLATE
	nodismemsleeves = TRUE
	blocking_behavior = null
	max_integrity = ARMOR_INT_CHEST_MEDIUM_STEEL
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/steel
	armor_class = ARMOR_CLASS_LIGHT
	smelt_bar_num = 1
	icon = 'modular_twilight_axis/icons/clothing/bloodraider.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/clothing/onmob/bloodraider.dmi'

/obj/item/clothing/suit/roguetown/armor/plate/cuirass/bloodraider/ComponentInitialize()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "ARMOR")

/obj/item/clothing/suit/roguetown/armor/plate/cuirass/bloodraider/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/clothing/gloves/roguetown/bloodraider
	name = "raiders gauntlets"
	desc = "Clawed plate gauntlets, capable of tormenting N'wah with their tips"
	icon_state = "bloodgauntlets"
	item_state = "bloodgauntlets"
	armor = ARMOR_PLATE
	resistance_flags = FIRE_PROOF
	blocksound = PLATEHIT
	max_integrity = ARMOR_INT_SIDE_STEEL
	break_sound = 'sound/foley/breaksound.ogg'
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_plate.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_plate.ogg'
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/steel
	desc = "This brigandine is an example of the painstaking work of a skilled, and very poor, craftsman. The gambenison, lined with metal parts and scraps of chain mail, is impossible to ruin even with such 'artistry'."
	icon = 'modular_twilight_axis/icons/clothing/bloodraider.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/clothing/onmob/bloodraider.dmi'

/obj/item/clothing/gloves/roguetown/bloodraider/ComponentInitialize()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "ARMOR")

/obj/item/clothing/gloves/roguetown/bloodraider/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/clothing/under/roguetown/bloodsplintlegs
	name = "raiders splintlegs"
	desc = "Raiders best friend, designed to protect the legs while still providing almost complete free range of movement."
	icon_state = "bloodsplintlegs"
	item_state = "bloodsplintlegs"
	max_integrity = ARMOR_INT_LEG_BRIGANDINE
	armor = ARMOR_BRIGANDINE
	blocksound = SOFTHIT
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/steel
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD
	resistance_flags = FIRE_PROOF
	armor_class = ARMOR_CLASS_LIGHT
	w_class = WEIGHT_CLASS_NORMAL
	//resistance_flags = FIRE_PROOF // these ones should be burning since is cloth + metal
	sewrepair = FALSE
	smeltresult = /obj/item/ingot/steel
	icon = 'modular_twilight_axis/icons/clothing/bloodraider.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/clothing/onmob/bloodraider.dmi'

/obj/item/clothing/under/roguetown/bloodsplintlegs/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/item_equipped_movement_rustle, SFX_PLATE_COAT_STEP, 10)
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_FENCERDEXTERITY)
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "ARMOR")

/obj/item/clothing/under/roguetown/bloodsplintlegs/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/clothing/shoes/roguetown/boots/bloodboots
	name = "raiders boots"
	desc = "Custom-fitted sabatons, made from a series of interlinking darksteel plates. "
	body_parts_covered = FEET
	icon_state = "bloodboots"
	item_state = "bloodboots"
	color = null
	blocksound = PLATEHIT
	resistance_flags = FIRE_PROOF
	max_integrity = ARMOR_INT_SIDE_STEEL
	armor = ARMOR_PLATE
	pickup_sound = 'sound/foley/equip/equip_armor_plate.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_plate.ogg'
	anvilrepair = /datum/skill/craft/armorsmithing
	sewrepair = FALSE
	smeltresult = /obj/item/ingot/steel
	sewrepair = FALSE
	icon = 'modular_twilight_axis/icons/clothing/bloodraider.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/clothing/onmob/bloodraider.dmi'

/obj/item/clothing/shoes/roguetown/boots/bloodboots/armor/ComponentInitialize()
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_FENCERDEXTERITY)
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_HONORBOUND)
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "ARMOR")

/obj/item/clothing/shoes/roguetown/boots/bloodboots/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/clothing/suit/roguetown/shirt/bloodraider
	name = "raider gambeson"
	desc = "A strong loosely worn quilted shirt that places little weight on the arms and legs, usually worn for protection from spiders "
	icon = 'modular_twilight_axis/icons/clothing/bloodraider.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/clothing/onmob/bloodraider.dmi'
	sleeved = 'modular_twilight_axis/icons/clothing/onmob/bloodraider.dmi'
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET
	icon_state = "bloodgambenzon"
	color = "#FFFFFF"
	var/shiftable = FALSE
	armor = ARMOR_PADDED
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 150
	blocksound = SOFTUNDERHIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	cold_protection = 10

/obj/item/clothing/suit/roguetown/shirt/bloodraider/ComponentInitialize()
	AddComponent(/datum/component/armour_filtering/positive, TRAIT_FENCERDEXTERITY)
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_HONORBOUND)
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "ARMOR")

/obj/item/clothing/suit/roguetown/shirt/bloodraider/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/clothing/wrists/roguetown/bracers/twilight_elven/bloodraider
	name = "raiders bracers"
	desc = "A pair of steel vambraces, protecting the arms from blows-most-foul. Painted in black and red"
	icon_state = "bloodbracers"
	item_state = "bloodbracers"
	allowed_race = NON_DWARVEN_RACE_TYPES
	icon = 'modular_twilight_axis/icons/clothing/bloodraider.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/clothing/onmob/bloodraider.dmi'
	sleeved = 'modular_twilight_axis/icons/clothing/onmob/bloodraider.dmi'
	alternate_worn_layer = WRISTS_LAYER

/obj/item/clothing/wrists/roguetown/bracers/twilight_elven/bloodraider/equipped(mob/user, slot)
	. = ..()
	user.update_inv_wrists()
	user.update_inv_gloves()
	user.update_inv_armor()
	user.update_inv_shirt()

/obj/item/clothing/wrists/roguetown/bracers/twilight_elven/bloodraider/ComponentInitialize()
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_FENCERDEXTERITY)
	AddComponent(/datum/component/armour_filtering/negative, TRAIT_HONORBOUND)
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "ARMOR")

/obj/item/clothing/wrists/roguetown/bracers/twilight_elven/bloodraider/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)
