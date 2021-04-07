/***
 * Note: This is not compiled at all. This simply demonstrates the assembly code
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <errno.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <sys/ioctl.h>
#include <net/if.h>

#include <pthread.h>

#define PORT	5000

#define BUFFER_SIZE	1000

int listen_fd, connection_fd;
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

int main()
{
	int n = 0;
    int ret;
	stdin_buffer_ptr = calloc(BUFFER_SIZE, 1);
	send_buffer_ptr = calloc(BUFFER_SIZE, 1);
	receive_buffer_ptr = calloc(BUFFER_SIZE, 1);
	memset(&server_address, 0, sizeof(struct sockaddr_in));
	pthread_t thread_id0;
	// Handle user input
	pthread_detach(pthread_create(&thread_id0, NULL, handle_input, &connection_fd));
	// Create a socket
	listen_fd = socket(AF_INET, SOCK_STREAM, 0);
	// Configure server(this) address
	server_address.sin_family = AF_INET;
	server_address.sin_port = htons(PORT);
	server_address.sin_addr.s_addr = INADDR_ANY;	// will bind socket to all local interfaces
	// Bind the socket to the address
	ret = bind(listen_fd, (struct sockaddr*)&server_address, sizeof(struct sockaddr_in));
	//printf("listen_fd=%d", listen_fd);
	if (ret < 0) {
		printf("Error binding!\n");
		exit(ret);
	}
	printf("Binding done...\n");
	// Listen for requests
	listen(listen_fd, 10);
	printf("Listening\n");
	while(1) {
		struct sockaddr_in connection_addr;
		connection_fd = accept(listen_fd, (struct sockaddr*)NULL, NULL);
		socklen_t connection_addr_len = sizeof(struct sockaddr_in);
		getpeername(connection_fd, (struct sockaddr*)&connection_addr, &connection_addr_len);
		printf("Client %s connected\n", inet_ntoa(connection_addr.sin_addr));
		while(1){
			while ((n = read(connection_fd, receive_buffer_ptr, BUFFER_SIZE - 1)) > 0) {
				receive_buffer_ptr[n] = 0;
				if(fputs(receive_buffer_ptr, stdout) == EOF) {
					printf("\n Error : Fputs error\n");
				}
			}
		}
		// Close the connection
		close(connection_fd);
	}

	free(stdin_buffer_ptr);
	free(send_buffer_ptr);
	free(receive_buffer_ptr);
	return 0;
}