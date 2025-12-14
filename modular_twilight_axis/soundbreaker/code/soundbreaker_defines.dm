// Ноты
#define SOUNDBREAKER_NOTE_STRIKE     1
#define SOUNDBREAKER_NOTE_WAVE       2
#define SOUNDBREAKER_NOTE_DULCE      3
#define SOUNDBREAKER_NOTE_OVERLOAD   4
#define SOUNDBREAKER_NOTE_ENCORE     5
#define SOUNDBREAKER_NOTE_SOLO       6

/// Окно для комбо (последовательность ударов)
#define SB_COMBO_WINDOW (8 SECONDS)
/// Сколько последних нот храним
#define SB_MAX_HISTORY 6

#define SB_BASE_COOLDOWN (1 SECONDS)

/// Сигнал, который кидает статус, когда комбо-бафф истёк
#define COMSIG_SOUNDBREAKER_COMBO_CLEARED "soundbreaker_combo_cleared"

/// Переменная на мобе для трекера комбо
/mob/living
	var/datum/soundbreaker_combo_tracker/soundbreaker_combo
