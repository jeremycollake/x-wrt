/* stupid stand-alone stub - jmc */ 
/* This code GPL, as if anyone cares. */

#include <stdio.h>
#include <stdlib.h>
#include "human_readable.h"

void usage() 
{
	printf("Usage: int2human integer1 integer2 integer3 ...\n\n"
		" Where integerX is an integer to convert to human readable form. If multiple\n"
		" integers are supplied, the output is delimited by a space. Currently this\n"
		" program is limited to integers the width of the system's unsigned long.\n\n");
}

int main(int argc, char **argv)
{
	if(argc<2)
	{
	 	usage();
		exit(1);
	}
	int nI;
	for(nI=1;nI<argc;nI++)
	{
		printf("%sB ", make_human_readable_str(strtoul(argv[nI], NULL, 10), 1,  0));
	}
	printf("\n");			
	exit(0);
}
