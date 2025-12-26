/// External entrypoint: push an input.
/// Args: (skill_id, mob/living/target, zone, extra)
#define COMSIG_COMBO_CORE_REGISTER_INPUT "combo_core_register_input"

/// External entrypoint: clear history.
/// Args: none
#define COMSIG_COMBO_CORE_CLEAR "combo_core_clear"

/// Return flags
#define COMPONENT_COMBO_ACCEPTED (1<<0)
#define COMPONENT_COMBO_FIRED    (1<<1)
