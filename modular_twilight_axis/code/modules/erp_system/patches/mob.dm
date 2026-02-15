/mob/living/carbon/human
	var/datum/weakref/sex_surrender_ref

/mob/living/proc/get_erp_organs()
	var/list/L = list()

	var/mob/living/carbon/human/H = src
	if(!istype(H))
		return L

	for(var/obj/item/organ/O in H.internal_organs)
		if(O.sex_organ)
			L += O.sex_organ

	for(var/obj/item/bodypart/B in H.bodyparts)
		if(B.sex_organ)
			L += B.sex_organ

	return L

/mob/living/proc/get_erp_organ(type)
	for(var/datum/erp_sex_organ/O in get_erp_organs())
		if(O.type == type)
			return O
	return null

/mob/living/carbon/human/proc/is_lamia_taur()
	if(!islist(bodyparts) || !bodyparts.len)
		return FALSE

	for(var/obj/item/bodypart/taur/lamia/L in bodyparts)
		if(!QDELETED(L))
			return TRUE

	return FALSE

/mob/living/carbon/human/proc/is_physically_restrained(node_flags)
	if(handcuffed || legcuffed)
		return TRUE

	if(node_flags & SEX_ORGAN_MOUTH)
		if(is_mouth_covered())
			return TRUE

	if(node_flags & SEX_ORGAN_HANDS)
		if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
			return TRUE

		var/L = get_item_for_held_index(LEFT_HANDS)
		var/R = get_item_for_held_index(RIGHT_HANDS)

		if((L && !is_sex_toy(L)) && (R && !is_sex_toy(R)))
			return TRUE

	if(node_flags & SEX_ORGAN_LEGS)
		if(legcuffed)
			return TRUE

	return FALSE

/mob/living/carbon/human/proc/get_worn_kink_tags()
	var/list/out = list()
	for(var/obj/item/I in get_equipped_items())
		if(!istype(I, /obj/item/clothing))
			continue
		var/obj/item/clothing/C = I
		var/list/L = C.get_propagade_kinks()
		if(!L || !L.len)
			continue
		for(var/k in L)
			out[k] = TRUE
	return out

/mob/living/carbon/human/proc/is_dullahan_head_partner()
	return FALSE

/mob/living/carbon/human/proc/is_erp_blocked_as_target()
	if(is_erp_defiant_in_combat())
		return TRUE

	if(has_erp_leprosy())
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/is_erp_defiant_in_combat()
	return defiant && cmode

/mob/living/carbon/human/proc/is_erp_defiant()
	return defiant && client.prefs.sexable

/mob/living/carbon/human/proc/has_erp_leprosy()
	if(HAS_TRAIT(src, TRAIT_LEPROSY))
		return TRUE

	return FALSE

/mob/living/proc/start_erp_session(mob/living/target)
	if(!ishuman(src) || !ishuman(target))
		return

	var/mob/living/carbon/human/Hsrc = src
	var/mob/living/carbon/human/Htgt = target

	if(Hsrc.is_erp_blocked_as_target() || Htgt.is_erp_blocked_as_target())
		return

	var/datum/erp_controller/C = SSerp.get_or_create_controller(Hsrc.client, Hsrc, Hsrc)
	C.add_partner_atom(Htgt)
	C.open_ui()

	return C

/mob/living/proc/start_erp_session_atom(atom/target_atom)
	if(!target_atom || QDELETED(target_atom))
		return
	if(!ishuman(src))
		return

	var/mob/living/carbon/human/consent_target = SSerp.get_consent_mob_for_target(target_atom)
	if(!consent_target || !ishuman(consent_target))
		return

	var/mob/living/carbon/human/Hsrc = src
	var/mob/living/carbon/human/Htgt = consent_target
	if(Hsrc.is_erp_blocked_as_target() || Htgt.is_erp_blocked_as_target())
		return

	var/datum/erp_controller/C = SSerp.get_or_create_controller(Hsrc.client, Hsrc, Hsrc)
	C.add_partner_atom(target_atom)
	C.open_ui()
	return C

/mob/living/carbon/human/MiddleMouseDrop_T(atom/movable/dragged, mob/living/user)
	var/mob/living/carbon/human/target = src
	var/mob/living/carbon/human/human_user = user

	if(!istype(human_user))
		return
	if(user.mmb_intent)
		return ..()
	if(!istype(dragged))
		return

	var/is_head = istype(dragged, /obj/item/bodypart/head/dullahan)
	if(dragged != user && !is_head)
		return

	if(!human_user.can_do_sex)
		to_chat(user, "<span class='warning'>I can't do this.</span>")
		return

	var/may_bang = client && client.prefs && client.prefs.sexable == TRUE
	#ifdef LOCALTEST
		may_bang = TRUE
	#endif

	if(!may_bang)
		to_chat(user, "<span class='warning'>[src] dosn't wish to be touched.</span>")
		to_chat(src, "<span class='warning'>[user] failed to touch you.</span>")
		return

	var/atom/initiator = is_head ? dragged : user
	var/datum/erp_controller/C = SSerp.get_or_create_controller(initiator, human_user.client, human_user)
	C.add_partner_atom(target)
	C.open_ui()
	return C

