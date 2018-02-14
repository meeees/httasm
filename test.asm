format PE console
entry start

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Includes of macros
include 'include/win32a.inc'
include 'std.inc'
;;;;;;;;;;;;;;;;;;;;;;;;;;;

section '.1337' code readable executable

data import
    library msvcrt, 'msvcrt.dll', \
        ws2_32 , 'ws2_32.dll'

    import msvcrt,\
        printf , 'printf',\
        scanf , 'scanf'

    import ws2_32,\
        WSAStartup , 'WSAStartup', \
        WSACleanup , 'WSACleanup', \
        bind , 'bind', \
        listen , 'listen', \
        accept , 'accept', \
        recv , 'recv', \
        send , 'send'
end data

include 'winsock.asm'

frmt db '%d',0,0

start:
    sub esp, 4
    mov ebp, esp
    push ebp
    push frmt
    call [scanf]
    add esp, 8
    mov byte[frmt+2],0x20
    mov ecx, 1
.divloop:
    xor edx, edx
    mov eax, [ebp]
    idiv ecx
    test edx, edx
    jnz .contloop
    push ecx
    push frmt
    call [printf]
    pop ecx
    pop ecx
.contloop:
    inc ecx
    cmp ecx, [ebp]
    jng .divloop
    add esp, 4
    ret