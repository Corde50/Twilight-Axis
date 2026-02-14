#define INJECT_NONE         0
#define INJECT_CONTINUOUS   1
#define INJECT_ON_FINISH    2

#define INJECT_ORGAN		"organ"
#define INJECT_CONTAINER	"container"
#define INJECT_GROUND		"ground"

#define INJECT_FROM_ACTIVE  "active"
#define INJECT_FROM_PASSIVE "passive"

var/static/regex/ERP_REGEX_CONDITIONAL = regex(@"\{(\w+)\?([^:}]*):([^}]*)\}")

/datum/erp_action
	var/id = null
	var/name = "Unnamed action"
	var/ckey = null
	var/abstract = FALSE
	var/required_init_organ = null
	var/required_target_organ = null
	var/reserve_target_organ = FALSE
	var/tick_time = 3 SECONDS
	var/continuous = TRUE
	var/active_arousal_coeff  = 1.0
	var/passive_arousal_coeff = 1.0
	var/active_pain_coeff     = 1.0
	var/passive_pain_coeff    = 1.0
	var/inject_timing = INJECT_NONE
	var/inject_source = INJECT_FROM_ACTIVE
	var/inject_target_mode = INJECT_ORGAN
	var/require_same_tile = TRUE
	var/require_grab = FALSE
	var/allow_when_restrained = FALSE
	var/list/required_item_tags = list()
	var/list/action_tags = list()
	var/allow_sex_on_move = FALSE
	var/message_start = null
	var/message_tick = null
	var/message_finish = null
	var/message_climax_active = null
	var/message_climax_passive = null
	var/action_scope = ERP_SCOPE_OTHER

/datum/erp_action/proc/calc_effect(datum/erp_sex_link/L)
	if(!L || !L.init_organ || !L.target_organ)
		return null

	var/datum/erp_sex_organ/I = L.init_organ
	var/datum/erp_sex_organ/T = L.target_organ
	var/a_arousal = (I.active_arousal * active_arousal_coeff) + (T.passive_arousal * passive_arousal_coeff)
	var/a_pain    = (I.active_pain    * active_pain_coeff)    + (T.passive_pain    * passive_pain_coeff)
	var/p_arousal = (T.active_arousal * passive_arousal_coeff) + (I.passive_arousal * active_arousal_coeff)
	var/p_pain    = (T.active_pain    * passive_pain_coeff)    + (I.passive_pain    * active_pain_coeff)
	a_arousal *= I.sensitivity
	a_pain    *= I.sensitivity
	p_arousal *= T.sensitivity
	p_pain    *= T.sensitivity
	var/ar_legacy = (a_arousal + p_arousal) * 0.5
	var/pa_legacy = (a_pain + p_pain) * 0.5

	return list(
		"active_arousal" = a_arousal,
		"active_pain"    = a_pain,
		"passive_arousal" = p_arousal,
		"passive_pain"    = p_pain,
		"arousal" = ar_legacy,
		"pain"    = pa_legacy
	)


/datum/erp_action/proc/handle_inject(datum/erp_sex_link/L, datum/erp_actor/who = null)
	if(!L)
		return

	var/datum/erp_sex_organ/source = null
	switch(inject_source)
		if(INJECT_FROM_ACTIVE)  source = L.init_organ
		if(INJECT_FROM_PASSIVE) source = L.target_organ

	if(source)
		L.request_inject(source, inject_target_mode, who)

/datum/erp_action/proc/build_message(template, datum/erp_sex_link/L)
	var/text = "[template]"
	text = apply_conditionals(text, L)
	text = replace_keywords(text, L)
	return text

