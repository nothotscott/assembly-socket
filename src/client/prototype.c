#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <errno.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>


#define SERVER_IP	"127.0.0.1"
#define SERVER_PORT	9002

#define BUFFER_SIZE	1024

int socket_fd = 0;
struct sockaddr_in server_address;
char* receive_buffer_ptr;

int main_prototype(){
	int n = 0;
	receive_buffer_ptr = calloc(BUFFER_SIZE, 1);

	// Create socket
	if((socket_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		printf("\n Error : Could not create socket \n");
		return 1;
	}
	// Configure server address
	memset(&server_address, '0', sizeof(server_address));
	server_address.sin_family = AF_INET;
	server_address.sin_port = htons(SERVER_PORT);
	if(inet_pton(AF_INET, SERVER_IP, &server_address.sin_addr)<=0)
	{
		printf("\n inet_pton error occured\n");
		return 1;
	}

	// Connect to the socket
	if(connect(socket_fd, (struct sockaddr*)&server_address, sizeof(server_address)) < 0)
	{
		printf("\n Error : Connect Failed \n");
		return 1;
	}
	// Read the receive buffer
	while ((n = read(socket_fd, receive_buffer_ptr, BUFFER_SIZE - 1)) > 0) {
		receive_buffer_ptr[n] = 0;
		if(fputs(receive_buffer_ptr, stdout) == EOF) {
			printf("\n Error : Fputs error\n");
		}
	}
	if(n < 0) {
		printf("\n Read error \n");
	}

	free(receive_buffer_ptr);
	return 0;
}