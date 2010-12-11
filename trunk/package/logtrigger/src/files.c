#include <stdio.h> 
#include <stdlib.h>
#include <string.h> 
#include <malloc.h> 
#include <errno.h>
#include "files.h"
extern int errno;
extern int DEBUG;

FILE *fileOpen(const char *filename, const char *mode)
{
	FILE *fp=fopen(filename,mode);
	if(fp==NULL) { 
		if (DEBUG>5)
			printf("File Open Error %s: (%d)-%s\n",filename, errno, strerror(errno));
	}
	return fp;
}

char *readfile(FILE *fp, char *tmp)
{
	char line[4096];
	long r = 0;
	if (tmp!=NULL)
		free(tmp);
	tmp = NULL;
	while (!feof(fp)) {
		r++;
		if (fgets(line,4096,fp)){
			if (tmp==NULL) {
				tmp = malloc(strlen(line)+1 * sizeof(char));
				if (tmp==NULL){
					printf("file.c 30 malloc Error (%d) %s", errno, strerror(errno));
					exit(1);
				}
				strcpy(tmp, line);
			} else {
				int len = strlen(tmp);
				len += strlen(line) + 1;
				tmp = realloc(tmp, (len * sizeof(char)));
				if (tmp==NULL){
					printf("file.c 39 malloc Error (%d) %s", errno, strerror(errno));
					exit(1);
				}
				tmp = strcat(tmp,line);
			}
		}
	}
	return tmp;
}

char *readNewLines(const char *filename, long *last, char *tmp)
{
	if (tmp!=NULL)
		free(tmp);
	tmp = NULL;
	FILE *fp=fileOpen(filename,"rb");
	if(fp==NULL) { 
		*last = 0;
	} else {
		fseek(fp, (long) *last, SEEK_SET);
		if (DEBUG>5)
			printf("------------ %s -----------------\n", filename);
		tmp = readfile(fp,tmp);
		*last = (long) ftell(fp);
		fclose(fp);
	}
	return tmp;
}

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
	FILE *fp=fileOpen(filename,"rb"); 
	if(fp==NULL) {
		length = -1;
	} else { 
		fseek(fp,0L,SEEK_END); 
		length=ftell(fp); 
		fclose(fp);
	}
	return length;
}	

