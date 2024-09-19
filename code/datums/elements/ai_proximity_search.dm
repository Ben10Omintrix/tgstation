#define MOB_VIEW_DISTANCE 9

/datum/element/proximity_searcher

/datum/element/proximity_searcher/Attach(datum/target)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/living_target = target
	if(isnull(living_target.ai_controller))
		return ELEMENT_INCOMPATIBLE

	new /datum/proximity_monitor/advanced/ai_proximity_search(
		living_target,
		MOB_VIEW_DISTANCE,
		TRUE,
		living_target.ai_controller
	)
	RegisterSignal(target, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(target, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignal(target, COMSIG_MOB_LOGOUT, PROC_REF(on_logout))
	RegisterSignal(living_target.ai_controller, COMSIG_QDELETING, PROC_REF(controller_deleted))

/datum/element/proximity_searcher/Detach(mob/living/living_target)
	. = ..()
	UnregisterSignal(living_target, list(
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_REVIVE,
		COMSIG_MOB_LOGIN,
		COMSIG_MOB_LOGOUT,
	))
	var/datum/ai_controller = living_target.ai_controller
	if(!isnull(ai_controller))
		UnregisterSignal(ai_controller, COMSIG_QDELETING)


/datum/element/proximity_searcher/proc/on_revive(mob/living/source)
	SIGNAL_HANDLER
	initialize_field(source)

/datum/element/proximity_searcher/proc/on_login(mob/living/source)
	SIGNAL_HANDLER
	initialize_field(source)

/datum/element/proximity_searcher/proc/controller_deleted(datum/ai_controller/controller)
	SIGNAL_HANDLER
	var/datum/proximity_monitor = controller.blackboard[BB_PROXIMITY_SEARCH_FIELD]
	qdel(proximity_monitor)

/datum/element/proximity_searcher/proc/on_logout(mob/living/source)
	SIGNAL_HANDLER
	var/datum/proximity_monitor = source.ai_controller?.blackboard[BB_PROXIMITY_SEARCH_FIELD]
	qdel(proximity_monitor)

/datum/element/proximity_searcher/proc/on_death(mob/living/source)
	SIGNAL_HANDLER
	if(source.ai_controller?.ai_traits & CAN_ACT_WHILE_DEAD)
		return
	var/datum/proximity_monitor = source.ai_controller.blackboard[BB_PROXIMITY_SEARCH_FIELD]
	qdel(proximity_monitor)

/datum/element/proximity_searcher/proc/initialize_field(mob/living/living_target)
	if(!isnull(living_target.ai_controller?.blackboard[BB_PROXIMITY_SEARCH_FIELD]))
		return
	new /datum/proximity_monitor/advanced/ai_proximity_search(
		living_target,
		MOB_VIEW_DISTANCE,
		TRUE,
		living_target.ai_controller
	)

#undef MOB_VIEW_DISTANCE
