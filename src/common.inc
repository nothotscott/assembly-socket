;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright(c) 2021 Scott Maday ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%define	_SOCK_STREAM	1	; TCP connection
%define	_SOCK_DGRAM		2	; UDP connectionless

%define	_AF_INET	2		; IPv4
%define	_AF_INET6	10		; IPv6

%define	_INADDR_ANY			0x00000000
%define	_INADDR_BROADCAST	0xffffffff
%define	_INADDR_LOOPBACK	0x7f000001

struc	_sockaddr
	.sa_family:	resw 1
	.sa_date:	resb 14
endstruc

struc	_sockaddr_in
	.sin_family:	resw 1
	.sin_port:		resw 1
	.sin_addr:		resd 1
	resb 8
endstruc