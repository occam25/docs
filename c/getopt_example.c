
#include <stdio.h>
#include <stdlib.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <getopt.h>

#include "mqtt.h"

const char* program_name;

static int connected = 0;

void print_usage (FILE* stream, int exit_code)
{
	fprintf(stream, "Usage:  %s options \n", program_name);
	fprintf(stream,
			"-h --help      :  Shows this help\n"
			"-p --port      :  Brocker port (Default: 1883)\n"
			"-s --server    :  Brocker host (Default: localhost)\n"
			"-u --user      :  User name\n"
			"-P --password  :  Password\n");
	exit(exit_code);
}

static void mqtt_client_connected(mqtt_connection_t *conn, void *user_data)
{
	fprintf(stderr, "Connected callback called!");
	connected = 1;
}

int main(int argc, char* argv[])
{
	int next_option;
	int port = 1883;
	char *server = NULL;
	char *user = NULL;
	char *password = NULL;

	const char* const short_options = "hp:s:u:P:";
	const struct option long_options[] = {
		{ "help",     0, NULL, 'h' },
		{ "port",     1, NULL, 'p' },
		{ "server",   1, NULL, 's' },
		{ "user",     1, NULL, 'u' },
		{ "password", 1, NULL, 'P' },
		{ NULL,       0, NULL, 0   }
	};

	program_name = argv[0];

	do{
		next_option = getopt_long(argc, argv, short_options, long_options, NULL);
		switch(next_option){
			case 'h':
				print_usage(stdout, 0);
				break;
			case 'p':
				port = atoi(optarg);
				break;
			case 's':
				server = optarg;
				break;
			case 'u':
				user = optarg;
				break;
			case 'P':
				password = optarg;
				break;
			case '?':
				print_usage(stderr, 1);
				break;
			case -1:
				break;
			default:
				print_usage(stderr, 1);
				break;
		}
	}while(next_option != -1);

	if(user == NULL || password == NULL){
		fprintf(stderr, "You need to define user and password\n");
		exit(1);
	}

	if(server == NULL)
		server = strdup("localhost");


	mqtt_cb_t mqtt_callbacks = {
		.connected = mqtt_client_connected,
		.disconnected = NULL,
		.published = NULL,
		.user_data = NULL
	};

	mqtt_connection_t *mqtt = mqtt_connect("device_id", server, port, user, password, &mqtt_callbacks);
	if(!mqtt){
		fprintf(stderr, "Failed to connect to MQTT\n");
		return 1;
	}

	int cnt = 0;
	while((!connected)&&(cnt < 20)){
		cnt++;
		sleep(1);
	}

	free(user);
	free(password);
	free(server);

	return 0;
}

