
///sent from ai controllers when they possess a pawn: (datum/ai_controller/source_controller)
#define COMSIG_AI_CONTROLLER_POSSESSED_PAWN "ai_controller_possessed_pawn"
///sent from ai controllers when they pick behaviors: (list/datum/ai_behavior/old_behaviors, list/datum/ai_behavior/new_behaviors)
#define COMSIG_AI_CONTROLLER_PICKED_BEHAVIORS "ai_controller_picked_behaviors"
///sent from ai controllers when a behavior is inserted into the queue: (list/new_arguments)
#define AI_CONTROLLER_BEHAVIOR_QUEUED(type) "ai_controller_behavior_queued_[type]"
///sent from ai controllers after clearing a behavior
#define COMSIG_AI_CONTROLLER_BEHAVIOR_DEQUEUED(type) "dequeued_behavior_[type]"
///sent from ai controllers whenever a new behavior is queued in general
#define COMSIG_AI_CONTROLLER_QUEUED_BEHAVIOR "queued_behavior"

