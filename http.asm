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
	
	push 0
	push SOCK_STREAM
	push AF_INET
	call [socket]

	cmp eax, INVALID_SOCKET ; if socket failed then kms
	jnz .validSocket

	call [GetLastError]
	push eax
	push http_bad_socket
	call http_die

.validSocket:
	
	mov ecx, eax
	push ecx

	push 1 ; int value
	mov eax, esp
	push 4 ; sizeof(int)
	push eax ; &truevalue
	push SO_REUSEADDR
	push SOL_SOCKET
	push ecx ; SOCKET
	call [setsockopt]
	add esp, 4 ; Get rid of the 1 on the stack.
	pop ecx ; Get the SOCKET value

	cmp eax, -1
	jnz .goodSockOpt ; If setsockopt failed then kms

	call [GetLastError]
	push eax
	push http_bad_sockopt
	call http_die

.goodSockOpt:

	push ecx
	; Call htons on the port
	mov eax, [ebp+0x08]
	push eax
	call [htons]
	pop ecx

	; Setup sockaddr_in structure
	sub esp, 0x10
	mov word [esp], AF_INET  ; sin_family = AF_INET
	mov word [esp+2], ax     ; htons(port)
	mov dword [esp+4], 0     ; INADDR_ANY
	mov eax, esp

	push ecx ; For preservation

	push 0x10 ; sizeof(sockaddr_in)
	push eax ; &sockaddr
	push ecx ; SOCKET
	call [bind]
	pop ecx ; restore SOCKET

	add esp, 0x10 ; clear sockaddr_in from the stack

	cmp eax, -1
	jnz .goodBind ; If bind failed then kms

	call [GetLastError]
	push eax
	push http_bad_bind
	call http_die

.goodBind:

	push ecx ; preserve value
	; now to do the listen stuff
	push 5
	push ecx
	call [listen]
	pop ecx

	cmp eax, -1
	jnz .goodListen

	call [GetLastError]
	push eax
	push http_bad_listen
	call http_die

.goodListen:
	mov eax, ecx ; Return the socket with the setup stuff

	mov esp, ebp
	pop ebp
	ret


; Provides a valid HTTP response for a given connection socket.
; Gets the request data and creates an HTTP response and then sends it.
; Returns: void
; Parameters:
;	+0x08 : SOCKET connection

http_handle_request:
	push ebp
	mov ebp, esp

	sub esp, 1024
	mov ebx, esp

	push ebx ; preserve ebx
	push 1024
	push ebx
	mov eax, [ebp+0x08]
	push eax
	call http_get_line
	add esp, 0xc
	pop ebx ; restore ebx

	; Create lil buffer with "GET" in it
	push 0
	push 0
	mov eax, esp
	push 3
	push ebx
	push eax
	call [memcpy]
	pop eax
	pop ebx
	add esp, 4

	push ebx
	push http_get_str
	push eax
	call [stricmp]
	add esp, 8
	pop ebx
	add esp, 8

	cmp eax, 0 ; If its not a GET request we tell them unimplemented
	jnz .unimplemented

	; Kill the rest of the request
	; TODO: If its not a GET and we implement stuff we stop if its just an empty line.
	push ebx

	mov eax, [ebp+0x08]
	push eax
	call http_read_headers
	add esp, 4

	pop ebx

	; TODO: validate the file exists and send it back
	;       if it doesn't exist send the 404 request.

	; Find the start of the URL path string
	mov ecx, ebx
.getUrl:
	cmp byte [ecx], 0x2f ; '/'
	jz .gotUrl
	inc ecx
	jmp .getUrl

.gotUrl:
	push ebx
	push ecx

	; Find the space after the URL path
	push 0x20 ; ' '
	push ecx
	call [strchr]
	add esp, 8

	pop ecx
	pop ebx

	sub eax, ecx ; eax = length of url string
	
	push ebx ; preserve ebx

	push eax
	push ecx
	mov eax, [ebp+0x08]
	push eax
	call http_get_request
	add esp, 0xc

	pop ebx

	jmp .finishThread


.unimplemented:

	; Kill the rest of the request
	mov eax, [ebp+0x08]
	push eax
	call http_read_headers
	add esp, 4

	mov eax, [ebp+0x08]
	push eax
	call http_send_unimplemented
	add esp, 4

.finishThread:
	; Close the socket
	mov eax, [ebp+0x08]
	push eax
	call [closesocket]

	mov esp, ebp
	pop ebp
	ret


; Does a get request on a given path and sends the data to the socket
; Returns: void
; Parameters:
;	+0x08 : SOCKET
;	+0x0c : URL ptr
;	+0x10 : URL length

http_get_request:
	push ebp
	mov ebp, esp

	mov eax, [ebp+0x10] ; eax is the length of the url
	mov ebx, eax ; ebx will be the necessary buffer length for the full path
	mov ecx, [ebp+0x0c] ; ecx is the url ptr
	movzx edx, byte [ecx + eax - 1] ; get the last character in the path
	push edx
	cmp edx, 0x2f ; '/'
	jnz .dontaddindex

	; We need to add index.html to the end of the path
	add ebx, 10 ; length of index.html

