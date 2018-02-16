format PE console
entry start

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Includes of macros
include 'include/win32a.inc'
include 'std.inc'
;;;;;;;;;;;;;;;;;;;;;;;;;;;


section '.impt' code readable executable

; Include of imports in a separate file.
include 'imports.asm'


section '.data' data readable writeable

; Data for use in the code below
include 'winsock_data.asm'
include 'http_data.asm'
include 'random_data.asm'

running_msg db '%s running on port %d', ENDL, 0

bad_socket_accept db 'Accepted bad socket, error 0x%x', ENDL, 0

bad_create_thread db 'Bad CreateThread call', ENDL, 0

section '.1337' code readable executable

; Code for execution
include 'winsock.asm'
include 'http.asm'
include 'random.asm'


start:

    call random_generate
    call random_generate
    call random_generate
    call random_print_states
    call random_clear_mem
    call random_generate

    ;call john_start

    push 0
    call [exit]
    int 3 ; If the program reaches here it will crash.

john_start:
    call winsock_setup

    ; Create the socket
    push 8080 ; Port to run on
    call http_create_listener
    add esp, 4

    push eax ; Little preservation

    push 8080
    push http_server_string
    push running_msg
    call [printf]
    add esp, 0xc

    pop ecx ; SOCKET now in ecx

.connectionLoop:
    push ecx ; preserve SOCKET

    sub esp, 0x10
    mov eax, esp
    mov dword [eax], 0
    mov dword [eax+0x4], 0
    mov dword [eax+0x8], 0
    mov dword [eax+0xc], 0

    push 0 ; Optional pointer to sizeof sockaddr
    push eax ; &sockaddr
    push ecx ; SOCKET
    call [accept]
    add esp, 0x10 ; Clear sockaddr from stack
    pop ecx

    cmp eax, INVALID_SOCKET ; Die if its a bad socket
    jnz .goodSocket

    call [GetLastError]
    push eax
    push bad_socket_accept
    call http_die

.goodSocket:

    ; If its a good socket spin off a new thread to handle the stuff.
    push ecx ; Preserve SOCKET

    push 0
    push 0
    push eax ; connection SOCKET
    push http_handle_request ; Start address of thread
    push 0
    push 0
    call [CreateThread]
    pop ecx

    cmp eax, 0 ; If its good then we continue the loop, if its bad we die.
    jnz .connectionLoop

    push ecx

    push bad_create_thread
    call [printf]
    add esp, 4

    call [closesocket] ; SOCKET is already on the stack.

    call winsock_cleanup