/datum/erp_action/proc/apply_conditionals(text, datum/erp_sex_link/L)
	var/result = text
	var/guard = 0
	while(guard++ < 50)
		var/pos = ERP_REGEX_CONDITIONAL.Find(result)
		if(!pos)
			break

		var/key = ERP_REGEX_CONDITIONAL.group[1]
		var/yes = ERP_REGEX_CONDITIONAL.group[2]
		var/no  = ERP_REGEX_CONDITIONAL.group[3]
		var/repl = resolve_condition(key, L) ? yes : no
		var/match = ERP_REGEX_CONDITIONAL.match
		var/match_len = length(match)
		result = copytext(result, 1, pos) + repl + copytext(result, pos + match_len)

	return result

/datum/erp_action/proc/resolve_condition(key, datum/erp_sex_link/L)
	switch(key)
		if("aggr")     return L.is_aggressive()
		if("big")      return L.has_big_breasts()
		if("dullahan") return L.is_dullahan_scene()
	return FALSE

/datum/erp_action/proc/replace_keywords(text, datum/erp_sex_link/L)
	var/t = text
	t = replacetext(t, "{actor}", "[L.actor_active?.physical]")
	t = replacetext(t, "{partner}", "[L.actor_passive?.physical]")
	t = replacetext(t, "{force}", "[L.get_force_text()]")
	t = replacetext(t, "{speed}", "[L.get_speed_text()]")
	t = replacetext(t, "{zone}",  "[L.get_target_zone_text()]")
	t = replacetext(t, "{pose}",  "[L.get_pose_text()]")
	return t

/datum/erp_action/proc/set_field(field_id, value)
	switch(field_id)
		if("name", "display_name", "title")
			name = isnull(value) ? null : "[value]"
			return TRUE

		if("required_init_organ")
			required_init_organ = value
			return TRUE
		if("required_target_organ")
			required_target_organ = value
			return TRUE
		if("reserve_target_organ")
			reserve_target_organ = !!value
			return TRUE

		if("tick_time")
			var/n = text2num("[value]")
			if(!isnum(n)) n = 0
			tick_time = _seconds_to_ticks(n)
			return TRUE
		if("continuous")
			continuous = !!value
			return TRUE

		if("active_arousal_coeff")  { active_arousal_coeff  = text2num("[value]"); return TRUE }
		if("passive_arousal_coeff") { passive_arousal_coeff = text2num("[value]"); return TRUE }
		if("active_pain_coeff")     { active_pain_coeff     = text2num("[value]"); return TRUE }
		if("passive_pain_coeff")    { passive_pain_coeff    = text2num("[value]"); return TRUE }
		if("inject_timing")
			inject_timing = isnum(value) ? value : text2num("[value]")
			return TRUE
		if("inject_source")
			inject_source = isnull(value) ? INJECT_FROM_ACTIVE : "[value]"
			return TRUE
		if("inject_target_mode")
			inject_target_mode = isnull(value) ? INJECT_ORGAN : "[value]"
			return TRUE
		if("require_same_tile") { require_same_tile = !!value; return TRUE }
		if("allow_when_restrained") { allow_when_restrained = !!value; return TRUE }
		if("allow_sex_on_move") { allow_sex_on_move = !!value; return TRUE }
		if("required_item_tags")
			required_item_tags = _coerce_string_list(value)
			return TRUE
		if("action_tags")
			action_tags = _coerce_string_list(value)
			return TRUE
		if("message_start") { message_start = _coerce_text_or_null(value); return TRUE }
		if("message_tick") { message_tick = _coerce_text_or_null(value); return TRUE }
		if("message_finish") { message_finish = _coerce_text_or_null(value); return TRUE }
		if("message_climax_active") { message_climax_active = _coerce_text_or_null(value); return TRUE }
		if("message_climax_passive") { message_climax_passive = _coerce_text_or_null(value); return TRUE }
		if("action_scope")
			var/n = isnum(value) ? value : text2num("[value]")
			if(n != ERP_SCOPE_SELF && n != ERP_SCOPE_OTHER)
				return FALSE
			action_scope = n
			return TRUE

	return FALSE

/datum/erp_action/proc/_coerce_text_or_null(v)
	if(isnull(v))
		return null
	var/t = "[v]"
	if(!length(t))
		return null
	return t

