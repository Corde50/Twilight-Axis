/datum/soundbreaker_combo_tracker
	var/mob/living/owner
	var/list/history

/datum/soundbreaker_combo_tracker/New(mob/living/L)
	. = ..()
	owner = L
	history = list()

/datum/soundbreaker_combo_tracker/proc/register_hit(note_id, mob/living/target)
	if(!owner)
		return
	if(!history)
		history = list()

	var/entry = list(
		"note" = note_id,
		"time" = world.time,
		"target" = target,
	)

	history += list(entry)
	cleanup_history()
	check_combos()

/datum/soundbreaker_combo_tracker/proc/cleanup_history()
	if(!history || !history.len)
		return

	var/current_time = world.time
	var/list/new_history = list()

	for(var/i in 1 to history.len)
		var/entry = history[i]
		if(!islist(entry))
			continue
		var/when = entry["time"]
		if(isnull(when))
			continue
		if(current_time - when <= SB_COMBO_WINDOW)
			new_history += list(entry)

	while(new_history.len > SB_MAX_HISTORY)
		new_history.Cut(1, 2)

	history = new_history

/datum/soundbreaker_combo_tracker/proc/check_combos()
	if(!history || !history.len)
		return

	var/list/notes = list()
	var/mob/living/last_target

	for(var/i in 1 to history.len)
		var/entry = history[i]
		if(!islist(entry))
			continue
		notes += entry["note"]
		last_target = entry["target"]

	if(!last_target)
		return

	// 10) Overture: 1,1,2,4,5
	if(soundbreaker_match_suffix(notes, list(1, 1, 2, 4, 5)))
		soundbreaker_combo_overture(owner, last_target)
		return

	// 9) Crescendo Finale: 3,2,4,6
	if(soundbreaker_match_suffix(notes, list(3, 2, 4, 6)))
		soundbreaker_combo_crescendo(owner, last_target)
		return

	// 11) Blade Dancer: 3,3,6,1
	if(soundbreaker_match_suffix(notes, list(3, 3, 6, 1)))
		soundbreaker_combo_blade_dancer(owner, last_target)
		return

	// 12) Harmonic Burst: 2,2,2,4
	if(soundbreaker_match_suffix(notes, list(2, 2, 2, 4)))
		soundbreaker_combo_harmonic_burst(owner, last_target)
		return

	// 5) Bass Drop: 1,2,4
	if(soundbreaker_match_suffix(notes, list(1, 2, 4)))
		soundbreaker_combo_bass_drop(owner, last_target)
		return

	// 6) Reverb Cut: 3,1,2
	if(soundbreaker_match_suffix(notes, list(3, 1, 2)))
		soundbreaker_combo_reverb_cut(owner, last_target)
		return

	// 7) Syncopation Lock: 2,4,1
	if(soundbreaker_match_suffix(notes, list(2, 4, 1)))
		soundbreaker_combo_syncopation(owner, last_target)
		return

	// 8) Ritmo: 1,1,1
	if(soundbreaker_match_suffix(notes, list(1, 1, 1)))
		soundbreaker_combo_ritmo(owner, last_target)
		return

	// 1) Echo Beat: 1,1
	if(soundbreaker_match_suffix(notes, list(1, 1)))
		soundbreaker_combo_echo_beat(owner, last_target)
		return

	// 2) Tempo Flick: 1,2
	if(soundbreaker_match_suffix(notes, list(1, 2)))
		soundbreaker_combo_tempo_flick(owner, last_target)
		return

	// 3) Snapback: 2,1
	if(soundbreaker_match_suffix(notes, list(2, 1)))
		soundbreaker_combo_snapback(owner, last_target)
		return

	// 4) Crossfade: 3,1
	if(soundbreaker_match_suffix(notes, list(3, 1)))
		soundbreaker_combo_crossfade(owner, last_target)
		return

