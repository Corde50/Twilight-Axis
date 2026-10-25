// TA: совместимость контрактов (Contract Ledger) с регионами карт Twilight-Axis.
//
// После апстрим-порта (Azure-Peak PR #9627 "towner-quest-port", влит в TA через PR #1626)
// /datum/threat_region/proc/allows_quest_type() проверяет не allowed_quest_types региона,
// а список eligible_regions у прототипа квеста:
//     return proto && (region_name in proto.eligible_regions) && proto.fits_region(src)
// В eligible_regions прописаны только регионы Dun World (Azure Basin, Azure Grove, Terrorbog...).
// Регионы Rockhill (и Al-Ashur) там не упомянуты, поэтому allows_quest_type() для них
// всегда FALSE, и SSquestpool не генерирует для этих карт ни одного контракта.
//
// Этот файл после загрузки регионов карты дописывает регионы TA-карт в eligible_regions
// прототипов:
//  1) Для регионов, которых нет НИ В ОДНОМ eligible_regions (Rockhill, Al-Ashur), берутся
//     типы из их allowed_quest_types - то есть поведение как до порта. Регионы Dun World
//     не затрагиваются.
//  2) Опционально: ta_quest_region_alias - "аналог" региона Dun World. Квесты, у которых
//     в eligible_regions есть этот аналог и которых нет в стандартном пуле
//     (towner-контракты горожан и т.п.), становятся доступны и в TA-регионе.
//  3) ta_extra_threat_regions: доп. регионы карты (Mount Decapitation на Rockhill, тот же datum, что
//     на Dun World), регистрируются без правки map_adjustment_rockhill.dm.
//  4) Регионы грузятся в SSminor_mapping (init order -40), то есть ПОСЛЕ
//     SSquestpool.Initialize (init order 0), и стартовое заполнение пула там ничего не делает.
//     Здесь пул заполняется повторно, сразу после загрузки регионов.

/// Стандартные типы пула, которые регулируются allowed_quest_types региона.
GLOBAL_LIST_INIT(ta_region_pool_quest_types, list(
	QUEST_KILL_EASY,
	QUEST_CLEAR_OUT,
	QUEST_RAID,
	QUEST_BOUNTY,
	QUEST_COURIER,
	QUEST_RETRIEVAL,
	QUEST_RECOVERY,
	QUEST_NOTORIOUS_BOUNTY,
))

/datum/threat_region
	/// TA: имя региона Dun World, "аналогом" которого считается этот регион (для towner-квестов и т.п.).
	var/ta_quest_region_alias

/datum/threat_region/rockhill_basin
	ta_quest_region_alias = THREAT_REGION_AZURE_BASIN

/datum/threat_region/rockhill_bog_north
	ta_quest_region_alias = THREAT_REGION_TERRORBOG

/datum/threat_region/rockhill_bog_west
	ta_quest_region_alias = THREAT_REGION_TERRORBOG

/datum/threat_region/rockhill_bog_south
	ta_quest_region_alias = THREAT_REGION_TERRORBOG

/datum/threat_region/rockhill_bog_sunkmire
	ta_quest_region_alias = THREAT_REGION_TERRORBOG

/datum/threat_region/rockhill_woods_north
	ta_quest_region_alias = THREAT_REGION_AZURE_GROVE

/datum/threat_region/rockhill_woods_south
	ta_quest_region_alias = THREAT_REGION_AZURE_GROVE

/datum/threat_region/rockhill_outer_grove
	ta_quest_region_alias = THREAT_REGION_AZURE_GROVE

// ---------------------------------------------------------------------------
// Дополнительные регионы карт, не прописанные в map_adjustment (без правки оригинальных файлов).
// Формат: list("Имя региона" = /datum/threat_region/путь)
// ---------------------------------------------------------------------------

/datum/map_adjustment/template
	/// TA: доп. threat-регионы этой карты: list(имя = путь /datum/threat_region). Регистрируются в on_map_ready().
	var/list/ta_extra_threat_regions

