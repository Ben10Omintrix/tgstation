/datum/ai_behavior/hunt_target/unarmed_attack_target/heal_raptor
	always_reset_target = TRUE

/datum/ai_behavior/proximity_search/injured_raptor
	accepted_types = list(/mob/living/basic/raptor)

/datum/ai_behavior/proximity_search/injured_raptor/validate_target(datum/ai_controller/controller, mob/living/target)
	return (controller.pawn != target && target.health < target.maxHealth)

/datum/ai_behavior/proximity_search/raptor_victim
	accepted_types = list(/mob/living/basic/raptor)

/datum/ai_behavior/proximity_search/raptor_victim/validate_target(datum/ai_controller/controller, mob/living/target)
	if(target.ai_controller?.blackboard[BB_RAPTOR_TROUBLE_MAKER])
		return FALSE
	return target.stat != DEAD && can_see(controller.pawn, target)

/datum/ai_behavior/hunt_target/unarmed_attack_target/bully_raptors
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/unarmed_attack_target/bully_raptors/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
	if(succeeded)
		controller.set_blackboard_key(BB_RAPTOR_TROUBLE_COOLDOWN, world.time + 2 MINUTES)
	return ..()

/datum/ai_behavior/proximity_search/raptor_baby
	accepted_types = list(/mob/living/basic/raptor/baby_raptor)

/datum/ai_behavior/proximity_search/raptor_baby/validate_target(datum/ai_controller/controller, mob/living/target)
	return can_see(controller.pawn, target) && target.stat != DEAD

/datum/ai_behavior/hunt_target/care_for_young
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/care_for_young/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("grooms [hunted]!")
	hunter.set_combat_mode(FALSE)
	hunter.ClickOn(hunted)

/datum/ai_behavior/hunt_target/care_for_young/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
	var/mob/living/living_pawn = controller.pawn
	living_pawn.set_combat_mode(initial(living_pawn.combat_mode))
	return ..()

/datum/ai_behavior/proximity_search/raptor_trough
	accepted_types = list(/obj/structure/ore_container/food_trough/raptor_trough)

/datum/ai_behavior/proximity_search/raptor_trough/validate_target(datum/ai_controller/controller, atom/trough)
	return !!(locate(/obj/item/stack/ore) in trough.contents)

/datum/ai_behavior/hunt_target/unarmed_attack_target/raptor_trough
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/unarmed_attack_target/raptor_trough/target_caught(mob/living/hunter, atom/hunted)
	hunter.set_combat_mode(FALSE)

/datum/ai_behavior/hunt_target/unarmed_attack_target/raptor_trough/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
	var/mob/living/living_pawn = controller.pawn
	living_pawn.set_combat_mode(initial(living_pawn.combat_mode))
	return ..()
