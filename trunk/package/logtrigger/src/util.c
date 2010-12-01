#include <malloc.h>
#include "util.h"

char *strndup(const char *s, size_t n)
{
	char *d;
	size_t i;
 
	if (!n)
		return NULL;

	d = malloc(n + 1);
	for (i = 0; i < n; i++)
		d[i] = s[i];
	d[i] = '\0';
	return d;
}

char *valuedup(const long int value)
{
	char *dec;
	dec = (char *)malloc(21 * sizeof(char));
	memset(dec,0,21);
	snprintf(dec, sizeof(dec), "%ld", value);
	return strdup(dec);
}