// Mount Decapitation на Rockhill: тот же регион и тот же datum, что и на Dun World
// (/datum/threat_region/mount_decap, modular_twilight_axis/.../regional_threat/dun_world.dm).
// Зона /area/rogue/outdoors/mountains/decap/somewhere (z4-z5 Rockhill) наследует
// THREAT_REGION_MOUNT_DECAP от /area/rogue/outdoors/mountains/decap (mountdecap.dm:31).
// Регион уже прописан в eligible_regions прототипов, поэтому код ниже его не трогает.
/datum/map_adjustment/template/rockhill
	ta_extra_threat_regions = list(
		THREAT_REGION_MOUNT_DECAP = /datum/threat_region/mount_decap,
		// Подземье Rockhill (21 метка в /area/rogue/under/underdark*) сейчас тоже "мёртвое".
		// Чтобы включить его как на Dun World, раскомментируйте строку ниже. Побочные эффекты: в подземье
		// заработают региональные засады и рог, а экономический регион Underdark
		// (economic_region.dm:176) сможет попасть в блокаду.
		// THREAT_REGION_UNDERDARK = /datum/threat_region/underdark,
	)

/datum/controller/subsystem/regionthreat/on_map_ready()
	ta_register_extra_threat_regions()
	. = ..()
	ta_extend_quest_eligible_regions()
	ta_refill_quest_pool()

/// Добавляет ta_extra_threat_regions активной карты в шаблоны и в её список threat_regions до загрузки регионов.
/datum/controller/subsystem/regionthreat/proc/ta_register_extra_threat_regions()
	var/datum/map_adjustment/template/map = SSmapping.map_adjustment
	if(!map || !length(map.ta_extra_threat_regions))
		return
	if(!map.threat_regions)
		map.threat_regions = list()
	for(var/region_name in map.ta_extra_threat_regions)
		var/region_path = map.ta_extra_threat_regions[region_name]
		if(!ispath(region_path, /datum/threat_region))
			stack_trace("RegionThreat (TA): bad threat region path for [region_name]")
			continue
		// Не подменяем уже существующий шаблон (для Mount Decapitation он есть в regional_threat.dm:7).
		if(!GLOB.threat_region_templates[region_name])
			GLOB.threat_region_templates[region_name] = region_path
		// |= не даст дублей, если карта уже перечисляет этот регион в threat_regions.
		map.threat_regions |= region_name

/// Дописывает регионы активной карты в eligible_regions прототипов квестов.
/datum/controller/subsystem/regionthreat/proc/ta_extend_quest_eligible_regions()
	if(!length(threat_regions))
		return

	// Регионы, которые апстрим уже знает (упомянуты хоть в одном прототипе).
	var/list/upstream_regions = list()
	for(var/qtype in GLOB.quest_prototypes)
		var/datum/quest/proto = GLOB.quest_prototypes[qtype]
		if(proto?.eligible_regions)
			upstream_regions |= proto.eligible_regions

	for(var/datum/threat_region/TR as anything in threat_regions)
		if(TR.region_name in upstream_regions)
			continue // Регион Dun World - оставляем как настроил апстрим.
		var/list/added = list()
		for(var/qtype in GLOB.quest_prototypes)
			var/datum/quest/proto = GLOB.quest_prototypes[qtype]
			if(!proto)
				continue
			var/allow = FALSE
			if(qtype in GLOB.ta_region_pool_quest_types)
				allow = (qtype in TR.allowed_quest_types)
			else if(TR.ta_quest_region_alias && (TR.ta_quest_region_alias in proto.eligible_regions))
				allow = TRUE
			if(!allow)
				continue
			if(!proto.eligible_regions)
				proto.eligible_regions = list()
			proto.eligible_regions |= TR.region_name
			added += qtype
		log_world("RegionThreat (TA): [TR.region_name] -> quest types: [length(added) ? jointext(added, ", ") : "none"]")

/// Повторное стартовое заполнение пула контрактов, т.к. SSquestpool инициализируется раньше загрузки регионов.
/datum/controller/subsystem/regionthreat/proc/ta_refill_quest_pool()
	if(!SSquestpool?.initialized || !length(threat_regions))
		return
	SSquestpool.regen_kill_targets(SSquestpool.total_kill_target())
	SSquestpool.regen_fetch_targets()
	log_world("RegionThreat (TA): quest pool refilled, [length(SSquestpool.pool)] contracts.")

// Towner-контракты в preview() сверяют регион метки со СВОИМ (инстансным) списком
// eligible_regions, а не с прототипом. Подтягиваем дополненный список из прототипа.
/datum/quest/kill/recovery/towner/preview(obj/effect/landmark/quest_spawner/landmark)
	var/datum/quest/proto = GLOB.quest_prototypes[quest_type]
	if(proto && proto != src && length(proto.eligible_regions))
		eligible_regions = proto.eligible_regions.Copy()
	return ..()
