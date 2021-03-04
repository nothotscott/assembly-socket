;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright(c) 2021 Scott Maday ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include	"common.inc"
%include	"client.inc"

; Data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SECTION	.rodata
error1:		db "Error: inet_pton",0
error2:		db "Error: Connection failed",0
error3:		db "Read error",0
ip_address:	db "127.0.0.1",0

SECTION	.data
socket_fd:			dd 0
receive_buffer_ptr:	dq 0
server_address:		times	_sockaddr_in_size db 0

; Code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SECTION	.text

GLOBAL	main
main:
	push	rbp
	mov		rbp, rsp
	; Initialize variables
	mov		rdi, BUFFER_SIZE											; receive_buffer_ptr = calloc(BUFFER_SIZE, 1);
	mov		rsi, 1
	call	calloc
	mov		QWORD [receive_buffer_ptr], rax
	mov		rdi, server_address											; memset(&server_address, 0, sizeof(struct sockaddr_in));
	mov		rsi, 0
	mov		rdx, _sockaddr_in_size
	; Create socket
	mov		rdi, _AF_INET												; socket_fd = socket(AF_INET, SOCK_STREAM, 0);
	mov		rsi, _SOCK_STREAM
	mov		rdx, 0
	call	socket
	mov		DWORD [socket_fd], eax
	; Configure server(remote) address
	mov		WORD [server_address + _sockaddr_in.sin_family], _AF_INET
	mov		rdi, SERVER_PORT
	call	htons
	mov		WORD [server_address + _sockaddr_in.sin_port], ax
	mov		DWORD [server_address + _sockaddr_in.sin_addr], _INADDR_ANY
	mov		rdi, _AF_INET												; inet_pton(AF_INET, SERVER_IP, &server_address.sin_addr)
	mov		rsi, ip_address
	mov		rdx, server_address + _sockaddr_in.sin_addr
	call	inet_pton
	cmp		rax, 0
	jg		.inet_pton_continue
	.inet_pton_error:
		push	ax														; exit with error
		mov		rdi, error1
		call	puts
		jmp		.exit
	.inet_pton_continue:
	; Connect to the socket
	mov     edi, DWORD [socket_fd]										; connect(socket_fd, (struct sockaddr*)&server_address, sizeof(struct sockaddr_in))
	mov		rsi, server_address
	mov		edx, _sockaddr_in_size
	call    connect
	cmp		rax, 0
	jge		.connect_continue
	.connect_error:
		push	ax														; exit with error
		mov		rdi, error2
		call	puts
		jmp		.exit
	.connect_continue:
	; Read the socket and write to the receive buffer
	.buffer_loop:
		mov		edi, DWORD [socket_fd]									; read(socket_fd, receive_buffer_ptr, BUFFER_SIZE - 1)
		mov		rsi, QWORD [receive_buffer_ptr]
		mov		rdx, BUFFER_SIZE - 1
		call	read
		cdqe															; sign extend eax to rax
		cmp		rax, 0
		jle		.buffer_exit
		mov		rbx, [receive_buffer_ptr]								; receive_buffer_ptr[n] = 0;
		mov		BYTE [rbx + rax], 0
		mov		rdi, QWORD [receive_buffer_ptr]							; fputs(receive_buffer_ptr, stdout)
		mov		rsi, QWORD [stdout]
		call	fputs
		cmp		eax, -1													; EOF
		jne		.fputs_continue
		.fputs_error:
			mov		rdi, error2
			call	puts
		.fputs_continue:
		jmp		.buffer_loop
	.buffer_exit:
	cmp			rax, 0													; rax is n from the previous jump
	jge			.read_continue
	.read_error:
		push	1														; exit with error
		mov		rdi, error3
		call	puts
		jmp		.exit
	.read_continue:

	push	BYTE 0														; default exit code
	.exit:
		mov		rdi, QWORD [receive_buffer_ptr]
		call	free
		pop		di														; claim error from stack
		pop		rbp
		mov		rax, 60
		syscall