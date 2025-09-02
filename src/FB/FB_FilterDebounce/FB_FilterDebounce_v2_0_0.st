/// @name		: FB_FilterDebounce
/// @brief		: Filters Spikes on Digital Inputs	
/// @author		: Ridvan Kahraman
/// @version	: v2.0.0
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
	q_Fault			: BOOL := FALSE;		// Config Fault
	
END_VAR

VAR
	
	l_TonDeb		: TON;	  				// Debounce Timer
    l_LastSt		: BOOL := FALSE;		// Last Stable State
	
	// --- Minimum Safety Variables ---
	l_PT			: TIME := T#0MS;		// Effective Debounce Time
	l_Bypass		: BOOL := FALSE;		// 0 ms -> Bypass
	l_PrevRaw		: BOOL := FALSE;		// Previous Raw Sample
	
END_VAR

VAR CONSTANT
	
    c_MaxPT			: TIME := T#1S;			// Upper Limit for PT
	
END_VAR



// --- Fail-Safe Fallback ---
IF NOT i_FiltEn THEN
	
	l_LastSt := FALSE;
	l_TonDeb(IN := FALSE, PT := T#0MS);
	
	// Force Reset
	l_TonDeb();								
	
	q_SigDeb := l_LastSt;
	l_PrevRaw := i_SigRaw;
	
	RETURN;
	
END_IF



// --- Clamp Debounce Time ---
IF i_DebTime < T#0MS THEN
	
    l_PT := T#0MS;
    q_Fault := TRUE;
	
ELSIF i_DebTime > c_MaxPT THEN
	
	l_PT := c_MaxPT;
    q_Fault := TRUE;
	
ELSE
	
    l_PT := i_DebTime;
    q_Fault := FALSE;
	
END_IF;

l_Bypass := (l_PT = T#0MS);



// --- Debounce Logic ---
IF l_Bypass THEN
	
    // Documented Passthrough
    l_LastSt := i_SigRaw;
    l_TonDeb(IN := FALSE, PT := T#0MS);
    l_TonDeb();

ELSE
	
    IF (i_SigRaw <> l_LastSt) THEN
		
        // Candidate Phase
        IF (i_SigRaw <> l_PrevRaw) THEN
			
            // Raw Changed Again → Reset ET
            l_TonDeb(IN := FALSE, PT := T#0MS);
            l_TonDeb();
			
        END_IF
		
        // Start/Continue Stability Window
        l_TonDeb(IN := TRUE, PT := l_PT);
		
    ELSE
		
        // No Candidate Phase → Timer Idle
        l_TonDeb(IN := FALSE, PT := l_PT);
		
    END_IF

    // Execute timer
    l_TonDeb();

    // Window Elapsed → Accept New State
    IF l_TonDeb.Q AND (i_SigRaw <> l_LastSt) THEN
		
        l_LastSt := i_SigRaw;
        l_TonDeb(IN := FALSE, PT := T#0MS);
        l_TonDeb();
		
    END_IF
	
END_IF



// --- Output Stable State ---
q_SigDeb := l_LastSt;
l_PrevRaw := i_SigRaw;
