/datum/ai_behavior/proximity_search
	action_cooldown = 2 SECONDS
	///what objects are we looking for?
	var/list/accepted_types

/datum/ai_behavior/proximity_search/New()
	. = ..()
	accepted_types = typecacheof(accepted_types)

/datum/ai_behavior/proximity_search/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/datum/proximity_monitor/advanced/ai_proximity_search/proximity = controller.blackboard[BB_PROXIMITY_SEARCH_FIELD]
	if(isnull(proximity))
		return FALSE
	if(proximity.subscribed_behaviors[src])
		return TRUE
	proximity.subscribe_to_field(src, controller)
	return TRUE

/datum/ai_behavior/proximity_search/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
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
