/datum/map_template/automap_template
	name = "Automap Template"
	keep_cached_map = TRUE
	var/required_map
	var/affects_builtin_map
	var/turf/load_turf
	var/load_x
	var/load_y
	var/load_z

/datum/map_template/automap_template/New(path, rename, incoming_required_map, incoming_coordinates)
	. = ..(path, rename, cache = TRUE)

	if(!incoming_required_map || !islist(incoming_coordinates) || (length(incoming_coordinates) != 3))
		return

	required_map = incoming_required_map
	affects_builtin_map = incoming_required_map == AUTOMAPPER_MAP_BUILTIN

	load_x = text2num("[incoming_coordinates[1]]")
	load_y = text2num("[incoming_coordinates[2]]")
	load_z = text2num("[incoming_coordinates[3]]")

/datum/map_template/automap_template/proc/resolve_load_turf()
	if(load_turf)
		return load_turf
	load_turf = locate(load_x, load_y, load_z)
	return load_turf

/datum/map_template
	var/depth = 1

/datum/map_template/preload_size(path, cache = FALSE)
	var/datum/parsed_map/parsed = new(file(path))
	var/bounds = parsed?.bounds
	if(bounds)
		width  = (bounds[MAP_MAXX] - bounds[MAP_MINX] + 1)
		height = (bounds[MAP_MAXY] - bounds[MAP_MINY] + 1)
		depth  = (bounds[MAP_MAXZ] - bounds[MAP_MINZ] + 1)

		if(cache)
			cached_map = parsed
	return bounds

/datum/map_template/get_affected_turfs(turf/T, centered = FALSE)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(width/2), placement.y - round(height/2), placement.z)
		if(corner)
			placement = corner

	var/x2 = placement.x + width  - 1
	var/y2 = placement.y + height - 1
	var/z2 = placement.z + depth  - 1

	return block(placement, locate(x2, y2, z2))

/datum/map_template/proc/nuke_placement_area(turf/T, centered = FALSE, turf/empty_type = /turf/open/transparent/openspace)
	var/list/turfs = get_affected_turfs(T, centered)
	for(var/turf/iter as anything in turfs)
		for(var/atom/movable/A as anything in iter.contents)
			qdel(A, force = TRUE)

		if(iter.type == empty_type)
			continue

		var/bt = initial(empty_type.baseturfs)
		if(islist(bt))
			bt = bt[1]

		iter.ChangeTurf(empty_type, bt, CHANGETURF_FORCEOP)
