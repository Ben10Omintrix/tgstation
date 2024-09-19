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
	recalculate_field(full_recalc = TRUE)
	controller.set_blackboard_key(BB_PROXIMITY_SEARCH_FIELD, src)

/datum/proximity_monitor/advanced/ai_proximity_search/proc/subscribe_to_field(datum/ai_behavior/behavior, /datum/ai_controller/controller)
	subscribed_behaviors[behavior] = TRUE
	if(!isnull(controller.blackboard[BB_PROXIMITY_FOUND_ITEMS(behavior.type)]))
		return
	controller.override_blackboard_key(BB_PROXIMITY_FOUND_ITEMS(behavior.type), list())
	recalculate_field(full_recalc = TRUE)

/datum/proximity_monitor/advanced/ai_proximity_search/Destroy()
	. = ..()
	controller = null
	subscribed_behaviors = null

/datum/proximity_monitor/advanced/ai_proximity_search/recalculate_field(full_recalc = FALSE, bypass_cleanup = FALSE)
	if(isnull(bypass_cleanup)) //our behaviors already handle this
		bypass_cleanup = TRUE
	if(isnull(full_recalc))
		full_recalc = FALSE
	return ..()

/datum/proximity_monitor/advanced/ai_proximity_search/setup_field_turf(turf/target)
	. = ..()
	for(var/datum/ai_behavior/proximity_search/behavior as anything in subscribed_behaviors)
		behavior.analyze_turf(target, controller)

/datum/proximity_monitor/advanced/ai_proximity_search/setup_edge_turf(turf/target)
	setup_field_turf(target)

/datum/proximity_monitor/advanced/ai_proximity_search/field_turf_crossed(atom/movable/movable, turf/location, turf/old_location)
	. = ..()
	for(var/datum/ai_behavior/proximity_search/behavior as anything in subscribed_behaviors)
		if(is_type_in_typecache(movable, behavior.accepted_types))
			controller.insert_blackboard_key(BB_PROXIMITY_FOUND_ITEMS(behavior.type), movable)