.dontaddindex:
	; Now we add the length of the path prefix
	push ebx
	push http_path_prefix
	call [strlen]
	add esp, 4
	pop ebx

	add ebx, eax
	add ebx, 5 ; For good measure, really we only need to add 1

	push ebx ; In case we wanna do snprintf
	push ebx
	call [malloc]
	add esp, 4
	pop ebx
	mov ecx, eax

	pop edx ; The last character of the string
	cmp edx, 0x2f ; '/'
	jnz .dontindex

	push ecx ; preserve ecx

	push http_index_string
	mov eax, [ebp+0x0c] ; url string
	push eax
	mov eax, [ebp+0x10] ; limiter to the length to grab from the string
	push eax
	push http_path_prefix
	push http_path_format
	push ebx
	push ecx
	call [snprintf]
	add esp, 28 ; clear the stack args

	jmp .pathcomplete

.dontindex:
	push ecx ; preserve ecx

	push http_empty_string ; no need for index.html
	mov eax, [ebp+0x0c] ; url string
	push eax
	mov eax, [ebp+0x10] ; limiter to the length to grab from the string
	push eax
	push http_path_prefix
	push http_path_format
	push ebx
	push ecx
	call [snprintf]
	add esp, 28 ; clear the stack args

.pathcomplete:
	pop ecx ; contains ptr to full path

	push ecx
	push http_read_mode
	push ecx
	call [fopen]
	add esp, 8

	pop ecx ; get file name string
	push eax ; save file* result

	push ecx
	call [free] ; free file string
	add esp, 4

	pop eax
	push eax
	cmp eax, 0
	jz .404error

	; Send basic HTTP headers
	mov eax, [ebp+0x08]
	push eax
	call http_send_headers
	add esp, 4
	
	; Send the actual file requested
	mov eax, [esp]
	push eax
	mov eax, [ebp+0x08]
	push eax
	call http_send_file
	add esp, 8

	call [fclose] ; closes file* which is already on stack
	add esp, 4

	jmp .donsies

.404error:
	; Something went wrong and we wanna serve 404
	mov eax, [ebp+0x08]
	push eax
	call http_send_404
	add esp, 4
	jmp .donsies


.donsies:
	mov esp, ebp
	pop ebp
	ret

; Read all the headers from the request
; Returns: void
; Parameters:
;	+0x08 : SOCKET

http_read_headers:
	push ebp
	mov ebp, esp

	sub esp, 1024
	mov ebx, esp

.whileloop:
	; Read stuff until we run out of stuff to read
	push ebx

	push 0
	push 1024
	push ebx
	mov eax, [ebp+0x08]
	push eax
	call [recv]

	pop ebx

	cmp eax, 1024
	jz .whileloop

.done:

	mov esp, ebp
	pop ebp
	ret

; Sends unimplemented response
; Returns: void
; Parameters:
;	+0x08 : SOCKET

http_send_unimplemented:
	push ebp
	mov ebp, esp

	; Get the length of the 501 response
	push http_501_response
	call [strlen]
	add esp, 4

	; Send the 501 response
	push 0
	push eax
	push http_501_response
	mov eax, [ebp+0x08]
	push eax
	call [send]

	mov esp, ebp
	pop ebp
	ret

; Sends 404 response
; Returns: void
; Parameters:
;	+0x08 : SOCKET

http_send_404:
	push ebp
	mov ebp, esp

	; Get the length of the 404 response
	push http_404_response
	call [strlen]
	add esp, 4

	; Send the 404 response
	push 0
	push eax
	push http_404_response
	mov eax, [ebp+0x08]
	push eax
	call [send]

	mov esp, ebp
	pop ebp
	ret

; Send HTTP headers
; Returns: void
; Parameters:
;	+0x08 : SOCKET

http_send_headers:
	push ebp
	mov ebp, esp

	push http_basic_headers
	call [strlen]
	add esp, 4

	push 0
	push eax
	push http_basic_headers
	mov eax, [ebp+0x08]
	push eax
	call [send]

	mov esp, ebp
	pop ebp
	ret


; Sends a file to a given socket
; Returns: void
; Parameters:
;	+0x08 : SOCKET
;	+0x0c : FILE* file

http_send_file:
	push ebp
	mov ebp, esp

	; Stack space for a buffer
	sub esp, 1024
	mov ebx, esp ; Buffer ptr

	push ebx ; Preserve buffer ptr
	mov eax, [ebp + 0x0c]
	push eax
	push 1024
	push ebx
	call [fgets]
	add esp, 0xc
	pop ebx ; Restore buffer ptr

.whileloop:
	; feof(file)
	mov eax, [ebp + 0x0c]
	push eax
	call [feof]
	add esp, 4

	cmp eax, 0
	jnz .done

	push ebx
	push ebx
	call [strlen]
	add esp, 4
	pop ebx

	push ebx ; Preserve buffer ptr

	push 0
	push eax
	push ebx
	mov eax, [ebp+0x08]
	push eax
	call [send]

	pop ebx ; Restores buffer ptr

	push ebx ; Preserve buffer

	mov eax, [ebp + 0x0c]
	push eax
	push 1024
	push ebx
	call [fgets]
	add esp, 0xc

	pop ebx

	jmp .whileloop

.done:

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
	sub edx, esi
	mov eax, [ebp+0x10]
	dec edx
	sub eax, edx


	mov esp, ebp
	pop ebp
	ret

; Calls printf will all arguments then kills the program
http_die:
	pop eax
	call [printf]
	push 1
	call [exit]
	int 3