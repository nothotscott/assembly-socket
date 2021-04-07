/***
 * Note: This is not compiled at all. This simply demonstrates the assembly code
 */

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

#include <pthread.h>


#define SERVER_IP	"127.0.0.1"
#define SERVER_PORT	5000

#define BUFFER_SIZE	1000

int socket_fd = 0;
struct sockaddr_in server_address;
char* stdin_buffer_ptr;
char* send_buffer_ptr;
char* receive_buffer_ptr;

void* handle_input(void* fd) {
	while(1){
		if(fgets(stdin_buffer_ptr, BUFFER_SIZE, stdin)) {
			time_t ticks = time(NULL);
			snprintf(send_buffer_ptr, BUFFER_SIZE, "%.24s: ", ctime(&ticks));
			strcat(send_buffer_ptr, stdin_buffer_ptr);
			if(*(int*)fd){
				write(*(int*)fd, send_buffer_ptr, BUFFER_SIZE);
			}
		}
	}
	return 0;
}

int main(){
	int n = 0;
	pthread_t thread_id0;
	stdin_buffer_ptr = calloc(BUFFER_SIZE, 1);
	send_buffer_ptr = calloc(BUFFER_SIZE, 1);
	receive_buffer_ptr = calloc(BUFFER_SIZE, 1);
	// Handle user input
	pthread_detach(pthread_create(&thread_id0, NULL, handle_input, &socket_fd));
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
	// Get IP
	struct sockaddr_in connection_addr;
	socklen_t connection_addr_len = sizeof(struct sockaddr_in);
	getpeername(socket_fd, (struct sockaddr*)&connection_addr, &connection_addr_len);
	printf("Connected to server %s\n", inet_ntoa(connection_addr.sin_addr));
	// Read the receive buffer
	while(1){
		while ((n = read(socket_fd, receive_buffer_ptr, BUFFER_SIZE - 1)) > 0) {
			receive_buffer_ptr[n] = 0;
			if(fputs(receive_buffer_ptr, stdout) == EOF) {
				printf("\n Error : Fputs error\n");
			}
		}
	}
	if(n < 0) {
		printf("\n Read error \n");
	}

	free(stdin_buffer_ptr);
	free(send_buffer_ptr);
	free(receive_buffer_ptr);
	return 0;
}