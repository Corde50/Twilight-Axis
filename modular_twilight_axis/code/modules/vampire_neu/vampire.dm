#define THRALLS_METHUSELAH	69
#define THRALLS_ANCILLAE	69
#define THRALLS_NEONATE		10
#define THRALLS_THINBLOOD 	0
#define THRALLS_DEFAULT 	0

/datum/antagonist/vampire/on_gain()
	SSmapping.retainer.vampires |= owner
	//move_to_spawnpoint()
	owner.special_role = name
	owner.current.adjust_bloodpool()
	max_thralls = initial(max_thralls)
	if(ishuman(owner.current))
		var/mob/living/carbon/human/vampdude = owner.current
		vampdude.hud_used?.shutdown_bloodpool()
		vampdude.hud_used?.initialize_bloodpool()
		vampdude.hud_used?.bloodpool.set_fill_color("#510000")

		switch(generation)
			if(GENERATION_METHUSELAH)
				vampdude?.adjust_skillrank_up_to(/datum/skill/magic/blood, 6, TRUE)
				max_thralls = THRALLS_METHUSELAH
			if(GENERATION_ANCILLAE)
				vampdude?.adjust_skillrank_up_to(/datum/skill/magic/blood, 5, TRUE)
				max_thralls = THRALLS_ANCILLAE
			if(GENERATION_NEONATE)
				vampdude?.adjust_skillrank_up_to(/datum/skill/magic/blood, 4, TRUE) // Licker Wretch
				max_thralls = THRALLS_NEONATE
			if(GENERATION_THINBLOOD)
				vampdude?.adjust_skillrank_up_to(/datum/skill/magic/blood, 3, TRUE) // You are not even an antagonist
				max_thralls = THRALLS_THINBLOOD
			else
				vampdude?.adjust_skillrank_up_to(/datum/skill/magic/blood, 2, TRUE) // Default weight if generation not set
				max_thralls = THRALLS_DEFAULT

		if(HAS_TRAIT(vampdude, TRAIT_DNR)) //if you have DNR, we add dustable
			ADD_TRAIT(vampdude, TRAIT_DUSTABLE, TRAIT_GENERIC)

		if(!forced)
			// Show clan selection interface
			if(!clan_selected)
				show_clan_selection(vampdude)
			else
				// Apply the selected clan
				vampdude.set_clan(default_clan)
		else
			vampdude.set_clan_direct(forcing_clan)
			forcing_clan = null


	// The clan system now handles most of the setup, but we can still do antagonist-specific things
	after_gain()
	. = ..()
	equip()

	if(HAS_TRAIT(owner, TRAIT_CRITICAL_RESISTANCE))
		REMOVE_TRAIT(owner, TRAIT_CRITICAL_RESISTANCE, null)

#undef THRALLS_METHUSELAH
#undef THRALLS_ANCILLAE
#undef THRALLS_NEONATE
#undef THRALLS_THINBLOOD
#undef THRALLS_DEFAULT