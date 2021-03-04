;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright(c) 2021 Scott Maday ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include	"common.inc"
%include	"server.inc"

; Data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SECTION	.rodata
error1:		db "Error binding",0
message1:	db "Listening",0
message2:	db "Client connected",0
format1:	db "%.24s",13,10,0

SECTION	.data
listen_fd:			dd 0
connection_fd:		dd 0
send_buffer_ptr:	dq 0
server_address:		times	_sockaddr_in_size db 0

; Code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SECTION	.text

GLOBAL	main
main:
	push	rbp
	mov		rbp, rsp
	sub		rsp, 16
	; Initialize variables
	mov		rdi, BUFFER_SIZE											; send_buffer_ptr = calloc(BUFFER_SIZE, 1)
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
		push	ax														; exit with error
		mov		rdi, error1
		call	puts
		jmp		.exit
	.bind_continue:
	; Listen for requests
	mov		edi, DWORD [listen_fd]										; listen(listen_fd, 10);
	mov		rsi, MAX_CONNECTIONS
	call	listen
	mov		rdi, message1
	call	puts

	.connect_loop:
		mov		edi, DWORD [listen_fd]									; accept(listen_fd, (struct sockaddr*)NULL, NULL);
		mov		rsi, 0
		mov		rdx, 0
		call	accept
		mov		DWORD [connection_fd], eax
		mov		rdi, message2
		call	puts
		; Send some cool stuff back
		mov		rdi, 0													; ticks = time(NULL);
		call	time
		mov		QWORD [rbp - 16], rax									; local variable ticks
		lea		rdi, [rbp - 16]											; snprintf(send_buffer, BUFFER_SIZE, "%.24s\r\n", ctime(&ticks));
		call	ctime
		mov		rdi, QWORD [send_buffer_ptr]
		mov		rsi, BUFFER_SIZE
		mov		rdx, format1
		mov		rcx, rax
		call	snprintf
		mov		edi, DWORD [connection_fd]								; write(connection_fd, send_buffer_ptr, strlen(send_buffer_ptr));
		mov		rsi, QWORD [send_buffer_ptr]
		movsx	rdx, eax												; size given by snprintf
		call	write
		; Close the connection and repeat
		mov		edi, DWORD [connection_fd]
		call	close
		mov		rdi, 1
		call	sleep
		jmp		.connect_loop

	push	BYTE 0														; default exit code
	.exit:
		mov		rdi, QWORD [send_buffer_ptr]
		call	free
		pop		di														; claim error from stack
		add		rsp, 16
		pop		rbp
		mov		rax, 60
		syscall