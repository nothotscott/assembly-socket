;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright(c) 2021 Scott Maday ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Defaults
DEFAULT	rel

; Declarations
%define BUFFER_SIZE	1000

%define PORT			5000
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
EXTERN	printf
EXTERN	write
EXTERN	getpeername
EXTERN	inet_ntoa
EXTERN	pthread_create
EXTERN	pthread_detach
EXTERN	fgets
EXTERN	strcat
EXTERN	read
EXTERN	fputs

EXTERN	stdin
EXTERN	stdout