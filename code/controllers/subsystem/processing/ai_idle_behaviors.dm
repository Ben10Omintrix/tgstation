PROCESSING_SUBSYSTEM_DEF(idle_ai_behaviors)
	name = "idle_ai_behaviors"
	flags = SS_NO_INIT | SS_BACKGROUND
	wait = 1
	priority = FIRE_PRIORITY_NPC_ACTIONS
	init_order = INIT_ORDER_AI_IDLE_CONTROLLERS //must execute only after ai behaviors are initialized
