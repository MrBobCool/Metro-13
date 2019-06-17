//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/var/list/req_access = list()

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	if(!istype(M))
		return 0
	return check_access_list(M.GetAccess())

/atom/movable/proc/GetAccess()
	. = list()
	var/obj/item/weapon/card/id/id = GetIdCard()
	if(id)
		. += id.GetAccess()
	/*
	if(maint_all_access)
		. |= access_maint_tunnels
	*/
/atom/movable/proc/GetIdCard()
	return null

/obj/proc/check_access(obj/item/I)
	return check_access_list(I ? I.GetAccess() : list())

/obj/proc/check_access_list(var/list/L)
	if(!req_access)
		req_access = list()
	if(!istype(L, /list))
		return 0
	return has_access(req_access, L)

/proc/has_access(var/list/req_access, var/list/accesses)
	for(var/req in req_access)
		if(islist(req))
			var/found = FALSE
			for(var/req_one in req)
				if(req_one in accesses)
					found = TRUE
					break
			if(!found)
				return FALSE
		else if(!(req in accesses)) //doesn't have this access
			return FALSE
	return TRUE

//Checks if the access (constant or list) is contained in one of the entries of access_patterns, a list of lists.
/proc/has_access_pattern(list/access_patterns, access)
	if(!islist(access))
		access = list(access)
	for(var/access_pattern in access_patterns)
		if(has_access(access_pattern, access))
			return 1

/var/list/datum/access/priv_all_access_datums
/proc/get_all_access_datums()
	if(!priv_all_access_datums)
		priv_all_access_datums = init_subtypes(/datum/access)
		priv_all_access_datums = dd_sortedObjectList(priv_all_access_datums)

	return priv_all_access_datums.Copy()

/var/list/datum/access/priv_all_access_datums_id
/proc/get_all_access_datums_by_id()
	if(!priv_all_access_datums_id)
		priv_all_access_datums_id = list()
		for(var/datum/access/A in get_all_access_datums())
			priv_all_access_datums_id["[A.id]"] = A

	return priv_all_access_datums_id.Copy()

/var/list/datum/access/priv_all_access_datums_region
/proc/get_all_access_datums_by_region()
	if(!priv_all_access_datums_region)
		priv_all_access_datums_region = list()
		for(var/datum/access/A in get_all_access_datums())
			if(!priv_all_access_datums_region[A.region])
				priv_all_access_datums_region[A.region] = list()
			priv_all_access_datums_region[A.region] += A

	return priv_all_access_datums_region.Copy()

/proc/get_access_ids(var/access_types = ACCESS_TYPE_ALL)
	var/list/L = new()
	for(var/datum/access/A in get_all_access_datums())
		if(A.access_type & access_types)
			L += A.id
	return L

/var/list/priv_all_access
/proc/get_all_accesses()
	if(!priv_all_access)
		priv_all_access = get_access_ids()

	return priv_all_access.Copy()

/var/list/priv_D6_access
/proc/get_all_D6_access()
	if(!priv_D6_access)
		priv_D6_access = get_access_ids(ACCESS_TYPE_D6)

	//return priv_vault_access.Copy()

/var/list/priv_region_access
/proc/get_region_accesses(var/code)
	/*
	if(code == ACCESS_REGION_ALL)
		return get_all_station_access()
	*/
	if(!priv_region_access)
		priv_region_access = list()
		for(var/datum/access/A in get_all_access_datums())
			if(!priv_region_access["[A.region]"])
				priv_region_access["[A.region]"] = list()
			priv_region_access["[A.region]"] += A.id

	var/list/region = priv_region_access["[code]"]
	return region.Copy()

/proc/get_region_accesses_name(var/code)
	switch(code)
		if(ACCESS_REGION_ALL)
			return "All"
		/*
		if(ACCESS_REGION_VAULT) //Just a throw in for D6 or something like that
			return "D6"
		*/
/proc/get_access_desc(id)
	var/list/AS = priv_all_access_datums_id || get_all_access_datums_by_id()
	var/datum/access/A = AS["[id]"]

	return A ? A.desc : ""

/proc/get_centcom_access_desc(A)
	return get_access_desc(A)

/proc/get_access_by_id(id)
	var/list/AS = priv_all_access_datums_id || get_all_access_datums_by_id()
	return AS[id]

/mob/observer/ghost
	var/static/obj/item/weapon/card/id/all_access/ghost_all_access
/*
/mob/observer/ghost/GetIdCard()
	if(!is_admin(src))
		return

	if(!ghost_all_access)
		ghost_all_access = new()
	return ghost_all_access

/mob/living/bot/GetIdCard()
	return botcard
*/
#define HUMAN_ID_CARDS list(get_active_hand(), wear_id, get_inactive_hand())
/mob/living/carbon/human/GetIdCard()
	for(var/item_slot in HUMAN_ID_CARDS)
		var/obj/item/I = item_slot
		var/obj/item/weapon/card/id = I ? I.GetIdCard() : null
		if(id)
			return id

/mob/living/carbon/human/GetAccess()
	. = list()
	for(var/item_slot in HUMAN_ID_CARDS)
		var/obj/item/I = item_slot
		if(I)
			. |= I.GetAccess()
#undef HUMAN_ID_CARDS

/proc/FindNameFromID(var/mob/M, var/missing_id_name = "Unknown")
	var/obj/item/weapon/card/id/C = M.GetIdCard()
	if(C)
		return C.registered_name
	return missing_id_name

/proc/get_all_role_icons() //For all existing HUD icons
	return SSroles.titles_to_datums + list("Prisoner")

/obj/proc/GetRoleName() //Used in secHUD icon generation
	/*
	var/obj/item/weapon/card/id/I = GetIdCard()
	if(I)
		var/role_icons = get_all_role_icons()
		if(I.assignment	in role_icons) //Check if the role has a hud icon
			return I.assignment
		if(I.rank in role_icons)
			return I.rank
		
		var/centcom = get_all_centcom_roles()
		if(I.assignment	in centcom) //Return with the NT logo if it is a Centcom role
			return "Centcom"
		if(I.rank in centcom)
			return "Centcom"
		
	else
		return
	*/
	return "Unknown" //Return unknown if none of the above apply

/proc/get_access_region_by_id(id)
	var/datum/access/AD = get_access_by_id(id)
	return AD.region