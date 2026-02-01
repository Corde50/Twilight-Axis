/datum/emote/living/blush
	key_third_person = "краснеет"
	message = "краснеет."
	emote_type = EMOTE_VISIBLE
/mob/living/carbon/human/verb/emote_blush()
	set name = "Blush"
	set category = "Emotes"

	emote("blush", intentional = TRUE)

/datum/emote/living/pray
	key_third_person = "молится"
	message = "прозносит молитву."

/datum/emote/living/meditate
	key_third_person = "медитирует"
	message = "медитирует."

/datum/emote/living/bow
	key_third_person = "кланяется"
	message = "кланяется."
	message_param = "кланяется %t."

/datum/emote/living/burp
	key_third_person = "рыгает"
	message = "рыгает."
	message_muffled = "издает приглушенный звук." //Потом

/datum/emote/living/choke
	key_third_person = "задыхается"
	message = "задыхается!"

/datum/emote/living/cross
	key_third_person = "скрещивает руки"
	message = "скрещивает руки."

/datum/emote/living/collapse
	key_third_person = "теряет сознание"
	message = "теряет сознание."

/datum/emote/living/whisper
	key_third_person = "шепчет"
	message = "шепчет."
	message_mime = "что-то шепчет."

/datum/emote/living/cough
	key_third_person = "кашляет"
	message = "кашляет."

/datum/emote/living/clearthroat
	key = "clearthroat"
	key_third_person = "прочищает горло"
	message = "прочищает горло."
	message_muffled = "издает приглушенный звук." //Потом

/datum/emote/living/dance
	key_third_person = "танцует"
	message = "танцует."

/datum/emote/living/drool
	key_third_person = "пускает слюни"
	message = "пускает слюни."

/datum/emote/living/faint
	key_third_person = "валится с ног"
	message = "валится с ног."

/datum/emote/living/frown
	key_third_person = "хмурится"
	message = "хмурится."
	emote_type = EMOTE_VISIBLE

/datum/emote/living/gag
	key_third_person = "давится"
	message = "давится."

/datum/emote/living/gasp
	key_third_person = "удивленно вздыхает"
	message = "удивленно вздыхает!"
	message_muffled = "издает приглушенный звук." //потом

/datum/emote/living/breathgasp
	key_third_person = "ловит ртом воздух"
	message = "ловит ртом воздух!"

/datum/emote/living/giggle
	key_third_person = "хихикает"
	message = "хихикает."

/datum/emote/living/chuckle
	key_third_person = "усмехается"
	message = "усмехается."


/datum/emote/living/glare
	key_third_person = "сверлит взглядом"
	message = "сверлит взглядом."
	message_param = "сверлит взглядом %t."

/datum/emote/living/grin
	key_third_person = "ухмыляется"
	message = "ухмыляется."

/datum/emote/living/groan
	key_third_person = "тяжело вздыхает"
	message = "тяжело вздыхает."
	message_muffled = "makes a muffled groan." //потом

/datum/emote/living/grimace
	key_third_person = "морщится"
	message = "морщится."

/datum/emote/living/jump
	key_third_person = "прыгает"
	message = "прыгает!"


/datum/emote/living/leap
	key_third_person = "скачет"
	message = "скачет!"

/datum/emote/living/kiss
	key_third_person = "целует"
	message = "посылает воздушный поцелуй."
	message_param = "целует %t."
	emote_type = EMOTE_VISIBLE
	use_params_for_runechat = TRUE

