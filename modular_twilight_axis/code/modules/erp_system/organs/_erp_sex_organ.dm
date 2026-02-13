/datum/erp_sex_organ
	var/atom/host
	var/erp_organ_type
	var/list/datum/erp_sex_link/links = list()
	var/sensitivity = 1.0
	var/sensitivity_max = SEX_SENSITIVITY_MAX
	var/pain = 0.0
	var/pain_max = SEX_PAIN_MAX
	var/datum/erp_liquid_storage/storage
	var/datum/erp_liquid_storage/producing
	var/last_process_time = 0
	var/process_interval = 1 SECONDS
	var/last_drain_time = 0
	var/drain_interval = 5 MINUTES
	var/count_to_action = 1
	var/last_overflow_spill_time = 0
	var/overflow_spill_interval = 30 SECONDS
	var/active_arousal = 1.0
	var/passive_arousal = 1.0
	var/active_pain = 0.0
	var/passive_pain = 0.0
	var/allow_overflow_spill = FALSE

/datum/erp_sex_organ/New(atom/A)
	. = ..()
	host = A
	last_process_time = world.time
	SSerp.register_organ(src)

/datum/erp_sex_organ/Destroy()
	for(var/datum/erp_sex_link/L in links)
		qdel(L)
	SSerp.unregister_organ(src)
	links = null
	storage = null
	producing = null
	host = null
	. = ..()

/datum/erp_sex_organ/proc/get_production_mult()
	return 0

/datum/erp_sex_organ/process()
	var/mob/living/carbon/H = get_owner()
	if(istype(H) && H.IsSleeping())
		if(pain > 0)
			pain = 0

	if(producing)
		if(world.time >= last_process_time + process_interval)
			last_process_time = world.time
			process_production()

	if(world.time >= last_drain_time + drain_interval)
		last_drain_time = world.time
		process_drain()

/datum/erp_sex_organ/proc/process_production()
	if(!producing || !producing.producing_reagent || producing.production_rate <= 0)
		return

	var/mult = get_production_mult()
	if(mult <= 0)
		return

	if(producing.total_volume() >= producing.capacity)
		if(allow_overflow_spill && should_spill_now() && can_spill_to_ground())
			var/amount = max(5, round(producing.production_rate * mult))
			amount = min(amount, producing.total_volume())

			if(amount > 0)
				var/datum/reagents/Rspill = producing.inject(amount)
				if(Rspill && Rspill.total_volume > 0)
					drop_to_ground(Rspill)
				else if(Rspill)
					qdel(Rspill)
		return

	var/amount = producing.production_rate * mult
	if(amount <= 0)
		return

	var/datum/reagents/R = new(amount)
	R.add_reagent(producing.producing_reagent, amount, null, 300, no_react = TRUE)
	producing.receive(R, amount, no_react = TRUE)

	R.clear_reagents()
	qdel(R)


/datum/erp_sex_organ/proc/process_drain()
	if(!storage)
		return
	if(!storage.can_drain || storage.block_drain)
		return
	if(storage.total_volume() <= 0)
		return

	storage.drain(1)

/datum/erp_sex_organ/proc/receive_reagents(datum/reagents/R, amount)
	if(!storage || !R || amount <= 0)
		return 0

	var/overflow = storage.receive(R, amount)

	if(overflow > 0)
		if(allow_overflow_spill && should_spill_now())
			drop_to_ground(R)
		else
			R.clear_reagents()

	return amount - overflow

/datum/erp_sex_organ/proc/extract_reagents(amount)
	if(amount <= 0)
		return null

	var/datum/reagents/R = new(amount)
	var/remaining = amount

	if(producing && producing.total_volume() > 0)
		var/take = min(remaining, producing.total_volume())
		var/datum/reagents/from_prod = producing.inject(take)
		if(from_prod)
			from_prod.trans_to(R, take)
			remaining -= take

	if(remaining > 0 && storage && storage.total_volume() > 0)
		var/take = min(remaining, storage.total_volume())
		var/datum/reagents/from_store = storage.inject(take)
		if(from_store)
			from_store.trans_to(R, take)
			remaining -= take

	if(R.total_volume <= 0)
		qdel(R)
		return null

	return R

/datum/erp_sex_organ/proc/route_reagents(datum/reagents/R, target_mode, target)
	if(!R || R.total_volume <= 0)
		return FALSE

	switch(target_mode)
		if(INJECT_ORGAN)
			var/datum/erp_sex_organ/target_organ = target
			if(target_organ)
				target_organ.receive_reagents(R, R.total_volume)
				return TRUE

		if(INJECT_CONTAINER)
			var/obj/item/reagent_containers/C = target
			if(C && C.reagents)
				R.trans_to(C, R.total_volume, 1, TRUE, TRUE)
				return TRUE

		if(INJECT_GROUND)
			drop_to_ground(R)
			return TRUE

	drop_to_ground(R)
	return TRUE

