/datum/crafting_stage

	var/icon_state = ""
	

	var/description = ""
	

	var/datum/crafting_recipe/recipe


/obj/structure/multistage
	name = "unfinished structure"
	desc = "A skeleton of a structure in progress."
	icon = 'icons/obj/structures.dmi'
	icon_state = "state0"
	anchored = TRUE
	density = TRUE
	max_integrity = 300

	
	var/stage = 1

	
	var/list/stage_types = list()

	
	var/list/stages_cache

	
	var/final_product_type

	var/base_desc = "An unfinished structure. It is missing a few key components."

/obj/structure/multistage/Initialize()
	. = ..()
	stages_cache = list()
	for(var/S in stage_types)
		stages_cache += new S()
	
	update_stage_appearance()

/obj/structure/multistage/Destroy()
	QDEL_LIST(stages_cache)
	return ..()

/obj/structure/multistage/proc/update_stage_appearance()
	if(stage <= length(stages_cache))
		var/datum/crafting_stage/S = stages_cache[stage]
		icon_state = S.icon_state
		desc = "[base_desc] [S.description]"
	else
		desc = base_desc

/obj/structure/multistage/attackby(obj/item/I, mob/living/carbon/user)
	if(try_progress_stage(user, I))
		return
	return ..()

/obj/structure/multistage/proc/try_progress_stage(mob/living/carbon/user, obj/item/tool)
	if(user.doing)
		return FALSE
	
	
	var/datum/component/personal_crafting/PC = user.craftingthing
	if(!PC)
		return FALSE

	if(stage > length(stages_cache))
		finish_construction(user)
		return TRUE

	var/datum/crafting_stage/current_stage_datum = stages_cache[stage]
	var/recipe_type = current_stage_datum.recipe
	
	
	var/datum/crafting_recipe/R = new recipe_type()

	
	var/list/surroundings = PC.get_surroundings(user)


	if(!PC.check_contents(R, surroundings))
		if(tool && PC.check_tools(user, R, surroundings))
			to_chat(user, span_warning("You are missing materials to continue construction."))
		return FALSE

	
	if(!PC.check_tools(user, R, surroundings))
		if(tool && PC.check_contents(R, surroundings))
			to_chat(user, span_warning("You need a specific tool to continue."))
		return FALSE

	
	user.visible_message(span_notice("[user] starts working on [src]..."), span_notice("You start working on [src]..."))
	
	if(R.craftsound)
		playsound(src, R.craftsound, 50, TRUE)

	if(do_after(user, 30, target = src))
		
		surroundings = PC.get_surroundings(user)
		if(!PC.check_contents(R, surroundings) || !PC.check_tools(user, R, surroundings))
			to_chat(user, span_warning("Conditions changed, construction failed."))
			return FALSE

	
		PC.del_reqs(R, user)
		
		
		if(user.mind && R.skillcraft && R.craftdiff)
			
			user.mind.add_sleep_experience(R.skillcraft, R.craftdiff * 10, FALSE)

		
		stage++
		user.visible_message(span_notice("[user] completes a stage of [src]."), span_notice("You complete a stage."))
		
		if(stage > length(stages_cache))
			finish_construction(user)
		else
			update_stage_appearance()
		
		return TRUE

	return FALSE

/obj/structure/multistage/proc/finish_construction(mob/user)
	if(final_product_type)
		new final_product_type(loc)
		qdel(src)
