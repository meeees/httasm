;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Random Number Generator ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; random numbers based on the xorwow variation of the xorshift algorithm

; initialize the tls value for storing seeds per thread, only if it's needed
; because it will early-out, I'm going to call this every seed initialization
; also returns the tls index
random_tls_init:
	push ebp
	mov ebp, esp
	cmp [random_xorwow_tls], 0
	jnz .skip
	call [TlsAlloc]
	mov [random_xorwow_tls], eax
.skip:
	mov eax, [random_xorwow_tls]
	mov esp, ebp
	pop ebp
	ret

; will intialize (or-reinitialize) based on a random number from the cpu
random_init:
	push ebp
	mov ebp, esp
	rdrand eax
	push eax
	call random_init_seeded
	add esp, 4
	mov esp, ebp
	pop ebp
	ret

; should pass in a seed
random_init_seeded:
	push ebp
	mov ebp, esp

	call random_tls_init
	; see if we need to malloc an array
	mov ebx, eax
	push eax
	call [TlsGetValue]
	cmp eax, 0
	jnz .skip
	push 4
	push 5
	call [calloc]
	add esp, 8
	mov ecx, eax
	push eax
	push ebx
	call [TlsSetValue]

; at this point, the pointer to the state array is in ecx
.skip:
	mov eax, [ebp+8]
	mov [ecx], eax
	cmp [random_xorwow_debugging], 0
	jz .skip_debug
	push ecx
	call random_print_states
	add esp, 4

.skip_debug:
	mov esp, ebp
	pop ebp
	ret

random_print_states:
	push ebp
	mov ebp, esp
	mov ecx, [ebp+8]
	mov eax, [ecx+16]
	push eax
	mov eax, [ecx+12]
	push eax
	mov eax, [ecx+8]
	push eax
	mov eax, [ecx+4]
	push eax
	mov eax, [ecx]
	push eax
	push random_xorwow_states_string
	call [printf]
	add esp, 24
	mov esp, ebp
	pop ebp
	ret


; there's a long ass list of triples we can use for this
; 13,17,5 because the xorshift author likes them
; if the random number generator isn't initialized then we will initialize it
random_generate:
	push ebp
	mov ebp, esp

	; make sure our states are seeded
	mov ecx, 0
	;mov ebx, random_xorwow_state
	mov edx, 0
.state_check:
	mov eax, [ebx]
	or edx, eax
	add ecx, 1
	add ebx, 4
	cmp ecx, 5
	jnz .state_check
	cmp edx, 0
	jnz .dont_seed
	call random_init

.dont_seed:
	mov esp, ebp
	pop ebp
	ret