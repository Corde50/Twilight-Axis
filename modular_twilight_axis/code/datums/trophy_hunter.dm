/datum/component/trophy_hunter
	var/mob/living/carbon/human/owner
	var/obj/item/storage/hip/headhook/active_hook
	var/list/rules = list()
	var/list/applied_effects = list()

/datum/component/trophy_hunter/Initialize()
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	owner = parent

	rules += new /datum/trophy_rule/troll_armor
	rules += new /datum/trophy_rule/minotaur_strong
	rules += new /datum/trophy_rule/dragon_perception
	rules += new /datum/trophy_rule/aspirant_rage

	RegisterSignal(owner, COMSIG_ITEM_EQUIPPED, PROC_REF(on_item_equipped))
	RegisterSignal(owner, COMSIG_ITEM_DROPPED, PROC_REF(on_item_dropped))

/datum/component/trophy_hunter/proc/on_item_equipped(mob/user, obj/item/I, slot)
	if(!istype(I, /obj/item/storage/hip/headhook))
		return
	if(slot != ITEM_SLOT_HIP)
		return

	set_active_hook(I)
	rebuild_effects()

/datum/component/trophy_hunter/proc/on_item_dropped(mob/user, obj/item/I)
	if(I != active_hook)
		return

	clear_active_hook()
	clear_effects()

/datum/component/trophy_hunter/proc/set_active_hook(obj/item/storage/hip/headhook/H)
	if(active_hook == H)
		return

	clear_active_hook()
	active_hook = H

	RegisterSignal(active_hook, COMSIG_HEADHOOK_CONTENTS_CHANGED, PROC_REF(on_hook_changed))
	RegisterSignal(active_hook, COMSIG_HEADHOOK_UNEQUIPPED, PROC_REF(on_hook_unequipped))

/datum/component/trophy_hunter/proc/clear_active_hook()
	if(!active_hook)
		return

	UnregisterSignal(active_hook, list(
		COMSIG_HEADHOOK_CONTENTS_CHANGED,
		COMSIG_HEADHOOK_UNEQUIPPED
	))

	active_hook = null

/datum/component/trophy_hunter/proc/on_hook_changed()
	rebuild_effects()

/datum/component/trophy_hunter/proc/on_hook_unequipped()
	clear_active_hook()
	clear_effects()

/datum/component/trophy_hunter/proc/rebuild_effects()
	if(!owner)
		return

	clear_effects()

	if(!active_hook)
		return

	var/list/best_effects = list()
	var/list/best_scores = list()

	for(var/obj/item/I in active_hook.contents)
		for(var/datum/trophy_rule/R as anything in rules)
			if(!R.matches(I))
				continue

			var/score = R.get_score(I)
			var/group_id = R.group_id

			if(!(group_id in best_effects) || score > best_scores[group_id])
				best_scores[group_id] = score
				best_effects[group_id] = R.build_effect(I)

			break
	for(var/group_id in best_effects)
		var/datum/trophy_effect/E = best_effects[group_id]
		apply_effect(E)
		applied_effects[group_id] = E

