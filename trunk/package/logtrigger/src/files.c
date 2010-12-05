#include <stdio.h> 
#include <string.h> 
#include <malloc.h> 

extern int DEBUG;

char *readline(FILE *fp, char *tmp)
{
	if (tmp!=NULL)
		free(tmp);
	tmp = NULL;
	char c;

	long len = 0;
	int fin = 0;
	while(!fin)
	{
		c=fgetc(fp);
		switch (c)
		{
			case EOF:
				if (len == 0) return NULL;
				fin = 1;
				c = '\n';
			case '\n':
				fin = 1;
			default:
				if (!(len % 16)){
					int nl = (int)(len/16)+1;
					nl*=16;
					tmp = realloc(tmp,(nl+1)*sizeof(char));
				}
				tmp[len] = c;
				len++;
				tmp[len] = '\0';
			break;
		}
	}
	return tmp;
}	

long getsize(const char *filename)
{
	long length;
	FILE *fp=fopen(filename,"rb"); 
	if(fp==NULL) { 
		printf("file not found!\n");
		length = -1;
	} else { 
		fseek(fp,0L,SEEK_END); 
		length=ftell(fp); 
	}
	fclose(fp);
	return length;
}	

