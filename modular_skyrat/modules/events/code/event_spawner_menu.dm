/datum/event_spawner_instance
	var/id
	var/list/species_whitelist = list()
	var/list/gender_whitelist = list()
	var/list/ckey_whitelist = list()
	var/used_outfit
	var/job_name = "Job Name"
	var/gets_loadout = TRUE
	var/list/access_override = list()
	var/headset_override
	var/flavor_text = "Flavor Text to be displayed"
	var/list/additional_equipment = list()
	var/disappear_after_spawn = FALSE

	var/show_outfit_equipment = FALSE

/datum/event_spawner_instance/New(_id, template_id)
	id = _id

/datum/event_spawner_instance/proc/CreateSpawner(turf/spawn_loc)
	var/obj/character_event_spawner/CES = new(spawn_loc)
	if(length(species_whitelist))
		CES.species_whitelist = species_whitelist.Copy()
	if(length(gender_whitelist))
		CES.gender_whitelist = gender_whitelist.Copy()
	if(length(ckey_whitelist))
		CES.ckey_whitelist = ckey_whitelist.Copy()
	if(length(access_override))
		CES.access_override = access_override.Copy()
	if(length(additional_equipment))
		CES.additional_equipment = additional_equipment.Copy()
	CES.used_outfit = used_outfit
	CES.job_name = job_name
	CES.gets_loadout = gets_loadout
	CES.headset_override = headset_override
	CES.flavor_text = flavor_text
	CES.disappear_after_spawn = disappear_after_spawn


/datum/event_spawner_manager
	var/next_id = 0
	var/list/managed_instances = list()
	var/radio_typecache

/datum/event_spawner_manager/New()
	radio_typecache = typecacheof(/obj/item/radio/headset)

