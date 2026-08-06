/obj/item/gun/ballistic/revolver/grenadelauncher/twilight_runelock/twilight_bloodlock
	name = "bloodlock rifle"
	desc = "Оружие скованное тёмными эльфами, глубоко во тьме Подземий. Заряжается жизненной энергией владельца"
	icon = 'modular_twilight_axis/firearms/icons/bloodlock.dmi'
	icon_state = "bloodlock"
	icon_state_ready = "bloodlock_r"
	default_icon_state = "bloodlock"
	item_state = "bloodlock"
	associated_skill = /datum/skill/combat/staves
	possible_item_intents = list(/datum/intent/mace/strike/wood)
	gripped_intents = list(/datum/intent/shoot/twilight_runelock, /datum/intent/arc/twilight_runelock, INTENT_GENERIC)
	mag_type = /obj/item/ammo_box/magazine/internal/shot/twilight_bloodlock
	pixel_y = -16
	pixel_x = -16
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	experimental_onback = TRUE
	bigboy = TRUE
	wlength = WLENGTH_LONG
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	spread = 10
	var/vitae_cost = 300
	recoil = 3
	force = 10
	force_wielded = 15
	cocked = FALSE
	cartridge_wording = "bullet"
	load_sound = 'modular_twilight_axis/firearms/sound/musketload.ogg'
	fire_sound = 'modular_twilight_axis/firearms/sound/musketfire2.ogg'
	fire_sound_variations = list(
		'modular_twilight_axis/firearms/sound/musketfire2.ogg' = 99.99,
		'modular_twilight_axis/firearms/sound/musketfire11.ogg' = 0.01, //little secret
	)
	vary_fire_sound = TRUE
	fire_sound_volume = 200
	anvilrepair = null
	smeltresult = /obj/item/ingot/steel
	/// Chance for the weapon to misfire
	misfire_chance = 0
	/// Reload time, in SECONDS
	reload_time = 10
	damfactor = 1.2
	critfactor = 1
	npcdamfactor = 4

/obj/item/gun/ballistic/revolver/grenadelauncher/twilight_runelock/twilight_bloodlock/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "GUN")

/obj/item/gun/ballistic/revolver/grenadelauncher/twilight_runelock/twilight_bloodlock/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/obj/item/gun/ballistic/revolver/grenadelauncher/twilight_runelock/twilight_bloodlock/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -7,"sy" = 6,"nx" = 7,"ny" = 6,"wx" = -2,"wy" = 3,"ex" = 1,"ey" = 3,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -43,"sturn" = 43,"wturn" = 30,"eturn" = -30, "nflip" = 0, "sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 5,"sy" = -2,"nx" = -5,"ny" = -1,"wx" = -8,"wy" = 2,"ex" = 8,"ey" = 2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 1,"nturn" = -45,"sturn" = 45,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.5,"sx" = -1,"sy" = 2,"nx" = 0,"ny" = 2,"wx" = 2,"wy" = 1,"ex" = 0,"ey" = 1,"nturn" = 0,"sturn" = 0,"wturn" = 70,"eturn" = 15,"nflip" = 1,"sflip" = 1,"wflip" = 1,"eflip" = 1,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)

/obj/item/gun/ballistic/revolver/grenadelauncher/twilight_runelock/twilight_bloodlock/attack_self(mob/living/user)
	if(twohands_required)
		return
	if(altgripped || wielded) //Trying to unwield it
		ungrip(user)
		return
	if(!cocked)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(HAS_TRAIT(H, TRAIT_ARCYNE) && HAS_TRAIT(H, TRAIT_VAMPBITE))
				if(H.bloodpool < vitae_cost)
					to_chat(H, span_warning("I don't have enough vitae to spare!"))
					return
				to_chat(H, span_info("I ready the bloodlock to be fired..."))
				playsound(src,'modular_twilight_axis/firearms/sound/bloodreload.ogg', 150, FALSE)
				var/adj_reload_time = reload_time
				if(H.mind)
					var/skill = H.get_skill_level(/datum/skill/combat/twilight_firearms)
					if(skill)
						adj_reload_time = reload_time / skill
				if(move_after(H, adj_reload_time SECONDS, target = H))
					H.adjust_bloodpool(-vitae_cost)
					H.update_action_buttons()
					playsound(H, 'modular_twilight_axis/firearms/sound/musketcock.ogg', 100, FALSE)
					cocked = TRUE
			else
				to_chat(H, "<span class='warning'>Я совершенно не понимаю, как этим пользоваться!</span>")
		else
			to_chat(user, "<span class='warning'>Я совершенно не понимаю, как этим пользоваться!</span>")
	else
		if(alt_grips)
			altgrip(user)
		if(gripped_intents)
			wield(user)
	update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/twilight_runelock/twilight_bloodlock/get_special_examine_hint(mob/living/carbon/human/user)
	if(!HAS_TRAIT(user, TRAIT_ARCYNE))
		return

	return span_info("Это оружие оснащено арканным замком — для стрельбы достаточно взвести курок, но зарядить его можно лишь своей кровью и знаниями.")

/obj/item/ammo_box/magazine/internal/shot/twilight_bloodlock
	ammo_type = /obj/item/ammo_casing/caseless/rogue/twilight_lead
	caliber = "lead_sphere"
	max_ammo = 1
	start_empty = TRUE

/datum/intent/shoot/twilight_bloodlock
	chargedrain = 0

/datum/intent/shoot/twilight_bloodlock/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = chargetime
		//skill block
		newtime = newtime + 75
		newtime = newtime - (mastermob.get_skill_level(/datum/skill/combat/twilight_firearms) * 15)
		//per block
		newtime = newtime + 20
		newtime = newtime - ((mastermob.STAPER)*1.5)
		if(newtime > 0)
			return newtime
		else
			return 0.1
	return chargetime

/datum/intent/arc/twilight_bloodlock
	chargetime = 1
	chargedrain = 0

/datum/intent/arc/twilight_bloodlock/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = chargetime
		//skill block
		newtime = newtime + 70
		newtime = newtime - (mastermob.get_skill_level(/datum/skill/combat/twilight_firearms) * 15)
		//per block
		newtime = newtime + 20
		newtime = newtime - ((mastermob.STAPER)*1.5)
		if(newtime > 0)
			return newtime
		else
			return 1
	return chargetime
