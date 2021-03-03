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

#define PORT	9002

#define BUFFER_SIZE	1024

int listen_fd, connection_fd;
struct sockaddr_in server_address;
char* send_buffer_ptr;

int main_prototype()
{
    time_t ticks;
    int ret;
	send_buffer_ptr = calloc(BUFFER_SIZE, 1);
	memset(&server_address, 0, sizeof(struct sockaddr_in));

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
		connection_fd = accept(listen_fd, (struct sockaddr*)NULL, NULL);
		//struct sockaddr_in* pV4Addr = (struct sockaddr_in*)&client_addr;
		//struct in_addr ipAddr = pV4Addr->sin_addr;
		printf("Client connected\n");
		// Send back some cool stuff
		ticks = time(NULL);
		int len = snprintf(send_buffer_ptr, BUFFER_SIZE, "%.24s\r\n", ctime(&ticks));
		write(connection_fd, send_buffer_ptr, len);
		// Close the connection
		close(connection_fd);
		sleep(1);
	}

	free(send_buffer_ptr);
	return 0;
}