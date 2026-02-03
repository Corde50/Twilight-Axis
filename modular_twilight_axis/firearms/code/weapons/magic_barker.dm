#define TOPER_CAST_TIME_REDUCTION 0.05
#define EMERALD_CAST_TIME_REDUCTION 0.10
#define SAPPHIRE_CAST_TIME_REDUCTION 0.15
#define RUBY_CAST_TIME_REDUCTION 0.25

/obj/item/gun/ballistic/twilight_firearm/barker/barker_staff
	var/cast_time_reduction = null
	light_system = MOVABLE_LIGHT
	light_outer_range = 2
	light_power = 1
	light_color = "#f5a885"
	possible_item_intents = list(/datum/intent/mace/strike/wood, /datum/intent/special/magicarc)

/obj/item/gun/ballistic/twilight_firearm/barker/barker_staff/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -7,"sy" = 6,"nx" = 7,"ny" = 6,"wx" = -2,"wy" = 3,"ex" = 1,"ey" = 3,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -43,"sturn" = 43,"wturn" = 30,"eturn" = -30, "nflip" = 0, "sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 5,"sy" = -2,"nx" = -5,"ny" = -1,"wx" = -8,"wy" = 2,"ex" = 8,"ey" = 2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 1,"nturn" = -45,"sturn" = 45,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.5,"sx" = -1,"sy" = 2,"nx" = 0,"ny" = 2,"wx" = 2,"wy" = 1,"ex" = 0,"ey" = 1,"nturn" = 0,"sturn" = 0,"wturn" = -15,"eturn" = -70,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 6,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)

/obj/item/gun/ballistic/twilight_firearm/barker/barker_staff/examine(mob/user)
	.=..()
	if(cast_time_reduction)
		. += span_notice("This weapon has been augmented with a gem, reducing a mage's spell casting time by [cast_time_reduction * 100]% when they hold it in their hand.")
	else
		return

/obj/item/gun/ballistic/twilight_firearm/barker/barker_staff/toper
	name = "toper focused barker"
	desc = "An amber focus-gem hewn by pressure immense sits nestled in metal of this weapon."
	icon = 'modular_twilight_axis/firearms/icons/magic/barker_toper.dmi'
	icon_state = "barker_toper"
	item_state = "barker_toper"
	cast_time_reduction = TOPER_CAST_TIME_REDUCTION

/obj/item/gun/ballistic/twilight_firearm/barker/barker_staff/gemerald
	name = "gemerald focused barker"
	desc = "An amber focus-gem hewn by pressure immense sits nestled in metal of this weapon."
	icon = 'modular_twilight_axis/firearms/icons/magic/barker_gemerald.dmi'
	icon_state = "barker_gemerald"
	item_state = "barker_gemerald"
	cast_time_reduction = EMERALD_CAST_TIME_REDUCTION

/obj/item/gun/ballistic/twilight_firearm/barker/barker_staff/sapphire
	name = "sapphire focused barker"
	desc = "An amber focus-gem hewn by pressure immense sits nestled in metal of this weapon."
	icon = 'modular_twilight_axis/firearms/icons/magic/barker_sapphire.dmi'
	icon_state = "barker_sapphire"
	item_state = "barker_sapphire"
	cast_time_reduction = SAPPHIRE_CAST_TIME_REDUCTION

/obj/item/gun/ballistic/twilight_firearm/barker/barker_staff/rontz
	name = "rontz focused barker"
	desc = "An amber focus-gem hewn by pressure immense sits nestled in metal of this weapon."
	icon = 'modular_twilight_axis/firearms/icons/magic/barker_rontz.dmi'
	icon_state = "barker_rontz"
	item_state = "barker_rontz"
	cast_time_reduction = RUBY_CAST_TIME_REDUCTION

/datum/crafting_recipe/gemsbarker/rontz
	name = "rontz focused barker"
	result = /obj/item/gun/ballistic/twilight_firearm/barker/barker_staff/rontz
	reqs = list(/obj/item/gun/ballistic/twilight_firearm/barker = 1,
				/obj/item/magic/manacrystal = 1,
				/obj/item/candle = 3,
				/obj/item/roguegem/ruby = 1)
	craftdiff = 0

/datum/crafting_recipe/gemsbarker/gemerald
	name = "gemerald focused barker"
	result = /obj/item/gun/ballistic/twilight_firearm/barker/barker_staff/gemerald
	reqs = list(/obj/item/gun/ballistic/twilight_firearm/barker = 1,
				/obj/item/magic/manacrystal = 1,
				/obj/item/candle = 3,
				/obj/item/roguegem/green = 1)
	craftdiff = 0

/datum/crafting_recipe/gemsbarker/sapphire
	name = "sapphire focused barker"
	result = /obj/item/gun/ballistic/twilight_firearm/barker/barker_staff/sapphire
	reqs = list(/obj/item/gun/ballistic/twilight_firearm/barker = 1,
				/obj/item/magic/manacrystal = 1,
				/obj/item/candle = 3,
				/obj/item/roguegem/violet = 1)
	craftdiff = 0

/datum/crafting_recipe/gemsbarker/toper
	name = "toper focused barker"
	result = /obj/item/gun/ballistic/twilight_firearm/barker/barker_staff/toper
	reqs = list(/obj/item/gun/ballistic/twilight_firearm/barker = 1,
				/obj/item/magic/manacrystal = 1,
				/obj/item/candle = 3,
				/obj/item/roguegem/yellow = 1)
	craftdiff = 0
