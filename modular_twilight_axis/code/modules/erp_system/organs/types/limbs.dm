/datum/erp_sex_organ/hand
	erp_organ_type = SEX_ORGAN_HANDS
	count_to_action = 2
	active_arousal = 0.5
	passive_arousal = 0.1
	active_pain = 0.1
	passive_pain = 0.1

/datum/erp_sex_organ/legs
	erp_organ_type = SEX_ORGAN_LEGS
	count_to_action = 2
	active_arousal = 0.5
	passive_arousal = 0.1
	active_pain = 0.1
	passive_pain = 0.1

/datum/erp_sex_organ/tail
	erp_organ_type = SEX_ORGAN_TAIL
	active_arousal = 0.5
	passive_arousal = 0.1
	active_pain = 0.1
	passive_pain = 0.1

/datum/erp_sex_organ/body
	erp_organ_type = SEX_ORGAN_BODY
	active_arousal = 0.2
	passive_arousal = 0.6
	passive_pain = 0.4
	active_pain = 0.1

/obj/item/organ/tail/Insert(...)
	if(!sex_organ)
		sex_organ = new /datum/erp_sex_organ/tail(src)