/datum/emote/living/kiss/adjacentaction(mob/user, mob/target)
	. = ..()
	message_param = initial(message_param) // re
	if(!user || !target)
		return
	if(ishuman(user) && ishuman(target))
		var/mob/living/carbon/human/H = user
		var/do_change
		if(target.loc == user.loc)
			do_change = TRUE
		if(!do_change)
			if(H.pulling == target)
				do_change = TRUE
		if(do_change)
			if(H.zone_selected == BODY_ZONE_PRECISE_MOUTH)
				message_param = "страстно целует %t."
			else if(H.zone_selected == BODY_ZONE_PRECISE_EARS)
				message_param = "целует %t в ухо."
				var/mob/living/carbon/human/E = target
				if(iself(E) || ishalfelf(E) || isdarkelf(E))
					if(!E.cmode)
						to_chat(target, span_love("Это щекотно..."))
			else if(H.zone_selected == BODY_ZONE_PRECISE_R_EYE || H.zone_selected == BODY_ZONE_PRECISE_L_EYE)
				message_param = "целует %t в бровь."
			else if(H.zone_selected == BODY_ZONE_PRECISE_SKULL)
				message_param = "целует %t в лоб."
			else if(H.zone_selected == BODY_ZONE_PRECISE_L_HAND || H.zone_selected == BODY_ZONE_PRECISE_R_HAND)
				message_param = "целует ладонь %t"
			else if(H.zone_selected == BODY_ZONE_PRECISE_STOMACH)
				message_param = "целует %t в живот."
			else if(H.zone_selected == BODY_ZONE_PRECISE_NECK)
				message_param = "целует %t в шею."
			else if(H.zone_selected == BODY_ZONE_HEAD)
				message_param = "целует %t в щеку."
			else if(H.zone_selected == BODY_ZONE_PRECISE_GROIN)
				message_param = "целует %t между ног."
				var/mob/living/carbon/human/L = target
				if(isliving(L))
					if(!L.cmode)
						to_chat(target, span_love("Это немного возбуждает..."))
			else
				message_param = "целует %t в \the [parse_zone(H.zone_selected)]." //Локализация частей тела WIP
	playsound(target.loc, pick('sound/vo/kiss (1).ogg','sound/vo/kiss (2).ogg'), 100, FALSE, -1)
	if(user.mind)
		record_round_statistic(STATS_KISSES_MADE)

/datum/emote/living/lick
	key_third_person = "облизывает"
	message = "облизывает."
	message_param = "облизывает %t."

/datum/emote/living/lick/adjacentaction(mob/user, mob/target)
	. = ..()
	message_param = initial(message_param)
	if(!user || !target)
		return
	if(ishuman(user) && ishuman(target))
		var/mob/living/carbon/human/J = user
		var/do_change
		if(target.loc == user.loc)
			do_change = TRUE
		if(!do_change)
			if(J.pulling == target)
				do_change = TRUE
		if(do_change)
			if(J.zone_selected == BODY_ZONE_PRECISE_MOUTH)
				message_param = "облизывает губы %t."
			else if(J.zone_selected == BODY_ZONE_PRECISE_EARS)
				message_param = "облизывает ухо %t."
				var/mob/living/carbon/human/O = target
				if(iself(O) || ishalfelf(O) || isdarkelf(O))
					if(!O.cmode)
						to_chat(target, span_love("Это щекотно..."))
			else if(J.zone_selected == BODY_ZONE_PRECISE_GROIN)
				message_param = "лижет %t между ног."
				to_chat(target, span_love("Это приятно..."))
			else if(J.zone_selected == BODY_ZONE_HEAD)
				message_param = "облизывает щеку %t."
			else
				message_param = "лижет %t по [parse_zone(J.zone_selected)]." //Локализация частей тела WIP
	playsound(target.loc, pick("sound/vo/lick.ogg"), 100, FALSE, -1)

/datum/emote/living/spit
	key_third_person = "плюет"
	message = "плюет на землю."
	message_param = "плюет в %t."

/datum/emote/living/spit/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param) // reset
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mouth)
			if(H.mouth.spitoutmouth)
				H.visible_message(span_warning("[H] выплеывает [H.mouth]."))
				H.dropItemToGround(H.mouth, silent = FALSE)
			return
	..()

/datum/emote/living/hug
	key_third_person = "обнимает"
	message = ""
	message_param = "обнимает %t."

/datum/emote/living/slap
	key_third_person = "шлепает"
	message = ""
	message_param = "отвешивает пощечину %t"

/datum/emote/living/slap/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.zone_selected == BODY_ZONE_PRECISE_GROIN)
			message_param = "шлепает %t' по заднице!"
		else if(H.zone_selected == BODY_ZONE_PRECISE_SKULL)
			message_param = "отвешивает подзатыльник %t"
		else if(H.zone_selected == BODY_ZONE_PRECISE_L_HAND || H.zone_selected == BODY_ZONE_PRECISE_R_HAND)
			message_param = "шлепает по руке %t"
		else if(H.zone_selected == BODY_ZONE_CHEST)
			message_param = "шлепает грудь %t'"
	..()

/datum/emote/living/pinch
	message = ""
	message_param = "щипает %t."

/datum/emote/living/pinch/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.zone_selected == BODY_ZONE_HEAD)
			message_param = "щипает %t за шеку"
		else if(H.zone_selected == BODY_ZONE_PRECISE_L_HAND || H.zone_selected == BODY_ZONE_PRECISE_R_HAND)
			message_param = "щипаеи %t за руку"
		else if(H.zone_selected == BODY_ZONE_CHEST)
			message_param = "шлепает грудь %t'"
		else
			message_param = "pinches %t on \the [parse_zone(H.zone_selected)]."
	..()

