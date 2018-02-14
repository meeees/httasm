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


section '.1337' code readable executable

; Code for execution
include 'winsock.asm'

; TODO: real stuff

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
