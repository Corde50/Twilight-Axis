/obj/effect/proc_holder/spell/self/conjure_armor/vines
	name = "Conjure vine armour"
	desc = "Conjure a vine armour, which can defend."
	overlay_state = "teambeast"
	sound = list('sound/magic/whiteflame.ogg')
	releasedrain = 50
	chargedrain = 1
	no_early_release = TRUE
	recharge_time = 5 MINUTES
	miracle = TRUE
	devotion_cost = 150
	invocations = list("Threefather! Give me you'r protect!")
	invocation_type = "shout"


	objtoequip = /obj/item/clothing/suit/roguetown/vinearmour
	slottoequip = SLOT_ARMOR
	checkspot = "armor"

/obj/effect/proc_holder/spell/self/conjure_armor/vines/Destroy()
	if(src.conjured_armor)
		conjured_armor.visible_message(span_warning("The [conjured_armor]'s borders begin to shimmer and fade, before it vanishes entirely!"))
		qdel(conjured_armor)
	return ..()

#define ARMOR_VINES list("blunt" = 60, "slash" = 60, "stab" = 70, "piercing" = 60, "fire" = 0, "acid" = 0)

/obj/item/clothing/suit/roguetown/vinearmour
	name = "Vine armor"
	desc = "An holy vine's armor."
	max_integrity = 200
	break_sound = 'sound/foley/breaksound.ogg'
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	icon = 'modular_twilight_axis/icons/roguetown/clothing/armor.dmi'
	icon_state = "druid"
	slot_flags = ITEM_SLOT_ARMOR
	mob_overlay_icon = 'modular_twilight_axis/icons/roguetown/clothing/onmob/armor.dmi'
	sleeved = null
	boobed = TRUE
	flags_inv = null
	armor_class = ARMOR_CLASS_LIGHT
	blade_dulling = DULLING_BASHCHOP
	blocksound = PLATEHIT
	armor = ARMOR_VINES
	body_parts_covered = COVERAGE_FULL | NECK | HANDS | FEET
	unenchantable = TRUE

/obj/item/clothing/suit/roguetown/vinearmour/equipped(mob/living/user)
	. = ..()
	if(!QDELETED(src))
		user.apply_status_effect(/datum/status_effect/buff/vinearmour)


/obj/item/clothing/suit/roguetown/vinearmour/proc/dispel()
	if(!QDELETED(src))
		src.visible_message(span_warning("The [src]'s body no more covered by vines!"))
		qdel(src)

/obj/item/clothing/suit/roguetown/vinearmour/obj_break()
	. = ..()
	if(!QDELETED(src))
		dispel()

/obj/item/clothing/suit/roguetown/vinearmour/attack_hand(mob/living/user)
	. = ..()
	if(!QDELETED(src))
		dispel()
	
/obj/item/clothing/suit/roguetown/vinearmour/dropped(mob/living/user)
	. = ..()
	user.remove_status_effect(/datum/status_effect/buff/vinearmour)
	if(!QDELETED(src))
		dispel()

/datum/status_effect/buff/vinearmour
	id = "vinearmour"
	alert_type = /atom/movable/screen/alert/status_effect/buff/vinearmour
	duration = -1
	examine_text = "<font color='green'>SUBJECTPRONOUN is covered in vines!</font>"
	var/outline_colour = "#042013"
	effectedstats = list(STATKEY_STR = 1, STATKEY_WIL = -1, STATKEY_SPD = -1)

/atom/movable/screen/alert/status_effect/buff/vinearmour
	name = "Vinearmour"
	desc = "The vines hirt you, but protects!"