/datum/emote/living/laugh
	key_third_person = "смеется"
	message = "смеется."
	message_mime = "бесшумно смеется."
	message_muffled = "приглушенно смеется."

/datum/emote/living/look
	key_third_person = "смотрит"
	message = "смотрит"
	message_param = "разглядывает %t."
/mob/living/carbon/human/verb/emote_look()
	set name = "Look"
	set category = "Emotes"

	emote("look", intentional = TRUE)

/datum/emote/living/nod
	key_third_person = "кивает"
	message = "кивает."
	message_param = "кивает %t."

/datum/emote/living/point
	key_third_person = "указывает"
	message = "указывает."
	message_param = "указывает на %t."

/datum/emote/living/pout
	key_third_person = "дуется"
	message = "дуется."
	emote_type = EMOTE_AUDIBLE
	show_runechat = FALSE
/mob/living/carbon/human/verb/emote_pout()
	set name = "Pout"
	set category = "Emotes"

	emote("pout", intentional = TRUE)

/datum/emote/living/scream
	key_third_person = "кричит"
	message = "кричит!"
	message_mime = "делает вид, что кричит!"
	message_muffled = "издает сдавленный звук в попытке закричать"
	emote_type = EMOTE_AUDIBLE
	show_runechat = FALSE

/datum/emote/living/scream/painscream
	message = "кричит от боли!"

/datum/emote/living/scream/strain
	message = "перенапрягается!"

/datum/emote/living/scream/agony
	message = "кричит в агонии!"

/datum/emote/living/haltyell
	message = "требует остановится!"

/datum/emote/living/rage
	message = "кричит в ярости!"

/datum/emote/living/attnwhistle
	message = "привлекает внимание свистом"
	message_muffled = "издает приглушенный звук." //потом

/datum/emote/living/scowl
	key_third_person = "смотрит исподлобья"
	message = "смотрит исподлобья."
	emote_type = EMOTE_AUDIBLE
	show_runechat = FALSE
/mob/living/carbon/human/verb/emote_scowl()
	set name = "Scowl"
	set category = "Emotes"

	emote("scowl", intentional = TRUE)


/datum/emote/living/shakehead
	key_third_person = "качает головой"
	message = "качает головой."

/datum/emote/living/shiver
	key_third_person = "дрожит"
	message = "дрожит."

/datum/emote/living/sigh
	key_third_person = "вздыхает"
	message = "вздыхает."
	message_muffled = "делает приглушенный вздох." //потом

/datum/emote/living/whistle
	key_third_person = "насвистывает"
	message = "насвистывает."
	message_muffled = "издает приглушенный звук." //потом

/datum/emote/living/hmm
	key_third_person = "хмыкает"
	message = "хмыкает."
	message_muffled = "приглушенно хмыкает." //потом

/datum/emote/living/huh
	key_third_person = "хмыкает?"
	message_muffled = "издает приглушенный звук." //потом

/datum/emote/living/hum
	key_third_person = "напевает"
	message = "напевает."
	message_muffled = "приглушенно напевает." //потом

/datum/emote/living/smile
	key_third_person = "улыбается"
	message = "улыбается."

/datum/emote/living/carbon/clap
	key_third_person = "хлопает"
	message = "хлопает."

/datum/emote/living/sneeze
	key_third_person = "чихает"
	message = "чихает."
	message_muffled = "приглушенно чихает."

/datum/emote/living/hmph
	key = "hmph"
	key_third_person = "хмыкает!"
	message = "хмыкает!"
	message_muffled = "приглушенно хмыкает."
/mob/living/carbon/human/verb/emote_hmph()
	set name = "Hmph"
	set category = "Noises"

	emote("hmph", intentional = TRUE)

/datum/emote/living/shh
	key_third_person = "шикает"
	message = "шикает."
	message_muffled = "приглушенно шикает."

/datum/emote/living/smug
	key_third_person = "самодовольно ухмыляется"
	message = "самодовольно ухмыляется."
/mob/living/carbon/human/verb/emote_smug()
	set name = "Smug"
	set category = "Emotes"

	emote("smug", intentional = TRUE)

/datum/emote/living/sniff
	key_third_person = "нюхает"
	message = "нюхает."
/mob/living/carbon/human/verb/emote_sniff()
	set name = "Sniff"
	set category = "Emotes"

	emote("sniff", intentional = TRUE)

