
//Border Reivers from a nearby state the. To "Reive" is to raid, These guys should be fast, look kind of poor but not be badly equipped.
//Solely an event mod atm expect alittle imbalance, readjust if added in actual gameplay

/datum/outfit/job/roguetown/human/northern/border_reiver/proc/add_random_reiver_helmet(mob/living/carbon/human/H)
	var/random_reiver_helmet = rand(1,7)
	switch(random_reiver_helmet)
		if(1)
			head = /obj/item/clothing/head/roguetown/helmet
		if(2)
			head = /obj/item/clothing/head/roguetown/helmet/skullcap
		if(3)
			head = /obj/item/clothing/head/roguetown/helmet/sallet
		if(4)
			head = /obj/item/clothing/head/roguetown/brimmed
		if(5)
			head = /obj/item/clothing/head/roguetown/knitcap
		if(6)
			head = /obj/item/clothing/head/roguetown/armingcap/padded

/mob/living/carbon/human/species/human/northern/border_reiver
	aggressive=1
	rude = TRUE
	mode = NPC_AI_IDLE
	faction = list("viking", "station")
	ambushable = FALSE
	cmode = 1
	setparrytime = 30
	flee_in_pain = TRUE
	a_intent = INTENT_HELP
	d_intent = INTENT_PARRY
	possible_mmb_intents = list(INTENT_BITE, INTENT_JUMP, INTENT_KICK, INTENT_SPECIAL)
	possible_rmb_intents = list(
		/datum/rmb_intent/feint,\
		/datum/rmb_intent/aimed,\
		/datum/rmb_intent/strong,\
		/datum/rmb_intent/riposte,\
		/datum/rmb_intent/weak
	)
	var/is_silent = FALSE /// Determines whether or not we will scream our funny lines at people.
	npc_max_jump_stamina = 0


/mob/living/carbon/human/species/human/northern/border_reiver/ambush
	aggressive=1
	wander = TRUE

/mob/living/carbon/human/species/human/northern/border_reiver/retaliate(mob/living/L)
	var/newtarg = target
	.=..()
	if(target)
		aggressive=1
		wander = TRUE
		if(!is_silent && target != newtarg)
			say(pick(GLOB.highwayman_aggro))
			pointed(target)

/mob/living/carbon/human/species/human/northern/border_reiver/should_target(mob/living/L)
	if(L.stat != CONSCIOUS)
		return FALSE
	. = ..()

/mob/living/carbon/human/species/human/northern/border_reiver/Initialize()
	. = ..()
	set_species(/datum/species/human/northern)
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)
	is_silent = TRUE


/mob/living/carbon/human/species/human/northern/border_reiver/after_creation()
	..()
	job = "Border Reiver"
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_LEECHIMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_BREADY, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	equipOutfit(new /datum/outfit/job/roguetown/human/northern/border_reiver)
	var/obj/item/organ/eyes/organ_eyes = getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		organ_eyes.eye_color = pick("27becc", "35cc27", "000000")
	update_hair()
	update_body()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	head.sellprice = 15 // Not much

/mob/living/carbon/human/species/human/northern/border_reiver/npc_idle()
	if(m_intent == MOVE_INTENT_SNEAK)
		return
	if(world.time < next_idle)
		return
	next_idle = world.time + rand(30, 70)
	if((mobility_flags & MOBILITY_MOVE) && isturf(loc) && wander)
		if(prob(20))
			var/turf/T = get_step(loc,pick(GLOB.cardinals))
			if(!istype(T, /turf/open/transparent/openspace))
				Move(T)
		else
			face_atom(get_step(src,pick(GLOB.cardinals)))
	if(!wander && prob(10))
		face_atom(get_step(src,pick(GLOB.cardinals)))

/mob/living/carbon/human/species/human/northern/border_reiver/handle_combat()
	if(mode == NPC_AI_HUNT)
		if(prob(2)) // do not make this big or else they NEVER SHUT UP
			emote("laugh")
	. = ..()

/datum/outfit/job/roguetown/human/northern/border_reiver/pre_equip(mob/living/carbon/human/H)
	..()
	//Body Stuff
	H.eye_color = "27becc"
	H.hair_color = "61310f"
	H.facial_hair_color = H.hair_color
	if(H.gender == FEMALE)
		H.hairstyle =  "Messy (Rogue)"
	else
		H.hairstyle = "Messy"
		H.facial_hairstyle = "Beard (Manly)"
	//skill Stuff
	H.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/whipsflails, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	H.STASTR = rand(12,14)
	H.STASPD = 11
	H.STACON = rand(11,13)
	H.STAWIL = 13
	H.STAPER = 11
	H.STAINT = 10
	//Chest Gear
	cloak = /obj/item/clothing/cloak/raincloak/mageblue
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord/heavy
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	//Head Gear
	mask = /obj/item/clothing/head/roguetown/roguehood/mageblue
	neck = /obj/item/clothing/neck/roguetown/leather
	add_random_reiver_helmet(H)
	//wrist Gear
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/jackchain
	//Lower Gear
	belt = /obj/item/storage/belt/rogue/leather
	pants = /obj/item/clothing/under/roguetown/brigandinelegs
	shoes = /obj/item/clothing/shoes/roguetown/ridingboots
	//Weapons
	r_hand = /obj/item/rogueweapon/spear/short
	l_hand = /obj/item/rogueweapon/shield/wood
