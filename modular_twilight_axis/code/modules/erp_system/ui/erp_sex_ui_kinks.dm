/datum/erp_sex_ui_tab/kinks
	parent_type = /datum/erp_sex_ui_tab

/datum/erp_sex_ui_tab/kinks/build()
	var/datum/erp_controller/C = ui.controller
	if(!C)
		return list("entries" = list())

	var/mob/living/subject = ui.actor
	if(C.active_partner?.physical)
		subject = C.active_partner.physical

	return C.get_kinks_ui(subject, C.active_partner)

/datum/erp_sex_ui_tab/kinks/handle_ui_intent(action, list/params)
	var/datum/erp_controller/C = ui.controller
	if(!C)
		return FALSE

	switch(action)
		if("set_kink_pref")
			var/mob/living/subject = ui.actor
			if(C.active_partner?.physical)
				subject = C.active_partner.physical

			if(!C.set_kink_pref(subject, params["type"], text2num(params["value"])))
				return FALSE

			ui.request_update()
			return TRUE

	return FALSE
