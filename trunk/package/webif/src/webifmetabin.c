/* silly stupid meta binary stub */
#include <stdio.h>
#include <string.h>

int wepkeygen_main(int argc, char **argv);
int int2human_main(int argc, char **argv);
int bstrip_main(int argc, char **argv);

int
main(int argc, char **argv)
{
	if(strstr(argv[0], "wepkeygen")) 
	{
		return wepkeygen_main(argc, argv);
	}
	else if(strstr(argv[0], "int2human"))
	{
		return int2human_main(argc, argv);
	}
	else if(strstr(argv[0], "bstrip"))
	{
		return bstrip_main(argc, argv);
	}
	else
	{
		printf(" Usage: symlink to wepkeygen or int2human and run.\n");
	}	
	return 1;
}
