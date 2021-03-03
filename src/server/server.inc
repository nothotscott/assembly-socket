;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright(c) 2021 Scott Maday ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Defaults
DEFAULT	rel

; Declarations
%define BUFFER_SIZE	1024

%define PORT	9002

; External references
EXTERN	puts
EXTERN	calloc
EXTERN	free
EXTERN	memset
EXTERN	socket
EXTERN	htons
EXTERN	bind