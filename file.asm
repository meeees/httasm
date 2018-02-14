

string_thing db 'hello world', ENDL, 0

file_test:
	push ebp
	mov ebp, esp
	push string_thing
	call[printf]
	add esp, 4

	mov esp, ebp
	pop ebp