/// Глобалка для регистрации удара ноты
/proc/soundbreaker_on_hit(mob/living/user, mob/living/target, note_id)
	if(!user || !target || !note_id)
		return

	if(!soundbreaker_has_music(user))
		return

	var/datum/soundbreaker_combo_tracker/T = soundbreaker_get_combo_tracker(user)
	if(T)
		T.register_hit(note_id, target)

	soundbreaker_add_combo_stack(user)

/// Получить/создать трекер на мобе
/proc/soundbreaker_get_combo_tracker(mob/living/user)
	if(!user)
		return null
	if(!user.soundbreaker_combo)
		user.soundbreaker_combo = new /datum/soundbreaker_combo_tracker(user)
	return user.soundbreaker_combo

/// Проверка, совпадает ли хвост списка нот с паттерном
/proc/soundbreaker_match_suffix(list/notes, list/pattern)
	if(!notes || !pattern)
		return FALSE
	if(pattern.len > notes.len)
		return FALSE

	var/base = notes.len - pattern.len
	for(var/i in 1 to pattern.len)
		if(notes[base + i] != pattern[i])
			return FALSE
	return TRUE

/// Стак-комбо на владельце
/proc/soundbreaker_add_combo_stack(mob/living/user)
	if(!user)
		return
	user.apply_status_effect(/datum/status_effect/buff/soundbreaker_combo)

/proc/soundbreaker_get_combo_stacks(mob/living/user)
	if(!user)
		return 0
	var/datum/status_effect/buff/soundbreaker_combo/C = user.has_status_effect(/datum/status_effect/buff/soundbreaker_combo)
	if(!C)
		return 0
	return C.stacks

/// Проверка, играет ли музыка
/proc/soundbreaker_has_music(mob/living/user)
	if(!user)
		return FALSE

	if(user.has_status_effect(/datum/status_effect/buff/playing_music))
		return TRUE

	return FALSE

/// Вспомогательные проки контроля / доп-эффектов
/proc/sb_safe_offbalance(mob/living/L, duration)
	if(!L)
		return
	L.OffBalance(duration)

/proc/sb_safe_slow(mob/living/L, amount)
	if(!L)
		return
	L.Slowdown(amount)

/proc/sb_small_bleed(mob/living/L, times)
	if(!L)
		return
	for(var/i in 1 to times)
		L.apply_damage(2, BRUTE)

/// Нокбэк на tiles тайлов от user
/proc/soundbreaker_knockback(mob/living/user, mob/living/target, tiles)
	if(!user || !target)
		return
	var/dir = get_dir(user, target)
	var/turf/start = get_turf(target)
	var/turf/dest = get_ranged_target_turf(start, dir, tiles)
	if(dest)
		target.safe_throw_at(dest, tiles, 1, user, force = MOVE_FORCE_NORMAL)

/// Биндинг bclass → armor damage flag
/proc/soundbreaker_get_damage_flag(bclass, damage_type)
	switch(bclass)
		if(BCLASS_BLUNT, BCLASS_SMASH, BCLASS_TWIST, BCLASS_PUNCH)
			return "blunt"
		if(BCLASS_CHOP, BCLASS_CUT, BCLASS_LASHING, BCLASS_PUNISH)
			return "slash"
		if(BCLASS_PICK, BCLASS_STAB, BCLASS_PIERCE)
			return "stab"

	switch(damage_type)
		if(BRUTE)
			return "blunt"
		if(BURN)
			return "fire"
		if(TOX)
			return "bio"
		if(OXY)
			return "oxy"

	return "blunt"

