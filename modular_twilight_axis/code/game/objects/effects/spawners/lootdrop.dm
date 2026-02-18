/obj/effect/spawner/lootdrop/proc/do_spawn()
	if(prob(probby))
		if(!spawned)
			return
		var/obj/new_type = pick(spawned)
		new new_type(get_turf(src))
