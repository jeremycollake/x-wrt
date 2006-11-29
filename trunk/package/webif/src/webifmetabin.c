/* silly stupid meta binary stub 
 * (c)2006 Jeremy Collake, released under GPL license. */

#include <stdio.h>
#include <string.h>

/* todo: if we add any more, maybe throw these in a table */
int wepkeygen_main(int argc, char **argv);
int int2human_main(int argc, char **argv);
int bstrip_main(int argc, char **argv);
int webifpage_main(int argc, char **argv);

int
main(int argc, char **argv)
{
	if(strstr(argv[0], "wepif-page")) 
	{
		return wepifpage_main(argc, argv);
	}
	else if(strstr(argv[0], "bstrip"))
	{
		return bstrip_main(argc, argv);
	}
	else if(strstr(argv[0], "int2human"))
	{
		return int2human_main(argc, argv);
	}
	else if(strstr(argv[0], "wepkeygen")) 
	{
		return wepkeygen_main(argc, argv);
	}
	else
	{
		printf(" ERR: Must symlink to bstrip, int2human, webif-page, or wepkeygen.\n");
	}	
	return 1;
}