/datum/event_spawner_manager/proc/ShowPanel(mob/user, panel_id)
	if(!user || !user.client)
		return
	var/list/dat = list("")
	if(panel_id)
		var/datum/event_spawner_instance/ESI = managed_instances["[panel_id]"]
		if(!ESI)
			return
		dat += "<a href='?src=[REF(src)];inst_pref=return;id=[ESI.id]'>Return</a><HR>"
		dat += "<a href='?src=[REF(src)];inst_pref=job_name;id=[ESI.id]'>Job Name:</a> <b>[ESI.job_name]</b>"
		dat += "<BR><font color='#777777'><i>This will appear on the person's ID</i></font>"
		dat += "<BR><a href='?src=[REF(src)];inst_pref=flavor_text;id=[ESI.id]'>Flavor Text:</a> <i>[ESI.flavor_text]</i>"
		dat += "<BR><font color='#777777'><i>The player will be greeted with the flavor text. Tell him who his supervisors are, if any.</i></font>"
		var/outfit_name
		var/datum/outfit/OU
		if(ESI.used_outfit)
			if(ESI.used_outfit == "Naked")
				outfit_name = "Naked"
			else
				OU = ESI.used_outfit
				outfit_name = initial(OU.name)
		dat += "<BR>Allow Loadout: <a href='?src=[REF(src)];inst_pref=loadout;id=[ESI.id]'>[ESI.gets_loadout ? "Yes" : "No"]</a>"
		dat += "<BR><font color='#777777'><i>Whether loadout from prefs is allowed.</i></font>"
		dat += "<BR><a href='?src=[REF(src)];inst_pref=used_outfit;id=[ESI.id]'>Used Outfit:</a> [outfit_name]"
		dat += "<BR><font color='#777777'><i>Which outfit is used for the spawned player. Below you can preview contents of the selected one.</i></font>"
		if(ESI.used_outfit)
			dat += "<BR><a href='?src=[REF(src)];inst_pref=show_outfit_equipment;id=[ESI.id]'>[ESI.show_outfit_equipment ? "Hide outfit equipment" : "Show outfit equipment"]</a>"
		if(OU && ESI.show_outfit_equipment)
			dat += "<HR><b>Outfit equipment:</b>"
			var/obj/item/display = initial(OU.uniform)
			if(display)
				dat += "<BR>Uniform: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.suit)
			if(display)
				dat += "<BR>Suit: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.belt)
			if(display)
				dat += "<BR>Belt: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.gloves)
			if(display)
				dat += "<BR>Gloves: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.head)
			if(display)
				dat += "<BR>Head: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.mask)
			if(display)
				dat += "<BR>Mask: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.neck)
			if(display)
				dat += "<BR>Neck: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.ears)
			if(display)
				dat += "<BR>Ears: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.glasses)
			if(display)
				dat += "<BR>Glasses: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.id)
			if(display)
				dat += "<BR>Id: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.l_pocket)
			if(display)
				dat += "<BR>Left pocket: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.r_pocket)
			if(display)
				dat += "<BR>Right pocket: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			display = initial(OU.back)
			if(display)
				dat += "<BR>Back: [initial(display.name)]<font color='#777777'> - ([display])</font>"
			var/list/backpack_cont = initial(OU.backpack_contents)
			if(backpack_cont)
				dat += "<BR>+Things in the backpack (due to coding limitations, those cant be established. See the code for the outfit to know more.)"

		dat += "<HR>"
		dat += "<font color='#777777'><i>Here you can add extra equipment on top of loadout, if possible those will be auto equipped.</i></font>"
		dat += "<BR><font color='#777777'><i>You HAVE to add them as typed paths('/obj/item/gun/energy/e_gun'). Search in Game Panel to find desired paths.</i></font>"
		dat += "<BR><b>Additional equipment: <a href='?src=[REF(src)];inst_pref=add_equip;id=[ESI.id]'>Add</a></b>"
		for(var/eq in ESI.additional_equipment)
			var/obj/item/equip = eq
			dat += "<BR><a href='?src=[REF(src)];inst_pref=remove_equip;equip=[eq];id=[ESI.id]'>[initial(equip.name)]</a><font color='#777777'> - ([eq])</font>"
		dat += "<HR>"
		dat += "<font color='#777777'><i>Outfits limit on what airlocks can someone access, or what headset and frequences they have. Here you can edit those things</i></font>"
		dat += "<BR><b>Access overrides: </b>"
		for(var/access_key in ESI.access_override)
			dat += "<a href='?src=[REF(src)];inst_pref=remove_access;id=[ESI.id];access=[access_key]'>[access_key]</a>"
		dat += " <- <a href='?src=[REF(src)];inst_pref=add_access;id=[ESI.id]'>Add</a>"
		dat += "<BR><font color='#777777'><i>Add access in NUMBERS. If no numbers are in the list, then the access will not be overriden. If you want to remove all access, add only a 0</i></font>"
		dat += "<BR><font color='#777777'><i>See '/code/__DEFINES/access.dm' for an access list. (401-Faction Public, 402-Faction Crew, 403-Faction Command)</i></font>"
		dat += "<BR><b>Headset override: </b>"
		if(ESI.headset_override)
			var/obj/item/headset = ESI.headset_override
			dat += "<a href='?src=[REF(src)];inst_pref=remove_headset;id=[ESI.id]'>[initial(headset.name)]</a><font color='#777777'> - ([ESI.headset_override])</font>"
		dat += " <- <a href='?src=[REF(src)];inst_pref=set_headset;id=[ESI.id]'>Set</a>"
		dat += "<BR><font color='#777777'><i>Here you can override the headset, make sure to pick one which has the proper key with radio frequences for your role</i></font>"
		dat += "<HR>"
		dat += "<b>Allowed Species:</b>"
		for(var/spec in ESI.species_whitelist)
			dat += "<a href='?src=[REF(src)];inst_pref=remove_species;id=[ESI.id];species=[spec]'>[spec]</a>"
		dat += " <- <a href='?src=[REF(src)];inst_pref=add_species;id=[ESI.id]'>Add</a>"
		dat += "<BR><font color='#777777'><i>If no species are in the list, then any species can join as this role.</i></font>"
		dat += "<BR><b>Allowed Genders:</b>"
		for(var/gend in ESI.gender_whitelist)
			dat += "<a href='?src=[REF(src)];inst_pref=remove_gender;id=[ESI.id];gender=[gend]'>[gend]</a>"
		dat += " <- <a href='?src=[REF(src)];inst_pref=add_gender;id=[ESI.id]'>Add</a>"
		dat += "<BR><font color='#777777'><i>If no genders are in the list, then any gender can join as this role.</i></font>"
		dat += "<BR><b>Allowed CKEYs:</b>"
		for(var/ckey in ESI.ckey_whitelist)
			dat += "<a href='?src=[REF(src)];inst_pref=remove_ckey;id=[ESI.id];ckey=[ckey]'>[ckey]</a>"
		dat += " <- <a href='?src=[REF(src)];inst_pref=add_ckey;id=[ESI.id]'>Add</a>"
		dat += "<BR><font color='#777777'><i>If no ckeys are in the list, then any ckey can join as this role.</i></font>"
		dat += "<BR>Spawner disappears after spawn: <a href='?src=[REF(src)];inst_pref=disappear_after_spawn;id=[ESI.id]'>[ESI.disappear_after_spawn ? "Yes" : "No"]</a>"
		dat += "<HR><center><a href='?src=[REF(src)];inst_pref=make_spawner;id=[ESI.id]'>Create spawner on current location</a></center>"
		//Buttons for easy override for the faction stuff (for access and headset keys)

	else
		dat += "<i>Here you add and configure spawners. People will be able to join to them using their pre-made character in preferences.</i>"
		dat += "<table align='center'; width='100%'; style='background-color:#13171C'>"
		dat += "<tr><td width=5%></td><td width=20%></td><td width=60%></td><td width=10%></td><td width=5%></td></tr>"
		var/even = FALSE
		for(var/key in managed_instances)
			even = !even
			var/bc_col = even ? "#13171C" : "#23272C"
			var/datum/event_spawner_instance/ESI = managed_instances[key]
			var/desc = ESI.flavor_text
			if(length(desc) > 40)
				desc = "[copytext_char(desc, 1, 57)]..."
			dat += "<tr style='background-color:[bc_col]'><td>#[key]</td><td><b>[ESI.job_name]</b></td><td><i>[desc]</i></td><td><a href='?src=[REF(src)];pref=configure_instance;id=[key]'>Configure</a></td><td><a href='?src=[REF(src)];pref=clone_instance;id=[key]'>Clone</a></td></tr>"
		dat += "<tr style='background-color:#33373C'><td>*</td><td><a href='?src=[REF(src)];pref=create_new_instance'>Create new</a></td><td></td><td></td><td></td></tr>"
		dat += "</table>"

	winshow(usr, "event_spawn_window", TRUE)
	var/datum/browser/popup = new(usr, "event_spawn_window", "<div align='center'>Event Spawners</div>", 800, 700)
	popup.set_content(dat.Join())
	popup.open(FALSE)
	onclose(usr, "event_spawn_window", src)

