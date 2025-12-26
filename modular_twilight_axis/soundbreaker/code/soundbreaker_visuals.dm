/obj/effect/temp_visual/soundbreaker_afterimage
	name = "afterimage"
	randomdir = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

	duration = 30
	fade_time = 5

	layer = ABOVE_MOB_LAYER - 0.1

/obj/effect/temp_visual/soundbreaker_afterimage/Initialize(mapload, mob/living/source, custom_dur, custom_fade)
	if(custom_dur)
		duration = custom_dur
	if(custom_fade)
		fade_time = custom_fade

	. = ..()

	if(!source)
		return INITIALIZE_HINT_QDEL

	plane = source.plane
	layer = source.layer - 0.05

	appearance = source.appearance
	setDir(source.dir)
	alpha = 160
	add_atom_colour("#44aaff", TEMPORARY_COLOUR_PRIORITY)

/obj/effect/temp_visual/soundbreaker_fx
	name = "soundbreaker fx"
	icon = SOUNDBREAKER_FX_ICON
	randomdir = FALSE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER
	plane = ABOVE_LIGHTING_PLANE

	duration = 4
	fade_time = 2

/obj/effect/temp_visual/soundbreaker_fx/eq_pillars
	icon_state = SB_FX_EQS
	duration = 4
	fade_time = 2

/obj/effect/temp_visual/soundbreaker_fx/wave_forward
	icon_state = SB_FX_WAVE_FORWARD
	duration = 4
	fade_time = 2

/obj/effect/temp_visual/soundbreaker_fx/ring
	icon_state = SB_FX_RING
	icon = SOUNDBREAKER_FX96_ICON
	duration = 4
	fade_time = 2

/obj/effect/temp_visual/soundbreaker_fx/note_shatter
	icon_state = SB_FX_NOTE_SHATTER
	duration = 3
	fade_time = 2

/obj/effect/temp_visual/soundbreaker_fx/riff_single
	icon_state = SB_FX_RIFF_SINGLE
	duration = 3
	fade_time = 2
	layer = ABOVE_MOB_LAYER + 0.1

/obj/effect/temp_visual/soundbreaker_fx/riff_cluster
	icon_state = SB_FX_RIFF_CLUSTER
	duration = 3
	fade_time = 2
	layer = ABOVE_MOB_LAYER + 0.1

/obj/effect/temp_visual/soundbreaker_fx/big_note_maw
	icon_state = SB_FX_PROJ_NOTE
	duration = 9
	fade_time = 3

/proc/sb_fx_eq_pillars(turf/T, dir_to_set)
	if(!T)
		return
	var/obj/effect/temp_visual/soundbreaker_fx/eq_pillars/F = new(T)
	if(dir_to_set)
		F.setDir(dir_to_set)

/proc/sb_fx_wave_forward(turf/T, dir_to_set)
	if(!T)
		return
	var/obj/effect/temp_visual/soundbreaker_fx/wave_forward/F = new(T)
	if(dir_to_set)
		F.setDir(dir_to_set)

/proc/sb_fx_note_shatter(turf/T)
	if(!T)
		return
	new /obj/effect/temp_visual/soundbreaker_fx/note_shatter(T)

/proc/sb_fx_riff_single(atom/A)
	if(!A)
		return
	new /obj/effect/temp_visual/soundbreaker_fx/riff_single(get_turf(A))

/proc/sb_fx_riff_cluster(atom/A)
	if(!A)
		return
	new /obj/effect/temp_visual/soundbreaker_fx/riff_cluster(get_turf(A))

/proc/soundbreaker_spawn_afterimage(mob/living/user, turf/T, dur_ds = 3, fade_ds = 3)
	if(!user || !T)
		return
	new /obj/effect/temp_visual/soundbreaker_afterimage(T, user, dur_ds, fade_ds)

/proc/sb_fire_sound_note(mob/living/user, damage_mult = 0.5, damage_type = BRUTE, zone = BODY_ZONE_CHEST)
	if(!user)
		return
	var/dir = user.dir
	if(!dir)
		dir = SOUTH
	var/turf/start = get_step(user, dir)
	if(!start)
		return
	if(start.density)
		return null	

	var/obj/projectile/soundbreaker_note/P = new(start, user, damage_mult, damage_type, zone)
	P.setDir(user.dir)
	P.fire(angle = user.dir)