/datum/erp_sex_organ/proc/drop_to_ground(datum/reagents/R)
	if(!R || R.total_volume <= 0)
		return

	if(!can_spill_to_ground())
		R.clear_reagents()
		return

	var/turf/T = get_turf(get_owner() || host)
	if(!T)
		R.clear_reagents()
		return

	var/obj/effect/decal/cleanable/coom/C = null
	for(var/obj/effect/decal/cleanable/coom/existing in T)
		C = existing
		break

	if(!C)
		C = new /obj/effect/decal/cleanable/coom(T)

	if(!C.reagents)
		C.reagents = new /datum/reagents(C.reagents_capacity)
		C.reagents.my_atom = C

	R.trans_to(C, R.total_volume, 1, TRUE, TRUE)
	R.clear_reagents()

/datum/erp_sex_organ/proc/get_owner()
	if(!host)
		return null

	if(ismob(host))
		return host

	if(istype(host, /obj/item/organ))
		var/obj/item/organ/O = host
		return O.owner

	if(istype(host, /obj/item/bodypart))
		var/obj/item/bodypart/B = host
		return B.owner

	return null

/datum/erp_sex_organ/proc/get_active_link_count()
	var/c = 0
	for(var/datum/erp_sex_link/L in get_active_links())
		if(L.state != LINK_STATE_ACTIVE)
			continue
		if(L.init_organ == src)
			c++
	return c

/datum/erp_sex_organ/proc/get_total_slots()
	return max(1, count_to_action)

/datum/erp_sex_organ/proc/get_free_slots()
	return max(0, max(1, count_to_action) - get_active_link_count())

/datum/erp_sex_organ/proc/is_busy()
	return get_free_slots() <= 0

/datum/erp_sex_organ/proc/get_active_links()
	var/list/out = list()
	for(var/datum/erp_sex_link/L in links)
		if(L.init_organ == src)
			out += L
	return out

/datum/erp_sex_organ/proc/get_passive_links()
	var/list/out = list()
	for(var/datum/erp_sex_link/L in links)
		if(L.target_organ == src)
			out += L
	return out

/obj/item/organ
	var/datum/erp_sex_organ/sex_organ

/obj/item/organ/Destroy()
	if(sex_organ)
		qdel(sex_organ)
		sex_organ = null
	return ..()

/obj/item/bodypart
	var/datum/erp_sex_organ/sex_organ

/obj/item/bodypart/Destroy()
	if(sex_organ)
		qdel(sex_organ)
		sex_organ = null
	return ..()

/datum/erp_sex_organ/proc/has_liquid_system()
	if(storage && storage.capacity > 0)
		return TRUE
	if(producing && producing.capacity > 0)
		return TRUE
	return FALSE

/datum/erp_sex_organ/proc/apply_prefs_if_possible()
	var/mob/living/M = null
	if(ismob(host))
		M = host
	if(!M)
		M = get_owner()
	if(!M)
		return

	var/client/C = M.client
	if(!C || !C.prefs)
		return

	var/datum/preferences/P = C.prefs
	if(!islist(P.erp_organ_prefs))
		return

	var/list/prefs = P.erp_organ_prefs["[erp_organ_type]"]
	if(!islist(prefs))
		return

	if("sensitivity" in prefs)
		sensitivity = clamp(prefs["sensitivity"], 0, sensitivity_max)

	if("overflow" in prefs)
		allow_overflow_spill = !!prefs["overflow"]

/datum/erp_sex_organ/proc/should_spill_now()
	if(world.time < last_overflow_spill_time + overflow_spill_interval)
		return FALSE
	last_overflow_spill_time = world.time
	return TRUE

/datum/erp_sex_organ/proc/_organ_type_to_zone()
	switch(erp_organ_type)
		if(SEX_ORGAN_PENIS, SEX_ORGAN_VAGINA, SEX_ORGAN_ANUS)
			return BODY_ZONE_PRECISE_GROIN
		if(SEX_ORGAN_BREASTS)
			return BODY_ZONE_CHEST
		if(SEX_ORGAN_MOUTH)
			return BODY_ZONE_PRECISE_MOUTH
	return null

/datum/erp_sex_organ/proc/can_spill_to_ground()
	var/mob/living/carbon/H = get_owner()
	if(!istype(H))
		return FALSE

	var/zone = _organ_type_to_zone()
	if(!zone)
		return TRUE

	return get_location_accessible(H, zone)
