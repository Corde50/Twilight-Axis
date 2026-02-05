#define MAX_SHIELD_HP 1000

/obj/effect/proc_holder/spell/self/magic_shield
	name = "Acrane Shield"
	desc = "Creates a temporary magical barrier that reflects projectiles flying at you back at the shooter."
	cost = 6
	xp_gain = TRUE
	releasedrain = 50
	chargedrain = 1
	chargetime = 3
	recharge_time = 1 MINUTES
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	action_icon = 'modular_twilight_axis/icons/mob/actions/roguespells.dmi'
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "shield"
	spell_tier = 3
	invocations = list("Submergi!")
	invocation_type = "shout"
	glow_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_HIGH
	gesture_required = TRUE
	sound = 'sound/magic/repulse.ogg'
	var/image/shield_overlay_image
	var/shield_hp = 0

/obj/effect/proc_holder/spell/self/magic_shield/Initialize()
	. = ..()
	shield_overlay_image = image(icon = 'icons/effects/effects.dmi', icon_state = "shield-grey")

/obj/effect/proc_holder/spell/self/magic_shield/proc/end_reflection_effect(mob/living/target)
	if(!target)
		return
	
	if(shield_hp <= 0)
		playsound(target.loc, 'sound/spellbooks/glass.ogg', 50, 1)
		to_chat(target, "<span class='danger'>The mirror shield around you shatters!</span>")
	else
		playsound(target.loc, 'sound/spellbooks/glass.ogg', 50, 1)
		to_chat(target, "<span class='notice'>The mirror shield around you disappears.</span>")
	
	target.cut_overlay(shield_overlay_image)

	if(HAS_TRAIT(target, TRAIT_MAGIC_SHIELD))
		REMOVE_TRAIT(target, TRAIT_MAGIC_SHIELD, src)

/obj/effect/proc_holder/spell/self/magic_shield/cast(mob/living/user = usr)
	var/duration = 30 SECONDS

	if(HAS_TRAIT(user, TRAIT_MAGIC_SHIELD))
		to_chat(user, "<span class='warning'>You are already experiencing a similar effect!</span>")
		return

	shield_hp = MAX_SHIELD_HP

	playsound(user.loc, 'sound/spellbooks/scrapeblade.ogg', 50, 1)
	user.add_overlay(shield_overlay_image)
	ADD_TRAIT(user, TRAIT_MAGIC_SHIELD, src)
	user.visible_message(
		"<span class='warning'>[user] is covered with a shimmering mirror shield!</span>",
		"<span class='notice'>A mirror barrier appears around you.</span>"
	)
	addtimer(CALLBACK(src, .proc/end_reflection_effect, user), duration)
