;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright(c) 2021 Scott Maday ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Defaults
DEFAULT	rel

; Declarations
%define BUFFER_SIZE	1024

%define PORT			9002
%define MAX_CONNECTIONS	10

; External references
EXTERN	puts
EXTERN	calloc
EXTERN	free
EXTERN	memset
EXTERN	socket
EXTERN	htons
EXTERN	bind
EXTERN	listen
EXTERN	accept
EXTERN	close
EXTERN	time
EXTERN	ctime
EXTERN	strlen
EXTERN	snprintf
EXTERN	write
EXTERN	sleep