/datum/event_spawner_manager/Topic(href, href_list)
	if(href_list["inst_pref"])
		var/numb = text2num(href_list["id"])
		var/datum/event_spawner_instance/ESI = managed_instances["[numb]"]
		if(!ESI)
			ShowPanel(usr, null)
			return
		switch(href_list["inst_pref"])
			if("return")
				ShowPanel(usr, null)
				return
			if("job_name")
				var/msg = input(usr, "Set the job name of this spawner.", "Job name", ESI.job_name) as text|null
				if(msg)
					ESI.job_name = msg
			if("flavor_text")
				var/msg = input(usr, "Set the flavor text of this spawner.", "Flavor Text", ESI.flavor_text) as message|null
				if(msg)
					ESI.flavor_text = msg
			if("used_outfit")
				var/dresscode = usr.client.robust_dress_shop()
				if(dresscode)
					ESI.used_outfit = dresscode
			if("show_outfit_equipment")
				ESI.show_outfit_equipment = !ESI.show_outfit_equipment
			if("loadout")
				ESI.gets_loadout = !ESI.gets_loadout
			if("disappear_after_spawn")
				ESI.disappear_after_spawn = !ESI.disappear_after_spawn
			if("add_ckey")
				var/msg = input(usr, "Add allowed CKEY to the spawner.", "Add CKEY", "") as text|null
				if(msg)
					ESI.ckey_whitelist += msg
			if("add_species")
				var/result = input(usr, "Select a species", "Add species") as null|anything in GLOB.roundstart_races
				if(result)
					ESI.species_whitelist += result
			if("add_gender")
				var/result = input(usr, "Select a gender", "Add Gender") as null|anything in list("male", "female", "plural")
				if(result)
					ESI.gender_whitelist += result
			if("add_access")
				var/msg = input(usr, "Add access type to the spawner(as number)", "Add Access", "") as num|null
				if(msg != null)
					if(!(msg in ESI.access_override))
						ESI.access_override += msg
			if("add_equip")
				var/msg = input(usr, "Add an equipment piece, as typed path (ex. '/obj/item/gun/energy/e_gun').", "Add equipment", "") as text|null
				if(!isnull(msg))
					var/typed = text2path(msg)
					if(!isnull(typed))
						ESI.additional_equipment += typed
			if("set_headset")
				var/result = input(usr, "Select a headset", "Set Headset") as null|anything in radio_typecache
				if(result)
					ESI.headset_override = result
			if("remove_ckey")
				var/ckey_to_rem = href_list["ckey"]
				ESI.ckey_whitelist -= ckey_to_rem
			if("remove_species")
				var/spec_to_rem = href_list["species"]
				ESI.species_whitelist -= spec_to_rem
			if("remove_gender")
				var/gend_to_rem = href_list["gender"]
				ESI.gender_whitelist -= gend_to_rem
			if("remove_access")
				var/access_to_rem = text2num(href_list["access"])
				ESI.access_override -= access_to_rem
			if("remove_headset")
				ESI.headset_override = null
			if("remove_equip")
				var/type_to_rem = text2path(href_list["equip"])
				ESI.additional_equipment -= type_to_rem
			if("make_spawner")
				var/turfed = get_turf(usr)
				ESI.CreateSpawner(turfed)
				message_admins("[ADMIN_LOOKUPFLW(usr)] created an event character spawner for [ESI.job_name].")
		ShowPanel(usr, numb)
	if(href_list["pref"])
		switch(href_list["pref"])
			if("create_new_instance")
				next_id++
				var/datum/event_spawner_instance/ESI = new(next_id)
				managed_instances["[next_id]"] = ESI
			if("configure_instance")
				var/numb = text2num(href_list["id"])
				var/datum/event_spawner_instance/ESI = managed_instances["[numb]"]
				if(ESI)
					ShowPanel(usr, numb)
					return
		ShowPanel(usr, null)
		return

/client/proc/admin_open_event_spawners_menu()
	set category = "Admin.Events"
	set name = "Event Spawners Menu"

	if(!check_rights(R_ADMIN))
		return

	var/datum/event_spawner_manager/ESM = GLOB.event_spawner_manager
	ESM.ShowPanel(usr, null)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Event Spawner Menu") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
