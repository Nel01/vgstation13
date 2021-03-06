//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

//Returns the thing in our active hand (whatever is in our active module-slot, in this case)
/mob/living/silicon/robot/mommi/get_active_hand()
	return module_active

/mob/living/silicon/robot/mommi/proc/is_in_modules(obj/item/W)
	var/obj/item/found = locate(W) in src.module.modules
	return found
/mob/living/silicon/robot/mommi/put_in_hands(var/obj/item/W)
	// Fixing NPEs caused by PDAs giving me NULLs to hold :V - N3X
	// And before you ask, this is how /mob handles NULLs, too.
	if(!W)
		return 0
	// Make sure we're not picking up something that's in our factory-supplied toolbox.
	//if(is_type_in_list(W,src.module.modules))
	if(is_in_modules(W))
		src << "\red Picking up something that's built-in to you seems a bit silly."
		return 0
	if(tool_state)
		//var/obj/item/found = locate(tool_state) in src.module.modules
		if(!is_in_modules(tool_state))
			var/obj/item/TS = tool_state
			drop_item()
			if(TS && TS.loc)
				TS.loc = src.loc
		contents -= tool_state
		if (client)
			client.screen -= tool_state
	tool_state = W
	W.layer = 20
	contents += W
	inv_tool.icon_state = "inv1"
	update_items()
	return 1

//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/living/silicon/robot/mommi/remove_from_mob(var/obj/O)
	src.u_equip(O)
	if (src.client)
		src.client.screen -= O
	O.layer = initial(O.layer)
	O.screen_loc = null
	return 1

/mob/living/silicon/robot/mommi/u_equip(W as obj)
	if (W == tool_state)
		if(module_active==tool_state)
			module_active=null
		unequip_tool()
	else if (W == sight_state)
		if(module_active==sight_state)
			module_active=null
		unequip_sight()

// Override the default /mob version since we only have one hand slot.
/mob/living/silicon/robot/mommi/put_in_active_hand(var/obj/item/W)
	// If we have anything active, deactivate it.
	if(get_active_hand())
		uneq_active()
	return put_in_hands(W)

/mob/living/silicon/robot/mommi/drop_item_v()		//this is dumb.
	if(stat == CONSCIOUS && isturf(loc))
		return drop_item()
	return 0

/mob/living/silicon/robot/mommi/drop_item(var/atom/Target)
	if(tool_state)
		//var/obj/item/found = locate(tool_state) in src.module.modules
		if(is_in_modules(tool_state))
			src << "\red This item cannot be dropped."
			return 0
		if(client)
			client.screen -= tool_state
		contents -= tool_state
		var/obj/item/TS = tool_state
		var/turf/T = null
		if(Target)
			T=get_turf(Target)
		else
			T=get_turf(src)
		TS.layer=initial(TS.layer)
		TS.loc = T.loc

		if(istype(T))
			T.Entered(tool_state)
		TS.dropped(src)
		tool_state = null
		module_active=null
		inv_tool.icon_state="inv1"
		update_items()
		return 1
	return 0


/*-------TODOOOOOOOOOO--------*/
// Called by store button
/mob/living/silicon/robot/mommi/uneq_active()
	if(isnull(module_active))
		return
	if(sight_state == module_active)
		if(istype(sight_state,/obj/item/borg/sight))
			sight_mode &= ~sight_state:sight_mode
		if (client)
			client.screen -= sight_state
		contents -= sight_state
		module_active = null
		sight_state = null
		inv_sight.icon_state = "sight"
	if(tool_state == module_active)
		//var/obj/item/found = locate(tool_state) in src.module.modules
		if(!is_in_modules(tool_state))
			var/obj/item/TS = tool_state
			drop_item()

			if(TS && TS.loc)
				TS.loc = src.loc
		if(istype(tool_state,/obj/item/borg/sight))
			sight_mode &= ~tool_state:sight_mode
		if (client)
			client.screen -= tool_state
		contents -= tool_state
		module_active = null
		tool_state = null
		inv_tool.icon_state = "inv1"

/mob/living/silicon/robot/mommi/uneq_all()
	module_active = null

	unequip_sight()
	unequip_tool()

/mob/living/silicon/robot/mommi/proc/unequip_sight()
	if(sight_state)
		if(istype(sight_state,/obj/item/borg/sight))
			sight_mode &= ~sight_state:sight_mode
		if (client)
			client.screen -= sight_state
		contents -= sight_state
		sight_state = null
		inv_sight.icon_state = "sight"

/mob/living/silicon/robot/mommi/proc/unequip_tool()
	if(tool_state)
		//var/obj/item/found = locate(tool_state) in src.module.modules
		if(!is_in_modules(tool_state))
			drop_item()
		if(istype(tool_state,/obj/item/borg/sight))
			sight_mode &= ~tool_state:sight_mode
		if (client)
			client.screen -= tool_state
		contents -= tool_state
		tool_state = null
		inv_tool.icon_state = "inv1"


/mob/living/silicon/robot/mommi/activated(obj/item/O)
	if(sight_state == O)
		return 1
	else if(tool_state == O) // Sight
		return 1
	else
		return 0