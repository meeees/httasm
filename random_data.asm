;;;;;;;;;;;;;;;;;
; RNG Data File ;
;;;;;;;;;;;;;;;;;

; the TLS will hold a pointer to an array of the 5 state values
random_xorwow_tls dd 0
;random_xorwow_state dd 0, 0, 0, 0, 0
random_xorwow_debugging db 1
random_xorwow_states_string db "xorwow full states: [%d, %d, %d, %d, %d]", ENDL, 0