/datum/emote/living/snore
	key_third_person = "храпит"
	message = "храпит."
	message_mime = "сопит."

/datum/emote/living/stare
	key_third_person = "пристально смотрит"
	message = "пристально смотрит."
	message_param = "пристально смотрит на %t."
/mob/living/carbon/human/verb/emote_stare()
	set name = "Stare"
	set category = "Emotes"

	emote("stare", intentional = TRUE)

/datum/emote/living/strech
	key_third_person = "потягивается"
	message = "потягивается."
/mob/living/carbon/human/verb/emote_strech()
	set name = "Strech"
	set category = "Emotes"

	emote("stretch", intentional = TRUE)

/datum/emote/living/sway
	key = "sway"
	key_third_person = "шатается"
	message = "шатается."
/mob/living/carbon/human/verb/emote_sway()
	set name = "Sway"
	set category = "Emotes"

	emote("sway", intentional = TRUE)

/datum/emote/living/tremble
	key_third_person = "дрожит"
	message = "дрожит от страха!"
/mob/living/carbon/human/verb/emote_tremble()
	set name = "Tremble"
	set category = "Emotes"

	emote("tremble", intentional = TRUE)

/datum/emote/living/twitch
	key_third_person = "дергается"
	message = "судорожно подёргивается."

/datum/emote/living/twitch_s
	message = "дергается в судорогах."

/datum/emote/living/warcry
	key_third_person = "издает боевой клич!"
	message = "выкрикивает вдохновляющий боевой клич!"
	message_muffled = "издает приглушенный крик"

/datum/emote/living/wave
	key_third_person = "машет"
	message = "машет."
	
/datum/emote/living/whimper
	key_third_person = "всхлипывает"
	message = "всхлипывает."
	message_mime = "всхлипывает."
	message_muffled = "приглушенно всхлипывает."

/datum/emote/living/wsmile
	key_third_person = "слабо улыбается"
	message = "слабо улыбается."
/mob/living/carbon/human/verb/emote_wsmile()
	set name = "Wsmile"
	set category = "Emotes"

	emote("wsmile", intentional = TRUE)

/datum/emote/living/yawn
	key_third_person = "зевает"
	message = "зевает."
	message_muffled = "приглушенно зевает."

/datum/emote/living/squint
	key_third_person = "щурится"
	message = "щурится"

/datum/emote/living/snap
	key_third_person = "щелкает пальцем"
	message = "щелкает пальцем!"

/datum/emote/living/blink
	key_third_person = "хлопает глазами."
	message = "хлопает глазами."

/datum/emote/living/stomp
	key_third_person = "топает"
	message = "топает!"

/datum/emote/living/snap2
	key_third_person = "дважды щелкает пальцами"
	message = "дважды щелкает пальцами!"

/datum/emote/living/snap3
	key_third_person = "трижды щелкает пальцами"
	message = "трижды щелкает пальцами!"

/datum/emote/living/fsalute
	key_third_person = "превозносит свою веру"
	message = "превозносит свою веру."

/datum/emote/living/ffsalute
	key_third_person = "превозносит свою веру"
	message = "превозносит свою веру."

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "плачет"
	message = "плачет."
/datum/emote/living/carbon/human/cry/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.can_speak())
			message = "всхлипывает. Поток слез стекает по лицу."

/*
/datum/emote/living/carbon/human/sexmoanlight/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.can_speak())
			message = "makes a noise."
*/

/datum/emote/living/carbon/human/eyebrow
	message = "приподнимает бровь."

/datum/emote/living/carbon/human/grumble
	key_third_person = "бухтит"
	message = "бухтит."
	message_muffled = "приглушенно бухтит."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/handshake //потом (таргеты)
	message = "пожимает свою руку"
	message_param = "пожимает руку %t."

/datum/emote/living/carbon/human/pale
	message = "бледнеет на мгновенье."
/mob/living/carbon/human/verb/emote_pale()
	set name = "Pale"
	set category = "Emotes"

	emote("pale", intentional = TRUE)

/datum/emote/living/carbon/human/raise
	key_third_person = "вскидывает руку"
	message = "вскидывает руку."
/mob/living/carbon/human/verb/emote_raise()
	set name = "Hand Raise"
	set category = "Emotes"

	emote("raise", intentional = TRUE)

/datum/emote/living/carbon/human/salute
	key_third_person = "салютует"
	message = "салютует."
	message_param = "салютует %t."
	restraint_check = TRUE