/// Главный хелпер нанесения урона
/proc/soundbreaker_apply_damage(
	mob/living/user,
	mob/living/target,
	damage_mult = 1,
	bclass = BCLASS_PUNCH,
	zone = BODY_ZONE_CHEST,
	damage_type = BRUTE,
	use_combo_pierce = TRUE,
)
	if(!target)
		return FALSE

	var/final_damage = soundbreaker_scale_damage(user, damage_mult)
	if(final_damage <= 0)
		return FALSE

	if(use_combo_pierce)
		var/stacks = soundbreaker_get_combo_stacks(user)
		if(stacks >= 3)
			bclass = BCLASS_STAB

	// ХУМАНЫ
	if(ishuman(target))
		var/mob/living/carbon/human/H = target

		if(!zone)
			zone = BODY_ZONE_CHEST

		var/obj/item/bodypart/affecting = H.get_bodypart(zone)
		if(!affecting)
			affecting = H.get_bodypart(BODY_ZONE_CHEST)
			if(affecting)
				zone = affecting.body_zone

		if(!affecting)
			return FALSE

		var/d_flag = soundbreaker_get_damage_flag(bclass, damage_type)
		var/armor_block = H.run_armor_check(zone, d_flag, 0, damage = final_damage, used_weapon = null)

		if(H.apply_damage(final_damage, damage_type, affecting, armor_block))
			affecting.bodypart_attacked_by(
				bclass,
				final_damage,
				user,
				zone_precise = zone,
				armor = armor_block,
				crit_message = TRUE,
				weapon = null,
			)
			return TRUE

		return FALSE

	// SIMPLE_WOUNDS
	if(HAS_TRAIT(target, TRAIT_SIMPLE_WOUNDS))
		if(target.apply_damage(final_damage, damage_type))
			target.simple_woundcritroll(bclass, final_damage, user, zone)
			return TRUE
		return FALSE

	// Всё остальное просто принимает урон
	return target.apply_damage(final_damage, damage_type)

/// Удар по одной случайной цели на тайле.
/proc/soundbreaker_hit_one_on_turf(
	mob/living/user,
	turf/T,
	damage_mult = 1,
	damage_type = BRUTE,
	bclass = BCLASS_PUNCH,
	zone,
)
	if(!user || !T)
		return null

	var/list/candidates = list()
	for(var/mob/living/L in T)
		if(L == user)
			continue
		if(L.stat == DEAD)
			continue
		candidates += L

	if(!candidates.len)
		return null

	var/mob/living/target = pick(candidates)

	if(!zone && istype(user))
		var/mob/living/UL = user
		if(UL.zone_selected)
			zone = UL.zone_selected

	if(!zone)
		zone = BODY_ZONE_CHEST

	if(soundbreaker_apply_damage(user, target, damage_mult, bclass, zone, damage_type))
		return target

	return null

/// Скалирование урона саундбрекера от статов и навыков
/// base_damage — то, что ты прописываешь в спелле/комбо (номинальный урон)
/// Возвращает уже “боевой” урон.
#define SB_MIN_DAMAGE_MULT 0.5
#define SB_MAX_DAMAGE_MULT 3

/proc/soundbreaker_scale_damage(mob/living/user, damage_mult)
	if(!user || damage_mult <= 0)
		return 0

	var/damage = 0

	// --- СТАТЫ ---
	var/str = user.get_stat(STATKEY_STR)
	var/dex = user.get_stat(STATKEY_SPD)
	var/con = user.get_stat(STATKEY_CON)
	damage = str

	// считаем 10 за базу, как “средний” человек
	var/dex_bonus = (dex - 10) * 0.1  // ±10% за 1 DEX (чуть поменьше, как “точность/техника”)
	damage += damage*con_bonus 
	damage *= damage_mult
	
	// --- НАВЫКИ ---
	var/unarmed_skill = user.get_skill_level(/datum/skill/combat/unarmed)
	var/music_skill = user.get_skill_level(/datum/skill/misc/music)

	// --- Активное оружие и его показатели ---
	var/obj/holding = user.get_active_held_item()
	if(holding)
		if(istype(holding, /obj/item/rogueweapon/katar) || istype(holding, /obj/item/rogueweapon/knuckles))
			var/weapon_force = holding.force
			damage += weapon_force/2

	// 25% за уровень безоружки, 15% за уровень музыки
	var/skill_bonus = (unarmed_skill * 0.2) + (music_skill * 0.1)

	skill_bonus = clamp(skill_bonus, SB_MIN_DAMAGE_MULT, SB_MAX_DAMAGE_MULT)

	damage *= skill_bonus

	return max(1, round(damage))

#undef SB_MIN_DAMAGE_MULT
#undef SB_MAX_DAMAGE_MULT
