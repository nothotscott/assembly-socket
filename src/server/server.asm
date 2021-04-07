;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright(c) 2021 Scott Maday ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include	"common.inc"
%include	"server.inc"

EXTERN		stdin_listener

; Data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SECTION	.rodata
size1:		dd _sockaddr_in_size
error1:		db "Error binding",0
message1:	db "Listening",0
format1:	db "Client %s connected",10,0

SECTION	.data
listen_fd:			dd 0
connection_fd:		dd 0
stdin_buffer_ptr:	dq 0
send_buffer_ptr:	dq 0
receive_buffer_ptr:	dq 0
server_address:		times	_sockaddr_in_size db 0

GLOBAL	stdin_buffer_ptr
GLOBAL	send_buffer_ptr

; Code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SECTION	.text

GLOBAL	main
main:
	push	rbp
	mov		rbp, rsp
	sub		rsp, 32
	; Initialize variables
	mov		rdi, BUFFER_SIZE											; stdin_buffer_ptr = calloc(BUFFER_SIZE, 1)
	mov		rsi, 1
	call	calloc
	mov		QWORD [stdin_buffer_ptr], rax
	mov		rdi, BUFFER_SIZE											; send_buffer_ptr = calloc(BUFFER_SIZE, 1)
	mov		rsi, 1
	call	calloc
	mov		QWORD [send_buffer_ptr], rax
	mov		rdi, BUFFER_SIZE											; receive_buffer_ptr = calloc(BUFFER_SIZE, 1)
	mov		rsi, 1
	call	calloc
	mov		QWORD [receive_buffer_ptr], rax
	mov		rdi, server_address											; memset(&server_address, 0, sizeof(struct sockaddr_in));
	mov		rsi, 0
	mov		rdx, _sockaddr_in_size
	call	memset
	; Handle user input in a separate thread
	lea		rdi, [rbp - 0]												; threadid0
	mov		rsi, 0
	mov		rdx, stdin_listener
	mov		rcx, connection_fd
	call	pthread_create
	mov		rdi, rax
	call	pthread_detach
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
		; Accept the connection
		mov		edi, DWORD [listen_fd]									; accept(listen_fd, (struct sockaddr*)NULL, NULL);
		mov		rsi, 0
		mov		rdx, 0
		mov		rdx, 0
		call	accept
		mov		DWORD [connection_fd], eax
		; Resolve the IP address of the connection
		mov		edi, eax												; getpeername(connection_fd, (struct sockaddr*)&connection_addr, &connection_addr_len);
		lea		rsi, [rbp - 16]											; connection_addr is at rbp - 0
		mov		rdx, size1
		call	getpeername
		mov		rdi, [rbp - (16 - _sockaddr_in.sin_addr)]			 	; printf("...", inet_ntoa(connection_addr.sin_addr))
		call	inet_ntoa
		mov		rdi, format1
		mov		rsi, rax
		mov		rax, 0
		call	printf
		; Stay and read the client
		.read_client:
			mov		rdi, QWORD [connection_fd]							; read(connection_fd, receive_buffer_ptr, BUFFER_SIZE - 1)
			mov		rsi, QWORD [receive_buffer_ptr]
			mov		rdx, BUFFER_SIZE - 1
			call	read
			cmp		rax, 0
			jle		.read_client
			mov		rbx, QWORD [receive_buffer_ptr]								; receive_buffer_ptr[n] = 0;
			mov		BYTE [rbx + rax], 0
			mov		rdi, QWORD [receive_buffer_ptr]							; fputs(receive_buffer_ptr, stdout)
			mov		rsi, QWORD [stdout]
			call	fputs
			jmp		.read_client
		.read_client_end:
		; Close the connection and repeat
		mov		edi, DWORD [connection_fd]
		call	close
		jmp		.connect_loop

	push	BYTE 0														; default exit code
	.exit:
		mov		rdi, QWORD [stdin_buffer_ptr]
		call	free
		mov		rdi, QWORD [send_buffer_ptr]
		call	free
		mov		rdi, QWORD [receive_buffer_ptr]
		call	free
		pop		di														; claim error from stack
		add		rsp, 32
		pop		rbp
		mov		rax, 60
		syscall