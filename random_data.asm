;;;;;;;;;;;;;;;;;
; RNG Data File ;
;;;;;;;;;;;;;;;;;

; the TLS will hold a pointer to an array of the 6 state values
random_xorwow_tls dd 0

random_xorwow_debugging db 1
random_xorwow_states_string db "xorwow full states: [%d, %d, %d, %d, %d], d: %d", ENDL, 0
random_xorwow_gen_string db "xorwow generated %d", ENDL, 0
random_xorwow_gen_string_f db "xorwow generated %f", ENDL, 0