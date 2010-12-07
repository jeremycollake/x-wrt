#include <stdio.h> 
#include <string.h> 
#include <malloc.h> 

#include "confreg.h"
#include "util.h"
#include "tail.h"
#ifndef OPENWRT
	#include "config.h"
#endif
#ifdef OPENWRT
	#include "uci.h"
#endif


extern int DEBUG;
extern uci_list *listlogcheck;
extern filelist_st *files;

//char *strndup(const char *s, size_t n);

/*
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
*/

char *readfile(FILE *fp)
{
	char line[4096];
	long r = 0;
	char *tmp=NULL;
	while (!feof(fp)) {
		r++;
		if (fgets(line,4096,fp)){
			if (tmp==NULL) {
				tmp = malloc(strlen(line)+1 * sizeof(char));
				strcpy(tmp, line);
			} else {
				int len = strlen(tmp);
				len += strlen(line) + 1;
				tmp = realloc(tmp, (len * sizeof(char)));
				tmp = strcat(tmp,line);
			}
		}
	}
	return tmp;
}	

char *readlines(const char *filename, long *last)
{
	FILE *fp=fopen(filename,"rb");
	char *line=NULL;
	if(fp==NULL) { 
		printf("Opening: %s file not found!\n", filename);
		*last = 0;
	} else {
		fseek(fp, (long) *last, SEEK_SET);
		printf("------------ %s -----------------\n", filename);
		line = readfile(fp);
	}
	*last = (long) ftell(fp);
	fclose(fp);
	return line;
}
/*
long getsize(const char *filename)
{
	long length;
	FILE *fp=fopen(filename,"rb"); 
	if(fp==NULL) { 
		printf("Opening: %s file not found!\n", filename);
		length = -1;
	} else { 
		fseek(fp,0L,SEEK_END); 
		length=ftell(fp); 
	}
	fclose(fp);
	return length;
}	
*/
int logsread(void) 
{ 
	FILE *fp; 
	int i;
	long length; 
	long lineas;
#ifdef OPENWRT
	printf("Read configuraton from uci logtrigger\n");
	read_conf_uci("logtrigger");
#endif
#ifndef OPENWRT
	if (DEBUG)
		printf("Read configuration from file\n");
	read_conf("logtrigger.conf");
#endif
	char *filename = "/var/log/asterisk/full";
	long lastread = getsize(filename);
	long checkfile;
	while(1){
		file_st *file = files->first;
		while(file){
			if ((checkfile = getsize(file->name)) != file->lasteof)
			{
				if (checkfile < file->lasteof ) file->lasteof = 0;
				char *line = readlines(file->name, &file->lasteof);
				printf("%s", line);
			}
			file = file->next;
		}
		sleep(1);
	}

	return 0; 
} 
