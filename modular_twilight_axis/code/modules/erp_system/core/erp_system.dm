SUBSYSTEM_DEF(erp)
	name = "ERP System"
	wait = 1 SECONDS
	priority = FIRE_PRIORITY_DEFAULT

	var/list/datum/erp_action/actions = list()
	var/list/datum/erp_sex_organ/organs = list()
	var/list/datum/erp_controller/controllers = list()

/datum/controller/subsystem/erp/Initialize(timeofday)
	. = ..()

	actions = list()

	for(var/path in subtypesof(/datum/erp_action))
		var/datum/erp_action/A = new path
		if(A.abstract)
			qdel(A)
			continue
			
		if(!A.id)
			A.id = "[path]"

		actions[path] = A

/datum/controller/subsystem/erp/proc/register_organ(datum/erp_sex_organ/O)
	if(O && !(O in organs))
		organs += O

/datum/controller/subsystem/erp/proc/unregister_organ(datum/erp_sex_organ/O)
	organs -= O

/datum/controller/subsystem/erp/fire(resumed)
	for(var/i = organs.len; i >= 1; i--)
		var/datum/erp_sex_organ/O = organs[i]
		if(!O || QDELETED(O))
			organs.Cut(i, i+1)
			continue
		O.process(1.0)

	for(var/datum/erp_controller/C in controllers)
		C.process_links()

/datum/controller/subsystem/erp/proc/register_controller(datum/erp_controller/C)
	if(C && !(C in controllers))
		controllers += C

/datum/controller/subsystem/erp/proc/unregister_controller(datum/erp_controller/C)
	controllers -= C

/datum/controller/subsystem/erp/proc/get_action(action_type)
	if(!action_type)
		return null

	var/path = action_type
	if(istext(path))
		path = text2path(path)

	return actions[path]

/datum/controller/subsystem/erp/proc/get_controller_for(atom/initiator_atom)
	if(!initiator_atom)
		return null

	for(var/datum/erp_controller/EC in controllers)
		if(!EC || QDELETED(EC))
			continue
		if(EC.owner?.active_actor == initiator_atom)
			return EC

	return null

/datum/controller/subsystem/erp/proc/create_controller(atom/initiator_atom, client/C, mob/living/effect_mob = null)
	if(!initiator_atom || QDELETED(initiator_atom) || !C)
		return null

	var/datum/erp_controller/EC = new(initiator_atom, C, effect_mob)
	return EC

/datum/controller/subsystem/erp/proc/get_or_create_controller(atom/initiator_atom, client/C, mob/living/effect_mob = null)
	var/datum/erp_controller/EC = get_controller_for(initiator_atom)
	if(!EC)
		EC = create_controller(initiator_atom, C, effect_mob)
	return EC

/datum/controller/subsystem/erp/proc/get_organ_type_options_ui()
	return list(
		list("value"=SEX_ORGAN_PENIS, "name"="Член"),
		list("value"=SEX_ORGAN_HANDS, "name"="Руки"),
		list("value"=SEX_ORGAN_LEGS, "name"="Ноги"),
		list("value"=SEX_ORGAN_TAIL, "name"="Хвост"),
		list("value"=SEX_ORGAN_BODY, "name"="Тело"),
		list("value"=SEX_ORGAN_MOUTH, "name"="Рот"),
		list("value"=SEX_ORGAN_ANUS, "name"="Анус"),
		list("value"=SEX_ORGAN_BREASTS, "name"="Грудь"),
		list("value"=SEX_ORGAN_VAGINA, "name"="Вагина"),
	)

/datum/controller/subsystem/erp/proc/apply_prefs_for_mob(mob/living/M)
	if(!M || !M.client?.prefs)
		return

	for(var/datum/erp_sex_organ/O in organs)
		if(!O || QDELETED(O))
			continue
		if(O.get_owner() == M)
			O.apply_prefs_if_possible()

/datum/controller/subsystem/erp/proc/create_actor(atom/A, client/C = null, mob/living/effect_mob = null)
	if(!A || QDELETED(A))
		return null

	if(istype(A, /obj/item/bodypart/head/dullahan))
		var/obj/item/bodypart/head/dullahan/HD = A
		var/mob/living/effect = effect_mob
		if(!effect && HD.original_owner && ismob(HD.original_owner))
			effect = HD.original_owner

		var/datum/erp_actor/erp_object/dullahan_head/Act = new(A, null, effect)
		if(C)
			Act.attach_client(C)
		Act.post_init()
		return Act

	if(ishuman(A))
		var/datum/erp_actor/human/HAct = new(A)
		if(C)
			HAct.attach_client(C)
		HAct.post_init()
		return HAct

	if(ismob(A))
		var/datum/erp_actor/mob/MAct = new(A)
		if(C)
			MAct.attach_client(C)
		MAct.post_init()
		return MAct

	return null

/datum/controller/subsystem/erp/proc/get_consent_mob_for_target(atom/target_atom)
	if(!target_atom || QDELETED(target_atom))
		return null

	if(ishuman(target_atom))
		return target_atom

	if(istype(target_atom, /obj/item/bodypart/head/dullahan))
		var/obj/item/bodypart/head/dullahan/H = target_atom
		if(H.original_owner && ishuman(H.original_owner))
			return H.original_owner

	return null
