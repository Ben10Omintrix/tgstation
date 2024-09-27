/datum/ai_behavior/proximity_search
	action_cooldown = 2 SECONDS
	///what objects are we looking for?
	var/list/accepted_types

/datum/ai_behavior/proximity_search/New()
	. = ..()
	accepted_types = typecacheof(accepted_types)

/datum/ai_behavior/proximity_search/setup(datum/ai_controller/controller, target_key)
	. = ..()
	return controller.blackboard_key_exists(BB_PROXIMITY_SEARCH_FIELD)

/datum/ai_behavior/proximity_search/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	if(!controller.blackboard[BB_PROXIMITY_ABLE_TO_SEARCH(type)])
		get_first_build(controller)
	for(var/atom/interesting_item as anything in controller.blackboard[BB_PROXIMITY_FOUND_ITEMS(type)])
		if(get_dist(interesting_item, controller.pawn) > 9) //moved out of range, yeet it out!
			controller.remove_thing_from_blackboard_key(BB_PROXIMITY_FOUND_ITEMS(type), interesting_item)
			continue
		if(!validate_target(controller, interesting_item))
			continue
		controller.set_blackboard_key(target_key, interesting_item)
		return AI_BEHAVIOR_SUCCEEDED | AI_BEHAVIOR_DELAY
	return AI_BEHAVIOR_FAILED | AI_BEHAVIOR_DELAY

/datum/ai_behavior/proximity_search/proc/validate_target(datum/ai_controller/controller, atom/target)
	return TRUE

/datum/ai_behavior/proximity_search/proc/analyze_turf(turf/target, datum/ai_controller/controller)
	for(var/atom/interesting_object as anything in target)
		if(is_type_in_typecache(interesting_object, accepted_types))
			controller.insert_blackboard_key(BB_PROXIMITY_FOUND_ITEMS(type), interesting_object)

/datum/ai_behavior/proximity_search/proc/get_first_build(datum/ai_controller/controller)
	if(isnull(controller.blackboard[BB_PROXIMITY_FOUND_ITEMS(type)]))
		controller.set_blackboard_key(BB_PROXIMITY_FOUND_ITEMS(type), list())
	for(var/atom/possible_atom as anything in oview(9, controller.pawn))
		if(is_type_in_typecache(possible_atom, accepted_types))
			controller.insert_blackboard_key(BB_PROXIMITY_FOUND_ITEMS(type), possible_atom)
	var/datum/proximity_monitor/advanced/ai_proximity_search/proximity_field = controller.blackboard[BB_PROXIMITY_SEARCH_FIELD]
	if(!proximity_field.subscribed_behaviors[src])
		proximity_field.subscribe_to_field(src)
	controller.set_blackboard_key(BB_PROXIMITY_ABLE_TO_SEARCH(type), TRUE)
