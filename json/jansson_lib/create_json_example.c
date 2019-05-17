#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <jansson.h>


int main(void)
{
	char *s;
	const char *devices[] = {"uuid_1", "uuid_2", "uuid_3"};
	const char *properties[] = {"prop1", "prop2", "prop3"};
	int i; 

	// Create json string
	json_t *root = json_object();
	json_t *dev_prop_pairs = json_array();

	for(i=0; i < 3; i++){
		json_t *dev_prop = json_object();
		json_object_set_new(dev_prop, "device", json_string(devices[i]));
		json_object_set_new(dev_prop, "property", json_string(properties[i]));
		json_array_append_new(dev_prop_pairs, dev_prop);
	}

	json_object_set_new(root, "stream_type", json_string("SUB_STREAM"));
	json_object_set_new(root, "end_time", json_integer(123456789));
	json_object_set_new(root, "devices", dev_prop_pairs);


	s = json_dumps(root, 0);

	puts(s);

	json_decref(root);
	free(s);
	// Parse json string
	json_error_t error;

	if(!asprintf(&s, "{\"device\":\"uuid1\",\"property\":\"property1\",\"value\":\"23\",\"timestamp\":123456789}")){
		fprintf(stderr, "Failed to create json string\n");	
		return 1;
	}

	root = json_loads(s, 0, &error);
	if(!root){
		fprintf(stderr, "Failed to load json string: %s\n", error.text);
		free(s);
		return 1;	
	}

	const char *device, *property, *value;
	int ts;
	json_unpack(root, "{s:s, s:s, s:s, s:i}", "device", &device, "property", &property, "value", &value, "timestamp", &ts);

	printf("device: %s\nproperty: %s\nvalue: %s\ntimestamp: %d\n", device, property, value, ts);

clean_up:
	json_decref(root);
	free(s);

	return 0;
}
