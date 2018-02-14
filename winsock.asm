;;;;;;;;;;;;;;;;;
; WinSock Stuff ;
;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;
; Macro Defines ;
;;;;;;;;;;;;;;;;;

; Address family defines

	AF_UNSPEC 		equ	0
	AF_UNIX			equ	1
	AF_INET			equ 2
	AF_IMPLINK		equ 3
	AF_PUP			equ 4
	AF_CHAOS		equ	5
	AF_IPX			equ	6
	AF_NS			equ	6
	AF_ISO			equ 7
	AF_OSI			equ AF_ISO
	AF_ECMA			equ	8
	AF_DATAKIT		equ	9
	AF_CCITT		equ	10
	AF_SNA			equ	11
	AF_DECnet		equ	12
	AF_DLI			equ	13
	AF_LAT			equ	14
	AF_HYLINK		equ	15
	AF_APPLETALK	equ	16
	AF_NETBIOS		equ	17
	AF_VOICEVIEW	equ	18
	AF_FIREFOX		equ	19
	AF_UNKNOWN1		equ	20
	AF_BAN			equ	21
	AF_MAX			equ	22

; Socket types

	SOCK_STREAM		equ	1
	SOCK_DGRAM		equ	2
	SOCK_RAW		equ	3
	SOCK_RDM		equ	4
	SOCK_SEQPACKET	equ	5

; Socket return values

	INVALID_SOCKET	equ	not 0
	SOCKET_ERROR	equ	-1

; setsockopt stuff

	SOL_SOCKET		equ	0xffff

	SO_DEBUG		equ 0x0001
	SO_ACCEPTCONN	equ	0x0002
	SO_REUSEADDR	equ	0x0004
	SO_KEEPALIVE	equ	0x0008
	SO_DONTROUTE	equ	0x0010
	SO_BROADCAST	equ	0x0020
	SO_USELOOPBACK	equ	0x0040
	SO_LINGER		equ	0x0080
	SO_OOBINLINE	equ	0x0100

	SO_DONTLINGER	equ not SO_LINGER

;;;;;;;;;;;;;;;;;


winsock_setup:
	push ebp
	mov ebp, esp
	sub esp, 0x190 ; sizeof(WSADATA)

	mov eax, esp
	push eax ; Pointer to WSADATA structure

	push 0x0202 ; MAKEWORD(2,2)
	call [WSAStartup]

	xor ecx, ecx

	cmp eax, 0 ; if return value is 0 then we finish the function
	jz .done

	; if its not zero then print an error and cry.
	push eax
	push winsock_error_msg
	call [printf]
	add esp, 8

.done:
	mov esp, ebp
	pop ebp
	ret

winsock_cleanup:
	push ebp
	mov ebp, esp

	; Basically just this...
	; Not basically, actually just this.
	call [WSACleanup]

	mov esp, ebp
	pop ebp
	ret