/datum/erp_action/proc/_coerce_string_list(v)
	var/list/out = list()
	if(islist(v))
		for(var/it in v)
			if(isnull(it)) continue
			var/t = "[it]"
			t = trim(t)
			if(length(t))
				out += t
	return out

/datum/erp_action/proc/export_for_prefs()
	var/list/out = list()

	for(var/field in ERP_ACTION_PREF_FIELDS)
		if(!hasvar(src, field))
			continue

		var/v = src.vars[field]
		if(islist(v))
			var/list/L = v
			var/list/copy = list()
			if(L.len)
				copy += L
			out[field] = copy
		else
			out[field] = v

	return out

/datum/erp_action/proc/import_from_prefs(list/data)
	if(!islist(data))
		return FALSE

	for(var/field in ERP_ACTION_PREF_FIELDS)
		if(!(field in data) || !hasvar(src, field))
			continue

		var/v = data[field]
		if(islist(v))
			var/list/L = v
			var/list/copy = list()
			if(L.len)
				copy += L
			src.vars[field] = copy
		else
			src.vars[field] = v

	return TRUE

/datum/erp_action/proc/export_editor_fields()
	. = list()
	. += list(_make_field("action_scope", "Направление действия", "enum", action_scope, "ОСНОВНОЕ", null, null, null, _scope_options(),"Self — действие с собой. Other — действие с партнёром. Это влияет на список доступных действий и фильтрацию.", null))
	. += list(_make_field("required_init_organ", "Орган актёра (init)", "enum", required_init_organ, "ОРГАНЫ", null, null, null, _organ_options()))
	. += list(_make_field("required_target_organ", "Орган цели (target)", "enum", required_target_organ, "ОРГАНЫ", null, null, null, _organ_options()))
	. += list(_make_field("reserve_target_organ", "Резервировать орган цели", "bool", reserve_target_organ, "ОРГАНЫ"))
	. += list(_make_field("tick_time", "Tick time (сек)", "number", _ticks_to_seconds(tick_time), "ТАЙМИНГ", 0.1, 60, 0.1))
	. += list(_make_field("continuous", "Непрерывное", "bool", continuous, "ТАЙМИНГ"))
	. += list(_make_field("active_arousal_coeff",  "Возбуждение актёра", "number", active_arousal_coeff,  "ЭФФЕКТЫ", 0, 10, 0.1))
	. += list(_make_field("passive_arousal_coeff", "Возбуждение цели",  "number", passive_arousal_coeff, "ЭФФЕКТЫ", 0, 10, 0.1))
	. += list(_make_field("active_pain_coeff",     "Боль актёра",       "number", active_pain_coeff,     "ЭФФЕКТЫ", 0, 10, 0.1))
	. += list(_make_field("passive_pain_coeff",    "Боль цели",         "number", passive_pain_coeff,    "ЭФФЕКТЫ", 0, 10, 0.1))
	. += list(_make_field("inject_timing", "Инъекция: когда", "enum", inject_timing, "ИНЪЕКЦИЯ", null, null, null, _inject_timing_options()))
	. += list(_make_field("inject_source", "Инъекция: источник", "enum", inject_source, "ИНЪЕКЦИЯ", null, null, null, _inject_source_options()))
	. += list(_make_field("inject_target_mode", "Инъекция: цель", "enum", inject_target_mode, "ИНЪЕКЦИЯ", null, null, null, _inject_target_mode_options()))
	. += list(_make_field("require_same_tile", "Только с одного тайла", "bool", require_same_tile, "ОГРАНИЧЕНИЯ"))
	. += list(_make_field("allow_when_restrained", "Можно в стяжках", "bool", allow_when_restrained, "ОГРАНИЧЕНИЯ"))
	. += list(_make_field("require_grab", "Нужен граб", "bool", require_grab, "ОГРАНИЧЕНИЯ"))
	. += list(_make_field("required_item_tags", "Нужные теги предмета", "string_list", required_item_tags, "ТЕГИ",
		null, null, null, null, "Напр: dildo. Если список не пуст — действие потребует предмет с одним из тегов.", "tag"))
	. += list(_make_field("action_tags", "Теги действия", "string_list", action_tags, "ТЕГИ",
		null, null, null, null, "Напр: spanking, testicles. Для фильтров/логики/совместимости.", "tag"))
	. += list(_make_field("message_start", "Сообщение: старт", "text", message_start, "СООБЩЕНИЯ"))
	. += list(_make_field("message_tick", "Сообщение: тик", "text", message_tick, "СООБЩЕНИЯ"))
	. += list(_make_field("message_finish", "Сообщение: финиш", "text", message_finish, "СООБЩЕНИЯ"))
	. += list(_make_field("message_climax_active", "Оргазм: актёр", "text", message_climax_active, "СООБЩЕНИЯ"))
	. += list(_make_field("message_climax_passive", "Оргазм: цель", "text", message_climax_passive, "СООБЩЕНИЯ"))

