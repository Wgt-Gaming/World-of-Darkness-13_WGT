/mob/living/carbon
	var/last_gnosis_buff = 0
	var/last_rage_penis = 0
	var/last_veil_restore = 0

/mob/living/carbon/werewolf/Life()
	update_icons()
	update_rage_hud()
	return..()

/mob/living/carbon/Life()
	. = ..()
	if(isgarou(src) || iswerewolf(src))
		if(key && stat <= 3)
			var/datum/preferences/P = GLOB.preferences_datums[ckey(key)]
			if(P)
				if(P.masquerade != masquerade)
					P.masquerade = masquerade
					P.save_preferences()
					P.save_character()


		if(stat != DEAD)
			var/gaining_rage = TRUE
			for(var/obj/structure/werewolf_totem/W in GLOB.totems)
				if(W)
					if(W.totem_health)
						if(W.tribe == auspice.tribe)
							if(get_area(W) == get_area(src) && client)
								gaining_rage = FALSE
								if(last_gnosis_buff+300 < world.time)
									last_gnosis_buff = world.time
									adjust_gnosis(1, src, TRUE)
			if(iscrinos(src))
				if(auspice.base_breed == "Crinos")
					gaining_rage = FALSE
			//else if(auspice.rage == 0) //! [ChillRaccoon] - FIXME
			//	transformator.trans_gender(src, auspice.base_breed)
			if(islupus(src))
				if(auspice.base_breed == "Lupus")
					gaining_rage = FALSE
			//else if(auspice.rage == 0)
			//	transformator.trans_gender(src, auspice.base_breed)
			if(ishuman(src))
				if(auspice.base_breed == "Homid")
					gaining_rage = FALSE
			//else if(auspice.rage == 0)
			//	transformator.trans_gender(src, auspice.base_breed)

			if(gaining_rage && client)
				if(last_rage_penis+600 < world.time)
					last_rage_penis = world.time
					adjust_rage(1, src, TRUE)

			if(masquerade == 0)
				var/special_role_name
				if(mind)
					if(mind.special_role)
						var/datum/antagonist/A = mind.special_role
						special_role_name = A.name
				if(!is_special_character(src) || special_role_name == "Ambitious")
					if(auspice.gnosis)
						to_chat(src, "<span class='warning'>My Veil is too low to connect with the spirits of Umbra!</span>")
						adjust_gnosis(-1, src, FALSE)

			if(auspice.rage >= 9)
				if(!in_frenzy)
					if(last_frenzy_check+400 <= world.time)
						last_frenzy_check = world.time
						rollfrenzy()
			if(istype(get_area(src), /area/vtm/interior/penumbra))
				if(last_veil_restore+600 < world.time)
					last_veil_restore = world.time
					adjust_veil(1)

/mob/living/carbon/werewolf/crinos/Life()
	. = ..()
	if(CheckEyewitness(src, src, 5, FALSE))
		adjust_veil(-1)

/mob/living/carbon/werewolf/check_breath(datum/gas_mixture/breath)
	return

/mob/living/carbon/werewolf/handle_status_effects()
	..()
	//natural reduction of movement delay due to stun.
	if(move_delay_add > 0)
		move_delay_add = max(0, move_delay_add - rand(1, 2))

/mob/living/carbon/werewolf/handle_changeling()
	return

/mob/living/carbon/werewolf/handle_fire()//Aliens on fire code
	. = ..()
	if(.) //if the mob isn't on fire anymore
		return
	adjust_bodytemperature(BODYTEMP_HEATING_MAX) //If you're on fire, you heat up!

/mob/living/carbon
	var/last_veil_adjusting = 0

/mob/living/carbon/proc/adjust_veil(var/amount)
	if(!GLOB.canon_event)
		return
	if(last_veil_adjusting+100 >= world.time)
		return
	if(amount > 0)
		if(HAS_TRAIT(src, TRAIT_VIOLATOR))
			return
	if(istype(get_area(src), /area/vtm))
		var/area/vtm/V = get_area(src)
		if(V.zone_type != "masquerade")
			return
	last_veil_adjusting = world.time
	var/special_role_name
	if(mind)
		if(mind.special_role)
			var/datum/antagonist/A = mind.special_role
			special_role_name = A.name
	if(!is_special_character(src) || special_role_name == "Ambitious")
		if(amount < 0)
			if(masquerade > 0)
				SEND_SOUND(src, sound('code/modules/ziggers/sounds/veil_violation.ogg', 0, 0, 75))
				to_chat(src, "<span class='boldnotice'><b>VEIL VIOLATION</b></span>")
				masquerade = max(0, masquerade+amount)
		if(amount > 0)
			if(masquerade < 5)
				SEND_SOUND(src, sound('code/modules/ziggers/sounds/humanity_gain.ogg', 0, 0, 75))
				to_chat(src, "<span class='boldnotice'><b>VEIL REINFORCEMENT</b></span>")
				masquerade = max(0, masquerade-amount)