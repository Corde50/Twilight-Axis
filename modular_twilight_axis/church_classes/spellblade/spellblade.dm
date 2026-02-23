/datum/advclass/noctite_spellblade
	name = "Newmoon Spellblade"
	tutorial = "Заклинатели Новолунья известны в кругах радикальных Ноктитов как самые преданные Нок монахи. \
		По какой-то причине вы покинули свой монастырь в Зибантии и прибыли сюда, в церковь десяти, \
		поломничество это или миссия по распространению влияния пантеона во главе Нок? Кроме вас точно никто сказать не сможет. \
		Хоть вы фанатичный Ноктит, но вы пришли с миром поэтому терпимо относитесь к местным порядкам, сохраняя недоверие к Астраритам \
		Несмотря на местных служителей церкви Десяти, вы знаете и крайне убеждены что Нок не требует поклонения и с чем она одарила вас чем то более уникальным, \
		за свою верное служение и познание в аркане вы получили доступ к арканному оружию.\n \
		Вам недоступны чудеса, но взамен вы получили доступ к аркане, и не смотря на то какое оружие свет Нок не сотворил бы для вас, вы являетесь экспертом в нем."
	outfit = /datum/outfit/job/roguetown/spellblade
	category_tags = list(CTAG_TEMPLAR)
	subclass_languages = list(/datum/language/grenzelhoftian, /datum/language/celestial, /datum/language/elvish)
	traits_applied = list(TRAIT_MEDIUMARMOR, TRAIT_NIGHT_OWL, TRAIT_ARCYNE_T3, TRAIT_NOC_LIGHT_BLESSING)
	subclass_spellpoints = 12
	maximum_possible_slots = 1
	subclass_stats = list(
		STATKEY_WIL = 1,
		STATKEY_INT = 5,
	)
	subclass_skills = list(
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/magic/arcane = SKILL_LEVEL_JOURNEYMAN
	)

	subclass_stashed_items = list(
		"Накидка Новолунья" = /obj/item/clothing/cloak/half/newmoon,
	)

	allowed_patrons = list(/datum/patron/divine/noc)

/datum/outfit/job/roguetown/spellblade
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver/noc
	head = /obj/item/clothing/head/roguetown/roguehood/newmoon
	armor = /obj/item/clothing/suit/roguetown/armor/leather/newmoon_jacket
	id = /obj/item/clothing/ring/gold
	backl = /obj/item/storage/backpack/rogue/satchel
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/newmoon
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	mask = /obj/item/clothing/mask/rogue/ragmask/newmoon
	backpack_contents = list(
		/obj/item/lockpickring/mundane = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/keyring/acolyte = 1,
		/obj/item/book/spellbook = 1
		)

/datum/outfit/job/roguetown/spellblade/pre_equip(mob/living/carbon/human/H)
	..()

	H.cmode_music = 'modular_twilight_axis/church_classes/sound/cmode_spellblade.ogg'
	ADD_TRAIT(H, TRAIT_CLERGY_TA, TRAIT_GENERIC)

	if(H.mind)
		SStreasury.give_money_account(ECONOMIC_LOWER_MIDDLE_CLASS, H, "Church Funding.")

	var/obj/effect/proc_holder/spell/targeted/spellblade_select_weapon/select_weapon 
	select_weapon = new /obj/effect/proc_holder/spell/targeted/spellblade_select_weapon

	var/obj/effect/proc_holder/spell/invoked/spellblade_summon_weapon/summon_weapon
	summon_weapon = new /obj/effect/proc_holder/spell/invoked/spellblade_summon_weapon
	summon_weapon.weapon_select = select_weapon
	select_weapon.summon_weapon = summon_weapon
	
	H.AddSpell(select_weapon)
	H.AddSpell(summon_weapon)
	H.AddSpell(new /obj/effect/proc_holder/spell/self/noctite_fortify)