/datum/erp_action/proc/_make_field(id, label, type, value, section, min=null, max=null, step=null, options=null, desc=null, placeholder=null)
	var/list/F = list(
		"id" = id,
		"label" = label,
		"type" = type,
		"value" = value,
		"section" = section
	)

	if(!isnull(min)) F["min"] = min
	if(!isnull(max)) F["max"] = max
	if(!isnull(step)) F["step"] = step
	if(islist(options)) F["options"] = options
	if(!isnull(desc)) F["desc"] = desc
	if(!isnull(placeholder)) F["placeholder"] = placeholder
	return F

/datum/erp_action/proc/_ticks_to_seconds(ticks)
	if(!isnum(ticks))
		return 0
	return ticks / 10

/datum/erp_action/proc/_seconds_to_ticks(sec)
	if(!isnum(sec))
		return 0
	return max(0, round(sec * 10))

/datum/erp_action/proc/_opt(value, name)
	return list("value" = value, "name" = name)

/datum/erp_action/proc/_organ_options()
	. = list()
	. += list(_opt(null, "—"))
	. += list(_opt(SEX_ORGAN_PENIS, "Член"))
	. += list(_opt(SEX_ORGAN_VAGINA, "Вагина"))
	. += list(_opt(SEX_ORGAN_ANUS, "Анус"))
	. += list(_opt(SEX_ORGAN_MOUTH, "Рот"))
	. += list(_opt(SEX_ORGAN_BREASTS, "Грудь"))
	. += list(_opt(SEX_ORGAN_HANDS, "Руки"))
	. += list(_opt(SEX_ORGAN_LEGS, "Ноги"))
	. += list(_opt(SEX_ORGAN_TAIL, "Хвост"))
	. += list(_opt(SEX_ORGAN_BODY, "Тело"))

/datum/erp_action/proc/_inject_timing_options()
	. = list()
	. += list(_opt(INJECT_NONE, "Нет"))
	. += list(_opt(INJECT_CONTINUOUS, "В процессе"))
	. += list(_opt(INJECT_ON_FINISH, "На финише"))

/datum/erp_action/proc/_inject_source_options()
	. = list()
	. += list(_opt(INJECT_FROM_ACTIVE, "От актёра"))
	. += list(_opt(INJECT_FROM_PASSIVE, "От цели"))

/datum/erp_action/proc/_inject_target_mode_options()
	. = list()
	. += list(_opt(INJECT_ORGAN, "В выбранный орган"))
	. += list(_opt(INJECT_CONTAINER, "В контейнер"))
	. += list(_opt(INJECT_GROUND, "на пол"))

/datum/erp_action/proc/_scope_options()
	. = list()
	. += list(_opt(ERP_SCOPE_OTHER, "Партнёр"))
	. += list(_opt(ERP_SCOPE_SELF,  "Соло"))
