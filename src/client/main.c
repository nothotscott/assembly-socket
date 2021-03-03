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

int main(int argc, char *argv[]){
	int socketfd = 0, n = 0;
	struct sockaddr_in server_address;
	char* receive_buffer = calloc(BUFFER_SIZE, 1);

	// Create socket
	if((socketfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
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
	if(connect(socketfd, (struct sockaddr*)&server_address, sizeof(server_address)) < 0)
	{
		printf("\n Error : Connect Failed \n");
		return 1;
	}
	// Read the receive buffer
	while ((n = read(socketfd, receive_buffer, BUFFER_SIZE - 1)) > 0) {
		receive_buffer[n] = 0;
		if(fputs(receive_buffer, stdout) == EOF) {
			printf("\n Error : Fputs error\n");
		}
	}
	if(n < 0) {
		printf("\n Read error \n");
	}

	free(receive_buffer);
	return 0;
}