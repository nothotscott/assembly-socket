;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright(c) 2021 Scott Maday ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Defaults
DEFAULT	rel

; Declarations
%define BUFFER_SIZE	1024

%define SERVER_PORT	9002

; External references
EXTERN	puts
EXTERN	calloc
EXTERN	free
EXTERN	socket
EXTERN	htons
EXTERN	inet_pton
EXTERN	connect
EXTERN	read
EXTERN	fputs
EXTERN	stdout