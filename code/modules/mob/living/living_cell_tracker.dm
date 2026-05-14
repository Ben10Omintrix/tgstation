/mob/living/proc/initialize_cell_tracker()
	tracked_cells = new(MOB_ACTIVITY_DISTANCE, MOB_ACTIVITY_DISTANCE, 1)
	update_cell_tracker()

/mob/living/proc/update_tracker_status()
	if((client || is_station_level(z)))
		disregard_cell_tracker()
		return
	if(isnull(tracked_cells))
		initialize_cell_tracker()

/mob/living/proc/disregard_cell_tracker()
	if(isnull(tracked_cells))
		return
	for(var/datum/spatial_grid_cell/current_grid as anything in tracked_cells.member_cells)
		UnregisterSignal(current_grid, list(SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)))

	tracked_cells = null
	update_mob_state(MOB_STATE_ACTIVE)

/mob/living/proc/update_cell_tracker()
	var/turf/our_turf = get_turf(src)

	if(isnull(our_turf))
		return

	var/list/cell_collections = tracked_cells.recalculate_cells(our_turf)

	for(var/datum/old_grid as anything in cell_collections[2])
		UnregisterSignal(old_grid, list(SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)))

	for(var/datum/spatial_grid_cell/new_grid as anything in cell_collections[1])
		RegisterSignal(new_grid, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(on_client_enter))
		RegisterSignal(new_grid, SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(on_client_exit))

	update_mob_state(get_active_state())

/mob/living/proc/get_active_state()
	if(client || isnull(tracked_cells))
		return MOB_STATE_ACTIVE

	for(var/datum/spatial_grid_cell/grid as anything in tracked_cells.member_cells)
		if(locate(/mob/living) in grid.client_contents)
			return MOB_STATE_ACTIVE

	return MOB_STATE_DORMANT

/mob/living/proc/on_client_enter(datum/source, list/target_list)
	SIGNAL_HANDLER

	if (!(locate(/mob/living) in target_list))
		return

	update_mob_state(new_state = MOB_STATE_ACTIVE)

/mob/living/proc/on_client_exit(datum/source, datum/exited)
	SIGNAL_HANDLER

	update_mob_state()


/mob/living/proc/update_mob_state(new_state)
	var/updated_state = new_state || get_active_state()
	if(updated_state == current_active_state)
		return
	GLOB.living_mob_list_by_state[current_active_state] -= src
	GLOB.living_mob_list_by_state[updated_state] += src
	current_active_state = updated_state
