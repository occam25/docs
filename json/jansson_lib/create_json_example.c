#include <stdio.h>
#include <string.h>
#include <jansson.h>


int main(void)
{
	char *s;
	const char *devices[] = {"uuid_1", "uuid_2", "uuid_3"};
	const char *properties[] = {"prop1", "prop2", "prop3"};
	int i; 

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

	return 0;
}
