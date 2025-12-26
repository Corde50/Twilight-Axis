#define SOUNDBREAKER_NOTE_BEND	1
#define SOUNDBREAKER_NOTE_BARE	2
#define SOUNDBREAKER_NOTE_SLAP	3
#define SOUNDBREAKER_NOTE_SHED	4
#define SOUNDBREAKER_NOTE_SOLO	5
#define SOUNDBREAKER_NOTE_RIFF	6

#define SB_COMBO_ICON_ECHO		"combo_echo"
#define SB_COMBO_ICON_TEMPO		"combo_tempo"
#define SB_COMBO_ICON_SNAPBACK	"combo_snap"
#define SB_COMBO_ICON_BASS		"combo_bass"
#define SB_COMBO_ICON_CROSSFADE	"combo_cross"
#define SB_COMBO_ICON_REVERB	"combo_reverb"
#define SB_COMBO_ICON_SYNC		"combo_sync"
#define SB_COMBO_ICON_RITMO		"combo_ritmo"
#define SB_COMBO_ICON_CRESCENDO	"combo_crescendo"
#define SB_COMBO_ICON_OVERTURE	"combo_overture"
#define SB_COMBO_ICON_BLADE		"combo_blade"
#define SB_COMBO_ICON_HARMONIC	"combo_harmonic"

#define SB_COMBO_WINDOW (8 SECONDS)
#define SB_MAX_HISTORY 5
#define SB_BASE_COOLDOWN (1.5 SECONDS)
#define SB_PREP_WINDOW (5 SECONDS)

#define SOUNDBREAKER_FX_ICON 				'modular_twilight_axis/soundbreaker/icons/soundanims.dmi'
#define SOUNDBREAKER_FX96_ICON 				'modular_twilight_axis/soundbreaker/icons/soundanims96.dmi'
#define SOUNDBREAKER_NOTES_ICON 			'modular_twilight_axis/soundbreaker/icons/soundspells.dmi'

#define SB_FX_EQS     		"spell_bend"        
#define SB_FX_WAVE_FORWARD	"spell_bare"      
#define SB_FX_RING			"spell_wave"        
#define SB_FX_NOTE_SHATTER	"spell_note"      
#define SB_FX_RIFF_SINGLE	"riff_strike"         
#define SB_FX_RIFF_CLUSTER	"riff_aura"   
#define SB_FX_PROJ_NOTE		"note_projectile"         

#define SB_MAX_VISIBLE_NOTES 5

/// Prime prepared note
/// Args: (note_id, damage_mult, damage_type, note_name)
#define COMSIG_SOUNDBREAKER_PRIME_NOTE "soundbreaker_prime_note"
#define COMPONENT_SOUNDBREAKER_PRIMED (1<<0)

/// Consume prepared attack on swing attempt
/// Args: (mob/living/target_or_null, zone)
#define COMSIG_SOUNDBREAKER_TRY_CONSUME_PREPARED "soundbreaker_try_consume_prepared"
#define COMPONENT_SOUNDBREAKER_CONSUMED (1<<0)

/// Successful defense hook (Riff stance)
/// Args: none
#define COMSIG_SOUNDBREAKER_RIFF_DEFENSE_SUCCESS "soundbreaker_riff_defense_success"

/// Projectile note hit
/// Args: (mob/living/target, damage_mult, damage_type, zone)
#define COMSIG_SOUNDBREAKER_NOTE_PROJECTILE_HIT "soundbreaker_note_projectile_hit"

/// Combo cleared event (status effect removed etc)
/// Args: none
// already have COMSIG_SOUNDBREAKER_COMBO_CLEARED in your defines.dm; re-use if present
#define COMSIG_SOUNDBREAKER_COMBO_CLEARED "soundbreaker_combo_cleared"
