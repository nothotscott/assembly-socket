;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright(c) 2021 Scott Maday ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include	"server.inc"
%include	"common.inc"

; Data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SECTION	.rodata
error1:		db "Error binding",0
message:	db "Test",0

SECTION	.data
GLOBAL	listen_fd
GLOBAL	connection_fd
GLOBAL	send_buffer_ptr
GLOBAL	server_address
listen_fd:			dd 0
connection_fd:		dd 0
send_buffer_ptr:	dq 0
server_address:		times	_sockaddr_in_size db 0

; Code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SECTION	.text

EXTERN	main_prototype
GLOBAL	main
main:
	push	rbp
	mov		rbp, rsp
	sub		rsp, 16
	; Initialize variables
	mov		rdi, BUFFER_SIZE											; send_buffer = calloc(BUFFER_SIZE, 1)
	mov		rsi, 1
	call	calloc
	mov		QWORD [send_buffer_ptr], rax
	mov		rdi, server_address											; memset(&server_address, 0, sizeof(struct sockaddr_in));
	mov		rsi, 0
	mov		rdx, _sockaddr_in_size
	; Create socket
	mov		rdi, _AF_INET												; listen_fd = socket(AF_INET, SOCK_STREAM, 0);
	mov		rsi, _SOCK_STREAM
	mov		rdx, 0
	call	socket
	mov		DWORD [listen_fd], eax
	; Configure server(this) address
	mov		WORD [server_address + _sockaddr_in.sin_family], _AF_INET
	mov		rdi, PORT
	call	htons
	mov		WORD [server_address + _sockaddr_in.sin_port], ax
	mov		DWORD [server_address + _sockaddr_in.sin_addr], _INADDR_ANY
	; Bind the socket to the address
	mov		edi, DWORD [listen_fd]										; ret = bind(listen_fd, (struct sockaddr*)&server_address, sizeof(sockaddr_in));
	mov		rsi, server_address
	mov		rdx, _sockaddr_in_size
	call	bind
	mov		DWORD [rbp - 4], eax										; local variable ret
	cmp		eax, 0
	jge		.bind_continue
	.bind_error:
		push	rax
		mov		rdi, error1
		call	puts
		jmp		.exit
	.bind_continue:

	mov		rdi, message
	call	puts

	push	QWORD 0														; default exit code
	.exit:
		mov		rdi, QWORD [send_buffer_ptr]
		call	free
		pop		rdi
		add		rsp, 16
		pop		rbp
		mov		rax, 60
		syscall