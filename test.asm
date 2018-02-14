format PE console
entry start

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Includes of macros
include 'include/win32a.inc'
include 'std.inc'
;;;;;;;;;;;;;;;;;;;;;;;;;;;

section '.1337' code readable executable writeable

data import
    library msvcrt, 'msvcrt.dll'
    import msvcrt,\
        printf , 'printf',\
        scanf , 'scanf'
end data

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