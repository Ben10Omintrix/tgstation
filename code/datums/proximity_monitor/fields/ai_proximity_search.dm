// Proximity monitor that checks to see if anything interesting enters our bounds
/datum/proximity_monitor/advanced/ai_proximity_search
	edge_is_a_field = TRUE
	/// The ai controller we're using
	var/datum/ai_controller/controller
	/// List of subscribed behaviors
	var/list/subscribed_behaviors = list()

// Initially, run the check manually
// If that fails, set up a field and have it manage the behavior fully
/datum/proximity_monitor/advanced/ai_proximity_search/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, datum/ai_controller/controller)
	. = ..()
	src.controller = controller
	RegisterSignal(controller, COMSIG_AI_PLAN_STATUS_CHANGED, PROC_REF(on_ai_planning_change))
	recalculate_field(full_recalc = TRUE)
	controller.set_blackboard_key(BB_PROXIMITY_SEARCH_FIELD, src)


/datum/proximity_monitor/advanced/ai_proximity_search/proc/subscribe_to_field(datum/ai_behavior/behavior, /datum/ai_controller/controller)
	subscribed_behaviors[behavior] = TRUE
	controller.override_blackboard_key(BB_PROXIMITY_FOUND_ITEMS(behavior.type), list())

/datum/proximity_monitor/advanced/ai_proximity_search/Destroy()
	. = ..()
	controller = null
	subscribed_behaviors = null

/datum/proximity_monitor/advanced/ai_proximity_search/recalculate_field(full_recalc = FALSE, bypass_cleanup = TRUE)
	return ..()

/datum/proximity_monitor/advanced/ai_proximity_search/setup_field_turf(turf/target)
	if(!controller.able_to_plan)
		return
	for(var/datum/ai_behavior/proximity_search/behavior as anything in subscribed_behaviors)
		behavior.analyze_turf(target, controller)

/datum/proximity_monitor/advanced/ai_proximity_search/setup_edge_turf(turf/target)
	setup_field_turf(target)

/datum/proximity_monitor/advanced/ai_proximity_search/field_turf_crossed(atom/movable/movable, turf/location, turf/old_location)
	if(!controller.able_to_plan)
		return
	for(var/datum/ai_behavior/proximity_search/behavior as anything in subscribed_behaviors)
		if(is_type_in_typecache(movable, behavior.accepted_types))
			controller.insert_blackboard_key(BB_PROXIMITY_FOUND_ITEMS(behavior.type), movable)

/datum/proximity_monitor/advanced/ai_proximity_search/proc/on_ai_planning_change(datum/source, new_status)
	if(new_status)
		return
	for(var/datum/ai_behavior/proximity_search/behavior as anything in subscribed_behaviors)
		controller.set_blackboard_key(BB_PROXIMITY_ABLE_TO_SEARCH(behavior.type), FALSE)
