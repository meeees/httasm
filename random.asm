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

; clear out the state array for this thread
random_clear_mem:
	push ebp
	mov ebp, esp
	mov eax, [random_xorwow_tls]
	cmp eax, 0
	jz .already_clear
	push eax
	call [TlsGetValue]
	cmp eax, 0
	jz .already_clear
	push eax
	call [free]
	add esp, 4
	push 0
	push [random_xorwow_tls]
	call [TlsSetValue]
.already_clear:
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
	push 6
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
	mov eax, [ecx+20]
	push eax
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
	add esp, 28
	mov esp, ebp
	pop ebp
	ret


; there's a long list of triples we can use for this
; 13,17,5 because the xorshift author likes them
; the integer at the end can be any odd integer
; if the random number generator isn't initialized then we will initialize it
random_generate:
	push ebp
	mov ebp, esp

	;checks to make sure everything is initialized
	mov eax, [random_xorwow_tls]
	cmp eax, 0
	jz .make_seed
	push eax
	call [TlsGetValue]
	cmp eax, 0
	jnz .skip_seed
.make_seed:
	call random_init

.skip_seed:
	push [random_xorwow_tls]
	call [TlsGetValue]
	;a = 13, b = 17, c = 5, d1 = 13371337
	;t=(xˆ(x>>a)); x=y; y=z; z=w; w=v; v=(vˆ(v<<b))ˆ(tˆ(t<<c));
	;return (d+=d1) + v
	mov ecx, [eax]
	mov edx, ecx
	shr ecx, 13
	xor ecx, edx
	mov edx, [eax+4]
	mov [eax], edx
	mov edx, [eax+8]
	mov [eax+4], edx
	mov edx, [eax+12]
	mov [eax+8], edx
	mov edx, [eax+16]
	mov [eax+12], edx
	mov ebx, edx
	shl edx, 17
	xor edx, ebx
	mov ebx, ecx
	shl ecx, 5
	xor ecx, ebx
	xor edx, ecx
	mov [eax+16], edx
	mov ecx, [eax+20]
	add ecx, 13371337
	mov [eax+20], ecx
	add edx, ecx

	cmp [random_xorwow_debugging], 0
	jz .skip_debug
	push edx
	push random_xorwow_gen_string
	call [printf]
	add esp, 4
	pop edx

.skip_debug:
	mov eax, edx

	mov esp, ebp
	pop ebp
	ret

;generate a random float
;returns eax in a state that's ready to be loaded with fld
random_generate_f:
	push ebp
	mov ebp, esp

	;we don't need debug output from this call
	movzx eax, [random_xorwow_debugging]
	push eax
	mov byte [random_xorwow_debugging], 0
	call random_generate
	pop ebx
	mov byte [random_xorwow_debugging], bl

	push eax
	fild dword [esp]
	;divide by largest possible value
	;value is now (-1, 1)
	push 0x80000000
	fild dword [esp]
	fdivp
	;make sure our value isn't negative
	;value is now [0, 2)
	fld1
	faddp
	;divide by 2
	;value is now [0, 1)
	push 2
	fild dword [esp]
	fdivp
	;clean up all the stack stuff for loading floats
	add esp, 12

	;debug output if we want that
	cmp [random_xorwow_debugging], 0
	jz .skip_debug
	;printf expects a double so we need 8 bytes
	sub esp, 8
	fst qword [esp]
	push random_xorwow_gen_string_f
	call [printf]
	add esp, 12

.skip_debug:
	sub esp, 4
	fstp dword [esp]
	pop eax
	add esp, 4
	mov esp, ebp
	pop ebp
	ret