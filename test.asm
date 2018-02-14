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
include 'file_data.asm'


section '.1337' code readable executable

; Code for execution
include 'winsock.asm'
include 'file.asm'


start:
    call file_test
    push 0
    call [exit]
    int 3 ; If the program reaches here it will crash.