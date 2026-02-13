/datum/erp_sex_ui_tab/editor
	parent_type = /datum/erp_sex_ui_tab
	var/dirty_data = TRUE
	var/list/cached_payload

/datum/erp_sex_ui_tab/editor/build()
	if(!dirty_data && islist(cached_payload))
		return cached_payload

	dirty_data = FALSE

	var/list/D = list(
		"templates" = list(),
		"custom_actions" = list()
	)

	var/datum/erp_controller/C = ui.controller
	if(!C)
		cached_payload = D
		return cached_payload

	for(var/path in SSerp.actions)
		var/datum/erp_action/A = SSerp.actions[path]
		if(!A || A.abstract)
			continue

		D["templates"] += list(list(
			"type" = "[path]",
			"name" = A.name,
			"fields" = A.export_editor_fields()
		))

	for(var/datum/erp_action/A in C.owner.custom_actions)
		D["custom_actions"] += list(list(
			"id" = A.id,
			"name" = A.name,
			"fields" = A.export_editor_fields()
		))

	cached_payload = D
	return cached_payload

/datum/erp_sex_ui_tab/editor/proc/mark_dirty()
	dirty_data = TRUE

/datum/erp_sex_ui_tab/editor/handle_ui_intent(action, list/params)
	var/datum/erp_controller/C = ui.controller
	if(!C)
		return FALSE

	switch(action)
		if("create_action")
			C.create_custom_action(ui.actor, params)
			mark_dirty()
			ui.request_update()
			return TRUE

		if("update_action")
			C.update_custom_action(ui.actor, params)
			mark_dirty()
			ui.request_update()
			return TRUE

		if("delete_action")
			C.delete_custom_action(ui.actor, params["id"])
			mark_dirty()
			ui.request_update()
			return TRUE

	return FALSE
