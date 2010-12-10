#include <malloc.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

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

long htoi (const char* s)
{
	char *hexval="0123456789ABCDEF";
	char *p = &s[strlen(s)-1];
    long deci = 0, dig = 0;
    int pos = 0;
	int i;
    if (s[0]=='0' && (s[1] == 'x' || s[1] == 'X')){
		while (p >= (s + 2)) {
			
			dig = strchr(hexval,toupper(*p))-hexval;
//			dig += pos*16;
//			if ((dig = (pos * 16)+strchr(hexval,toupper(*p)))< 0 ) {
//				printf("Error\n");
//				return -1;
//			}
			printf("%c = %d, %d, %ld\n", toupper(*p), strchr(hexval,toupper(*p))-hexval, pos, dig);
			deci += (deci*16)+dig;
			--p;
			++pos;
		}
    } else {
		printf("Error\n");
		return -1;
	}
    return deci;
}


