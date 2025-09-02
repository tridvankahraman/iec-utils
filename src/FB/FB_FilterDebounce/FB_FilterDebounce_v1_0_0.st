/// @name		: FB_FilterDebounce
/// @brief		: Filters Spikes on Digital Inputs	
/// @author		: Ridvan Kahraman
/// @version	: v1.0.0
/// @date		: 2025-09-02
/// @copyright	: Copyright (c) 2025 Ridvan Kahraman

(*
	Filters unstable digital input transitions using debounce logic.
	A timer is started when input changes; output updates only if the input remains stable during the time.
*)

/// Filters Spikes on Digital Inputs with Debounce Logic

FUNCTION_BLOCK FB_FilterDebounce

VAR_INPUT
	i_FiltEn		: BOOL;					// Enable Input for FB
    i_SigRaw		: BOOL;	  				// Input to Debounce
    i_DebTime		: TIME;					// Debounce Time in Milliseconds
END_VAR

VAR_OUTPUT
	q_SigDeb		: BOOL := FALSE;		// Debounced Output
END_VAR

VAR
	l_TonDeb		: TON;	  				// Debounce Timer
    l_LastSt		: BOOL := FALSE;		// Last Stable State
END_VAR



// Debounce Logic with SIL-2 Considerations
IF (i_FiltEn = TRUE) THEN
	
	// Change Detected → Start Timer
	IF (i_SigRaw <> l_LastSt) THEN
				
		l_TonDeb(IN := TRUE, PT := i_DebTime);
		
	ELSE
		
		l_TonDeb(IN := FALSE, PT := i_DebTime);
		
	END_IF;
	
	// Execute Timer
	l_TonDeb();
	
	// Timer Elapsed → Accept New State
	IF l_TonDeb.Q THEN
		
        l_LastSt := i_SigRaw;								
	
	END_IF;
	
ELSE
	// Bypass Logic When Disabled (Fail-Safe Default Behavior)
	l_LastSt := i_SigRaw;

	// Optional: Reset Timer to Avoid Stale State
	l_TonDeb(IN := FALSE, PT := i_DebTime);
	l_TonDeb();
	
END_IF

// Output Last Known Stable State
q_SigDeb := l_LastSt;