/mob/living/simple_animal/MiddleMouseDrop_T(atom/movable/dragged, mob/living/user)
	var/mob/living/carbon/human/target = src
	var/mob/living/carbon/human/human_user = user

	if(!istype(human_user))
		return
	if(user.mmb_intent)
		return ..()
	if(!istype(dragged))
		return

	var/is_head = istype(dragged, /obj/item/bodypart/head/dullahan)
	if(dragged != user && !is_head)
		return

	if(!human_user.can_do_sex)
		to_chat(user, "<span class='warning'>I can't do this.</span>")
		return

	var/may_bang = client && client.prefs && client.prefs.sexable == TRUE
	#ifdef LOCALTEST
		may_bang = TRUE
	#endif

	if(!may_bang)
		to_chat(user, "<span class='warning'>[src] dosn't wish to be touched.</span>")
		to_chat(src, "<span class='warning'>[user] failed to touch you.</span>")
		return

	var/atom/initiator = is_head ? dragged : user
	var/datum/erp_controller/C = SSerp.get_or_create_controller(initiator, human_user.client, human_user)
	C.add_partner_atom(target)
	C.open_ui()
	return C

/mob/living/carbon/human/proc/set_sex_surrender_to(mob/living/carbon/human/mob_object)
	if(mob_object)
		sex_surrender_ref = WEAKREF(mob_object)
	else
		sex_surrender_ref = null

/mob/living/carbon/human/proc/is_surrendering_to(mob/living/carbon/human/mob_object)
	if(!mob_object || !sex_surrender_ref)
		return FALSE

	var/mob/living/carbon/human/target = sex_surrender_ref.resolve()
	if(!target || QDELETED(target))
		sex_surrender_ref = null
		return FALSE

	return target == mob_object

/mob/living/carbon/human/grippedby(mob/living/carbon/user, instant = FALSE)
	if(is_surrendering_to(user))
		instant = TRUE
		var/old_surrendering = surrendering
		surrendering = TRUE

		. = ..()

		surrendering = old_surrendering
		return .

	. = ..()
	return .

/mob/living/carbon/human/Login()
	. = ..()
	client?.prefs?.apply_erp_kinks_to_mob(src)
	SSerp.apply_prefs_for_mob(src)

/obj/item/bodypart/head/dullahan/MiddleMouseDrop_T(atom/movable/dragged, mob/living/user)
	var/mob/living/carbon/human/consent_target = src.original_owner
	if(user.mmb_intent)
		return ..()

	if(!istype(dragged))
		return
	if(dragged != user)
		return

	if(!user.can_do_sex())
		to_chat(user, "<span class='warning'>I can't do this.</span>")
		return
	if(!user.client?.prefs?.sexable)
		to_chat(user, "<span class='warning'>I don't want to touch [consent_target]. (Your ERP preference, in the options)</span>")
		return
	if(!consent_target?.client || !consent_target.client.prefs)
		to_chat(user, span_warning("[consent_target] is simply not there. I can't do this."))
		log_combat(user, consent_target, "tried ERP menu against d/ced")
		return
	if(!consent_target.client.prefs.sexable)
		to_chat(user, "<span class='warning'>[consent_target] doesn't want to be touched. (Their ERP preference, in the options)</span>")
		to_chat(consent_target, "<span class='warning'>[user] failed to touch you. (Your ERP preference, in the options)</span>")
		log_combat(user, consent_target, "tried unwanted ERP menu against")
		return

	var/client/C = user.client
	if(!C)
		return

	var/datum/erp_controller/EC = SSerp.get_or_create_controller(user, C, user)
	EC.add_partner_atom(src)
	EC.open_ui(user)
	return EC

/obj/item/bodypart/head/dullahan/drop_limb(special)
	var/mob/living/carbon/human/user = original_owner
	var/datum/species/dullahan/user_species = user.dna.species

	user_species.soul_light_on(user)
	user_species.headless = TRUE
	SEND_SIGNAL(user, COMSIG_ERP_ANATOMY_CHANGED)
	
	grabbedby = SANITIZE_LIST(grabbedby)
	if(grabbedby)
		for(var/obj/item/grabbing/grab in grabbedby)
			if(grab.grab_state != GRAB_AGGRESSIVE)
				continue

			var/mob/living/carbon/human = grab.grabbee
			var/hand_index = human.get_held_index_of_item(grab)
			human.dropItemToGround(grab)

			if(!special)
				insert_worn_items()

			. = ..()

			human.put_in_hand(src, hand_index)
			grabbedby.Cut()
			return

		grabbedby.Cut()

	if(!special)
		insert_worn_items()

	. = ..()

