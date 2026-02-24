// code/controllers/subsystem/automapper_subsystem.dm
#define INIT_ORDER_AUTOMAPPER 88

GLOBAL_LIST_EMPTY(automapper_blacklisted_turfs)

SUBSYSTEM_DEF(automapper)
	name = "Automapper"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_AUTOMAPPER
	var/config_file = "_maps/twilight_axis/automapper.toml"
	var/loaded_config
	var/list/preloaded_map_templates = list()

/datum/controller/subsystem/automapper/Initialize()
	var/raw = rustg_read_toml_file(config_file)

	if(!raw)
		CRASH("Automapper: TOML returned null for [config_file]")

	if(islist(raw) && raw["templates"])
		loaded_config = raw
		return SS_INIT_SUCCESS

	if(islist(raw) && raw["success"])
		if(!raw["success"])
			CRASH("Automapper TOML error: [raw["content"]]")

		var/list/decoded = json_decode(raw["content"])
		if(!islist(decoded))
			CRASH("Automapper: Failed to decode TOML content from [config_file]")

		loaded_config = decoded
		return SS_INIT_SUCCESS

	CRASH("Automapper: Unknown TOML format for [config_file]")

/datum/controller/subsystem/automapper/proc/preload_templates_from_toml(map_names)
	if(!islist(map_names))
		map_names = list(map_names)

	var/list/main_map_files = islist(SSmapping.config.map_file) ? SSmapping.config.map_file : list(SSmapping.config.map_file)

	for(var/template in loaded_config["templates"])
		var/selected_template = loaded_config["templates"][template]
		var/required_map = selected_template["required_map"]

		var/requires_builtin = (required_map == AUTOMAPPER_MAP_BUILTIN) && (LAZYLEN(main_map_files & map_names) || (LAZYLEN(map_names) == 1 && (map_names[1] in main_map_files)))
		if(!requires_builtin && !(required_map in map_names))
			continue

		var/list/coordinates = selected_template["coordinates"]
		if(LAZYLEN(coordinates) != 3)
			CRASH("Invalid coordinates for automap template [template]!")

		if(!LAZYLEN(selected_template["map_files"]))
			CRASH("Could not find any valid map files for automap template [template]!")

		var/map_file = selected_template["directory"] + pick(selected_template["map_files"])
		if(!fexists(map_file))
			CRASH("[template] could not find map file [map_file]!")

		var/datum/map_template/automap_template/map = new(map_file, template, required_map, coordinates)
		preloaded_map_templates += map

/datum/controller/subsystem/automapper/proc/load_templates_from_cache(map_names)
	if(!islist(map_names))
		map_names = list(map_names)

	var/list/main_map_files = islist(SSmapping.config.map_file) ? SSmapping.config.map_file : list(SSmapping.config.map_file)

	for(var/datum/map_template/automap_template/iterating_template as anything in preloaded_map_templates)
		if(iterating_template.affects_builtin_map && (LAZYLEN(main_map_files & map_names) || (LAZYLEN(map_names) == 1 && (map_names[1] in main_map_files))))
			iterating_template.resolve_load_turf()
			if(iterating_template.load_turf)
				for(var/turf/old_turf as anything in iterating_template.get_affected_turfs(iterating_template.load_turf, FALSE))
					init_contents(old_turf)
		else if(!(iterating_template.required_map in map_names))
			continue

		iterating_template.resolve_load_turf()
		if(!iterating_template.load_turf)
			CRASH("Automapper: locate failed for [iterating_template.name] at [iterating_template.load_x],[iterating_template.load_y],[iterating_template.load_z] (required_map=[iterating_template.required_map]) world=[world.maxx]x[world.maxy]x[world.maxz]")

		iterating_template.nuke_placement_area(iterating_template.load_turf, FALSE, /turf/open/transparent/openspace)

		if(iterating_template.load(iterating_template.load_turf, FALSE))
			log_world("AUTOMAPPER: Successfully loaded map template [iterating_template.name] at [iterating_template.load_turf.x], [iterating_template.load_turf.y], [iterating_template.load_turf.z]!")

/datum/controller/subsystem/automapper/proc/init_contents(atom/parent)
	var/static/list/mapload_args = list(TRUE)
	var/static/list/type_blacklist = typecacheof(list())

	var/previous_initialized_value = SSatoms.initialized
	SSatoms.initialized = INITIALIZATION_INNEW_MAPLOAD

	for(var/atom/atom_to_init as anything in parent.get_all_contents_ignoring(type_blacklist) - parent)
		if(atom_to_init.flags_1 & INITIALIZED_1)
			continue
		SSatoms.InitAtom(atom_to_init, FALSE, mapload_args)

	SSatoms.initialized = previous_initialized_value

	for(var/atom/atom_to_del as anything in parent.get_all_contents() - parent)
		qdel(atom_to_del, TRUE)

/datum/controller/subsystem/automapper/proc/has_turf_noop(datum/map_template/map, x, y)
	if(!map?.cached_map)
		CRASH("Automapper: cached_map is null for [map] (path=[map.original_path])")
	var/datum/grid_set/map_row = map.cached_map.gridSets[x + 1]
	var/modelID = map_row.gridLines[map.height - y]
	var/model = map.cached_map.grid_models[modelID]
	return findtextEx(model, "/turf/template_noop,\n")

/datum/controller/subsystem/automapper/proc/get_turf_blacklists(map_names)
	if(!map_names)
		return list()

	if(!islist(map_names))
		map_names = list(map_names)

	var/list/blacklisted_turfs = list()

	for(var/datum/map_template/automap_template/iterating_template as anything in preloaded_map_templates)
		if(!(iterating_template.required_map in map_names))
			continue

		iterating_template.resolve_load_turf()
		if(!iterating_template.load_turf)
			continue

		var/base_x = iterating_template.load_turf.x
		var/base_y = iterating_template.load_turf.y

		for(var/turf/blacklisted_turf as anything in iterating_template.get_affected_turfs(iterating_template.load_turf, FALSE))
			if(has_turf_noop(iterating_template, blacklisted_turf.x - base_x, blacklisted_turf.y - base_y))
				continue
			blacklisted_turfs[blacklisted_turf] = TRUE

	return blacklisted_turfs

