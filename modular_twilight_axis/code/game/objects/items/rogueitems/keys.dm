/obj/item/roguekey/butcher
	name = "butcher key"
	desc = "This is a rusty key that'll open butcher doors."
	icon_state = "rustkey"
	lockid = "butcher"

/obj/item/roguekey/sheriff
	name = "sheriff's key"
	desc = "This key belongs to the sheriff of town guard."
	icon_state = "cheesekey"
	lockid = "sheriff"

/obj/item/roguekey/roomvii
	name = "room VII key"
	desc = "The key to the seventh room."
	icon_state = "brownkey"
	lockid = "roomvii"

/obj/item/roguekey/roomviii
	name = "room VIII key"
	desc = "The key to the eighth room."
	icon_state = "brownkey"
	lockid = "roomviii"

/obj/item/roguekey/mansion
	name = "Rockhill Mansion"
	desc = "This fancy key opens the doors of the Rockhill mansion."
	icon_state = "cheesekey"
	lockid = "rockhill_mansion"

/obj/item/roguekey/garrison/Initialize()
	. = ..()
	if(SSmapping.config.map_name == "Rockhill_TA")
		name = "garisson key"
		desc = "This key opens many garrison doors in manor."

/obj/item/roguekey/walls/Initialize()
	. = ..()
	if(SSmapping.config.map_name == "Rockhill_TA")
		name = "citywatch key"
		desc = "This key opens the walls and gatehouse of the city."
		lockid = "walls"

/obj/item/roguekey/justiciary/Initialize()
	. = ..()
	if(SSmapping.config.map_name == "Rockhill_TA")
		name = "marshal key"
		desc = "This key opens the marshal office."
		lockid = "marshall"

/obj/item/roguekey/university/Initialize()
	. = ..()
	if(SSmapping.config.map_name == "Rockhill_TA")
		name = "magician tower key"
		desc = "This key should open anything within the Magician tower."

/obj/item/roguekey/warden/Initialize()
	. = ..()
	if(SSmapping.config.map_name == "Rockhill_TA")
		name = "vanguard key"
		desc = "This key opens doors in vanguard stronghold."

/obj/item/roguekey/inquisitionmanor/Initialize()
	. = ..()
	if(SSmapping.config.map_name == "Rockhill_TA")
		name = "inquisition ship key"
		desc = "This key opens doors in inquisition ship."
