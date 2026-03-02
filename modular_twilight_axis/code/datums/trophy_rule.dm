/datum/trophy_rule
	var/name = "trophy rule"
	var/group_id = null

/datum/trophy_rule/proc/matches(obj/item/I)
	return FALSE

/datum/trophy_rule/proc/get_score(obj/item/I)
	return 0

/datum/trophy_rule/proc/apply(mob/living/user, obj/item/I)
	return

/datum/trophy_rule/proc/remove(mob/living/user)
	return

/datum/trophy_rule/proc/build_effect(obj/item/I)
	return null

/datum/trophy_rule/troll_armor
	name = "troll armor"
	group_id = "armor"

/datum/trophy_rule/troll_armor/matches(obj/item/I)
	return istype(I, /obj/item/natural/head/troll)

/datum/trophy_rule/troll_armor/get_score(obj/item/I)
	if(istype(I, /obj/item/natural/head/troll/cave))
		return 20
	if(istype(I, /obj/item/natural/head/troll/axe))
		return 15
	return 10

/datum/trophy_rule/troll_armor/apply(mob/living/user, obj/item/I)
	var/value = get_score(I)
	user.change_stat(STATKEY_ARMOR, value)

/datum/trophy_rule/troll_armor/remove(mob/living/user)
	user.change_stat(STATKEY_ARMOR, -value)

/datum/trophy_rule/troll_armor/build_effect(obj/item/I)
	var/datum/trophy_effect/E = new
	E.group_id = group_id
	E.effect_type = TROPHY_EFFECT_ARMOR
	E.value = get_score(I)
	E.message = "You feel your skin harden with the resilience of a troll."
	return E

/datum/trophy_rule/minotaur_strong
	name = "minotaur strength"
	group_id = "strong"

/datum/trophy_rule/minotaur_strong/matches(obj/item/I)
	return istype(I, /obj/item/natural/head/minotaur)

/datum/trophy_rule/minotaur_strong/get_score(obj/item/I)
	return 2

/datum/trophy_rule/minotaur_strong/build_effect(obj/item/I)
	var/datum/trophy_effect/E = new
	E.group_id = group_id
	E.effect_type = TROPHY_EFFECT_STRONG
	E.value = 2
	E.message = "You feel the crushing strength of the minotaur flow into your limbs."
	return E

/datum/trophy_rule/dragon_perception
	name = "dragon precision"
	group_id = "perception"

/datum/trophy_rule/dragon_perception/matches(obj/item/I)
	return istype(I, /obj/item/natural/head/dragon) && !istype(I, /obj/item/natural/head/dragon/broodmother)

/datum/trophy_rule/dragon_perception/get_score(obj/item/I)
	return 1

/datum/trophy_rule/dragon_perception/build_effect(obj/item/I)
	var/datum/trophy_effect/E = new
	E.group_id = group_id
	E.effect_type = TROPHY_EFFECT_PERCEPTION
	E.value = 1
	E.message = "You feel the dragon's lethal precision sharpen your senses."
	return E

/datum/trophy_rule/aspirant_rage
	name = "aspirant rage"
	group_id = "rage"

/datum/trophy_rule/aspirant_rage/matches(obj/item/I)
	return istype(I, /obj/item/natural/head/dragon/broodmother)

/datum/trophy_rule/aspirant_rage/get_score(obj/item/I)
	return 15

/datum/trophy_rule/aspirant_rage/build_effect(obj/item/I)
	var/datum/trophy_effect/E = new
	E.group_id = group_id
	E.effect_type = TROPHY_EFFECT_RAGE_DURATION
	E.value = 15
	E.message = "The fury you felt battling this horror burns through your body once more."
	return E