/mob/living/carbon/human/verb/emote_salute()
	set name = "Salute"
	set category = "Emotes"

	emote("salute", intentional = TRUE)

/datum/emote/living/carbon/human/shrug
	key_third_person = "пожимает плечами"
	message = "пожимает плечами."
/mob/living/carbon/human/verb/emote_shrug()
	set name = "Shrug"
	set category = "Emotes"

	emote("shrug", intentional = TRUE)

/datum/emote/living/carbon/human/wag
	key_third_person = "виляет"
	message = "виляет своим хвостом."

/datum/emote/living/carbon/human/wing
	key_third_person = "машет крыльями"
	message = "хлопает своими крыльями."

/*
/datum/emote/living/stat_roll/run_emote(mob/user, params, type_override, intentional = FALSE)
	. = ..()
	if(.)
		sleep(delay)

		var/mob/living/living = user
		var/chance_per_point = 5
		var/success = FALSE
		var/chance = 0

		var/modifier_sum
		if(length(modifiers_list))
			for(var/key in modifiers_list)
				if(HAS_TRAIT(living, key))
					modifier_sum += modifiers_list[key]

		switch(key)
			if("strength")
				success = living.stat_roll(STAT_STRENGTH, chance_per_point, modifier_sum) 
				chance = living.get_stat(STAT_STRENGTH)
			if("perception")
				success = living.stat_roll(STAT_PERCEPTION, chance_per_point, modifier_sum)
				chance = living.get_stat(STAT_PERCEPTION)
			if("intelligence")
				success = living.stat_roll(STAT_INTELLIGENCE, chance_per_point, modifier_sum)
				chance = living.get_stat(STAT_INTELLIGENCE)
			if("constitution")
				success = living.stat_roll(STAT_CONSTITUTION, chance_per_point, modifier_sum)
				chance = living.get_stat(STAT_CONSTITUTION)
			if("willpower")
				success = living.stat_roll(STAT_WILLPOWER, chance_per_point, modifier_sum)
				chance = living.get_stat(STAT_WILLPOWER)
			if("speed")
				success = living.stat_roll(STAT_SPEED, chance_per_point, modifier_sum)
				chance = living.get_stat(STAT_SPEED)
			if("fortune")
				success = living.stat_roll(STAT_FORTUNE, chance_per_point, modifier_sum)
				chance = living.get_stat(STAT_FORTUNE)
			if("charisma")
				// We compare willpower and fortune and use the highest. Not the best way to handle charisma actions, may be a subject to change in future
				var/will = living.get_stat(STAT_WILLPOWER)
				var/fort = living.get_stat(STAT_FORTUNE)
				var/chosen_stat = (will > fort) ? STAT_WILLPOWER : STAT_FORTUNE

				success = living.stat_roll(chosen_stat, chance_per_point, modifier_sum)
				chance = living.get_stat(chosen_stat)

		// modifier_sum is a difficulty class modifier, negative values make a roll more likely to succeed
		chance -= modifier_sum
		chance *= chance_per_point

		var/msg = success ? span_green("УСПЕШНО [pick(success_message_list)]") : span_danger("ПРОВАЛ: [pick(failure_message_list)] [chance]%")

		msg = replace_pronoun(user, msg)

		if(!msg)
			return

		// A COMSIG here would be nice, in my attempts it sadly didn't work out well for the relay.
		var/atom/movable/emotelocation = user
		var/mob/living/carbon/human/human
		if(ishuman(user))
			human = user

		var/obj/item/organ/dullahan_vision/vision
		var/datum/species/dullahan/dullahan
		if(isdullahan(user))
			dullahan = human.dna.species
			vision = human.getorganslot(ORGAN_SLOT_HUD)
			if(dullahan.headless && vision.viewing_head)
				emotelocation = dullahan.my_head

		user.log_message(msg, LOG_EMOTE)
		var/pre_color_msg = msg
		if (use_params_for_runechat) // apply puncutation stripping here where appropriate
			var/static/regex/regex = regex(@"[,.!?]", "g")
			pre_color_msg = regex.Replace(pre_color_msg, "")
			pre_color_msg = trim(pre_color_msg, MAX_MESSAGE_LEN)
		// Checks to see if we're emoting on the body while we have a head, or if we're emoting on the head.
		if(human && human.voice_color)
			msg = "<span style='color:#[human.voice_color];text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b>[emotelocation]</b></span> " + msg
		else
			msg = "<b>[emotelocation]</b> " + msg
		for(var/mob/M in GLOB.dead_mob_list)
			if(!M.client || isnewplayer(M))
				continue
			var/T = get_turf(emotelocation)
			if(M.stat == DEAD && M.client && (M.client.prefs?.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(T, null)))
				M.show_message(msg)
		var/runechat_msg_to_use = null
		if(show_runechat)
			runechat_msg_to_use = runechat_msg ? runechat_msg : pre_color_msg
		emotelocation.visible_message(msg, runechat_message = runechat_msg_to_use, log_seen = SEEN_LOG_EMOTE)

/datum/emote/living/stat_roll/strength
	attempt_message_list = list(
		"испытывает свою силу...",
		"прикладывает усилие...",
		"напрягает мышцы...",
	)

	success_message_list = list(
		"демонстрирует свою силу!",
		"оправдывает наличие таких мышц!",
		"доказывает, что силен!",
	)

	failure_message_list = list(
		"руки похожи на ветки",
		"не сможет поднять даже стул",
		"стоило есть больше мяса",
	)

/datum/emote/living/stat_roll/perception
	attempt_message_list = list(
		"очень тщательно всматривается...",
		"фокусирует взгляд...",
		"прищуривается...",
	)

	success_message_list = list(
		"может похвастаться орлиным зрением!",
		"видит то, что не видят другие!",
		"видит мельчайшую деталь!",
	)

	failure_message_list = list(
		"видимо страдает близорукостью!",
		"похоже обладает катарактой!",
		"слеп....",
	)

/datum/emote/living/stat_roll/intelligence
	attempt_message_list = list(
		"задумывается...",
		"сводит свои брови...",
		"задумчиво чешет подбородок...",
	)

	success_message_list = list(
		"доказывает, что в рядах одних из умнейших!",
		"доказывает остроту своего ума!",
		"что знает, что делает!",
	)

	failure_message_list = list(
		"вообще не понимает где находиться...",
		"голова, как кочерыжка",
		"как сложить два плюс два - осталось загадкой...",
	)

/datum/emote/living/stat_roll/constitution
	attempt_message_list = list(
		"испытывает свою крепость",
		"готовится к удару...",
		"приготовился терпеть...",
	)

	success_message_list = list(
		"даже не дрогнул!",
		"крепок, как дуб!",
		"даже не повел и бровью!",
	)

	failure_message_list = list(
		"одни кожа, да кости...",
		"покачивается, как травинка на ветру",
		"хрупок, как хрусталь",
	)

/datum/emote/living/stat_roll/willpower
	modifiers_list = list(
		TRAIT_TOLERANT = -1,
	)

	attempt_message_list = list(
		"испытывает свою силу воли...",
		"собирается с мыслями...",
		"готовиться доказать свою решимость...",
	)

	success_message_list = list(
		"преодолевает это",
		"никогда не сдается!",
		"пройдет сквозь огонь и воду",
	)

	failure_message_list = list(
		"труслив как цыпленок",
		"руки опускаются...",
		"испугается, даже, если никто не крикнет",
	)

/datum/emote/living/stat_roll/speed
	attempt_message_list = list(
		"готовит свой лучшее движение...",
		"демонстрирует свою гибкость...",
		"пытается разогнаться...",
	)

	success_message_list = list(
		"показывает блестящий контроль своего тела",
		"изгибается, словно кошка",
		"невероятная гибкость",
	)

	failure_message_list = list(
		"похоже владеет двумя левыми",
		"переигрывает себя",
		"медленнее улитки...",
	)

/datum/emote/living/stat_roll/fortune
	attempt_message_list = list(
		"испытывает свою удачу...",
		"ловит момент...",
		"взвешивает ставки...",
	)

	success_message_list = list(
		"мог бы найти слиток в луже",
		"будто бы, крольчия лапка в кармане!",
		"светиться истинной удачей!",
	)

	failure_message_list = list(
		"понимает, что игра была проигрышной с самого начала...",
		"удача явно не на его стороне",
		"все ставки против...",
	)

/datum/emote/living/stat_roll/charisma
	attempt_message_list = list(
		"пытается сохранить самообладание...",
		"пробует произвести впечатление...",
		"обдумывает следующий шаг...",
	)

	success_message_list = list(
		"переполнен непоколебимой уверенностью!",
		"- лицо, подобно каменной маске",
		"... лик подобен богу",
	)

	failure_message_list = list(
		"кипит от неуверенности...",
		"не очень-то убедительно...",
		"собранность висит на честном слове...",
	)
*/