/obj/item/bodypart/head/dullahan/attach_limb(mob/living/carbon/human/user)
	var/mob/living/carbon/human/user_dullahan = original_owner ? original_owner : user
	var/datum/species/dullahan/user_species = user_dullahan.dna.species
	user_species.soul_light_off()
	user_species.headless = FALSE
	SEND_SIGNAL(user, COMSIG_ERP_ANATOMY_CHANGED)
	for(var/item_slot in head_items)
		var/obj/item/worn_item = head_items[item_slot]
		if(worn_item)
			user_dullahan.equip_to_slot(worn_item, text2num(item_slot))
	head_items = list()
	return ..()

/datum/species/gnoll/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.icon_state = "firepelt"
	C.base_pixel_x = -8
	C.pixel_x = -8
	C.base_pixel_y = -4
	C.pixel_y = -4

	var/mob/living/carbon/human/H = C
	if(istype(H))
		var/datum/preferences/P = H.client?.prefs
		if(P)
			P.validate_customizer_entries()
			P.apply_customizer_organs_to_mob(H)

		SEND_SIGNAL(H, COMSIG_ERP_ANATOMY_CHANGED)

/mob/living/carbon/human/species/wildshape
	var/added_penis = FALSE
	var/added_testicles = FALSE
	var/added_breasts = FALSE
	var/added_vagina = FALSE

/mob/living/carbon/human/species/wildshape/proc/ensure_form_sex_organs_from_original(mob/living/carbon/human/original)
	if(!original)
		return

	if(ispath(internal_organs_slot?[ORGAN_SLOT_PENIS]))
		internal_organs_slot[ORGAN_SLOT_PENIS] = null
	if(ispath(internal_organs_slot?[ORGAN_SLOT_TESTICLES]))
		internal_organs_slot[ORGAN_SLOT_TESTICLES] = null
	if(ispath(internal_organs_slot?[ORGAN_SLOT_BREASTS]))
		internal_organs_slot[ORGAN_SLOT_BREASTS] = null
	if(ispath(internal_organs_slot?[ORGAN_SLOT_VAGINA]))
		internal_organs_slot[ORGAN_SLOT_VAGINA] = null

	if(original.getorganslot(ORGAN_SLOT_TESTICLES) && !getorganslot(ORGAN_SLOT_TESTICLES))
		var/obj/item/organ/testicles/T = new
		T.Insert(src, TRUE, FALSE)
		added_testicles = TRUE

	if(original.getorganslot(ORGAN_SLOT_PENIS) && !getorganslot(ORGAN_SLOT_PENIS))
		var/obj/item/organ/penis/knotted/big/P = new
		P.Insert(src, TRUE, FALSE)
		added_penis = TRUE

	if(original.getorganslot(ORGAN_SLOT_BREASTS) && !getorganslot(ORGAN_SLOT_BREASTS))
		var/obj/item/organ/breasts/B = new
		B.Insert(src, TRUE, FALSE)
		added_breasts = TRUE

	if(original.getorganslot(ORGAN_SLOT_VAGINA) && !getorganslot(ORGAN_SLOT_VAGINA))
		var/obj/item/organ/vagina/V = new
		V.Insert(src, TRUE, FALSE)
		added_vagina = TRUE

	SEND_SIGNAL(src, COMSIG_ERP_ANATOMY_CHANGED)

/mob/living/carbon/human/species/wildshape/proc/remove_form_sex_organs()
	if(added_penis)
		var/obj/item/organ/penis/P = getorganslot(ORGAN_SLOT_PENIS)
		if(P)
			P.Remove(src)
			qdel(P)
		added_penis = FALSE

	if(added_testicles)
		var/obj/item/organ/testicles/T = getorganslot(ORGAN_SLOT_TESTICLES)
		if(T)
			T.Remove(src)
			qdel(T)
		added_testicles = FALSE

	if(added_breasts)
		var/obj/item/organ/breasts/B = getorganslot(ORGAN_SLOT_BREASTS)
		if(B)
			B.Remove(src)
			qdel(B)
		added_breasts = FALSE

	if(added_vagina)
		var/obj/item/organ/vagina/V = getorganslot(ORGAN_SLOT_VAGINA)
		if(V)
			V.Remove(src)
			qdel(V)
		added_vagina = FALSE

	SEND_SIGNAL(src, COMSIG_ERP_ANATOMY_CHANGED)

/mob/living/carbon/human/proc/mirror_set_nudeshot_url()
	var/url = input(src, "Paste a direct image URL (http/https).", "Nude Shot URL") as null|text
	if(!url)
		return FALSE

	url = trimtext(url)
	if(length(url) > 512)
		to_chat(src, span_warning("That link is too long."))
		return FALSE

	var/lower = lowertext(url)
	if(!(findtext(lower, "http://") == 1 || findtext(lower, "https://") == 1))
		to_chat(src, span_warning("Only http/https links are allowed."))
		return FALSE

	nsfw_headshot_link = url
	update_body()
	update_body_parts()

	to_chat(src, span_notice("Your reflection settles into a new… compromising portrait."))
	return TRUE
