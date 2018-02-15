;;;;;;;;;;;;;;;;;;;;
; HTTP Server Code ;
;;;;;;;;;;;;;;;;;;;;

; Handles the creation of a listen socket
; Does everything except call accept.
; Returns: Listen socket value of type SOCKET
; Parameters:
;	+0x08 : uint port

http_create_listener:
	push ebp
	mov ebp, esp



	mov esp, ebp
	pop ebp
	ret


; Provides a valid HTTP response for a given connection socket.
; Gets the request data and creates an HTTP response and then sends it.
; Returns: Send return value of type int
; Parameters:
;	+0x08 : SOCKET connection

http_handle_request:
	push ebp
	mov ebp, esp



	mov esp, ebp
	pop ebp
	ret

; Gets line from HTTP request and places it in a given buffer.
; Returns: Number of bytes placed into the buffer, excluding null terminator. Type of int.
; Parameters:
;	+0x08 : SOCKET connection
;	+0x0c : void* buffer
;	+0x10 : uint buffer_len

http_get_line:
	push ebp
	mov ebp, esp

	; ebx will be the SOCKET connection
	; edi is the current # of bytes placed into the buffer
	; esi will be the current position in the buffer
	; edx will be the end of the buffer
	; ecx is the current character that we're reading.
	mov ebx, [ebp+0x08] ; ebx = connection
	mov esi, [ebp+0x0c] ; esi = buffer
	mov edx, [ebp+0x10] ; edx = buffer_len
	add edx, ecx ; edx = buffer + buffer_len
	xor ecx, ecx ; ecx = 0

	; Done with register setup code.
	; Remember to preserve these values across calls
.whileloop:
	lea eax, [edx-1]
	cmp ecx, eax ; if (ecx >= (size - 1)) we done
	jae .done

	cmp ecx, ENDL ; if (ecx == '\n') we done
	jz .done

	; Okay so now we know we still wanna keep reading and stuff
	; Lazy way to preserve all the registers
	push edx
	push esi
	push ebx
	push ecx
	mov eax, esp

	; I don't remember which registers are preserved...
	; Okay now for recv args
	push 0 ; RECV Flags
	push 1 ; # of bytes to read
	push eax ; Buffer position
	push ebx
	call [recv]
	; STDCALL so no cleanup

	pop ecx
	pop ebx
	pop esi
	pop edx
	; Restore values with esi being the recv'd value

	cmp eax, 0
	jbe .done ; if (recvReturnValue < 0) goto done 
	; Because this means that the recv has no more data, so we're done

	; Otherwise continue the processing shit.
	cmp cl, CRET ; if ecx == '\r'
	jnz .notcret

	; If it is cret then we gotta check to see if the next character is an endline, if so read it it.
	; Preserve my registers
	push edx
	push esi
	push ebx
	push ecx
	mov eax, esp

	push 2 ; MSG_PEEK
	push 1 ; # of bytes to peek
	push eax ; buff
	push ebx ; SOCKET
	call [recv]

	; Restore registers
	pop ecx
	pop ebx
	pop esi
	pop edx

	cmp eax, 0
	jle .notEndl

	cmp cl, ENDL
	jnz .notEndl

	push edx
	push esi
	push ebx
	push ecx
	mov eax, esp

	push 0
	push 1 ; # of bytes
	push eax ; buff
	push ebx ; SOCKET
	call [recv]

	pop ecx
	pop ebx
	pop esi
	pop edx
	jmp .notcret

.notEndl:
	mov ecx, ENDL

.notcret:
	mov byte [esi], cl
	inc esi
	jmp .whileloop

.done:
	mov byte [esi], 0
	inc esi

	; Set eax to the # of bytes read in.
	lea eax, [edx - esi]
	mov ecx, [ebp+0x10]
	dec eax
	lea eax, [ecx - eax]


	mov esp, ebp
	pop ebp
	ret

