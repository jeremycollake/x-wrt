#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <malloc.h> 
#include <errno.h>
#include <ctype.h>
#include "util.h"
#include "files.h"
#include "config.h"
#include "confreg.h"

extern int errno;
extern int DEBUG;
extern uci_list *listlogcheck;
extern filelist_st *files;

void remove_comment(char *str)
{
	int nl = 0;
	if (strchr(str,'\n')) nl = 1;
	while(*str)
	{
		switch (*str)
		{
			case '\'':
			case '"':
				str++;
				while(str && *str!='\'' && *str!='"' ) str++;
				str++;
			break;
			case '#':
				if (nl){
					*str = '\n';
					str++;
				}
				*str = '\0';
			break;
		}
		str++;
	}
}

void clean_str(char *str)
{
	char *newstr;
	const char *buf = str;
	newstr = (char*) malloc((strlen(buf)+10)*sizeof(char));
	int i = 0;

	while (isspace(*buf)) buf++;
	while(*buf)
	{
		if(*buf == '\''
		|| *buf == '"' )
		{
			char end = *buf;
			buf++;
			while( *buf != '\0'
				&& *buf != end )
			{
				if (*buf == '\\'){
					newstr[i++] = *(buf++);
				}
				newstr[i++] = *(buf++);
			}
			buf++;
		} else if(!isspace(*buf)){
			newstr[i++] = *(buf++);
		} else if (*buf == '\n'){
			buf++;
		} else {
			newstr[i++] = ' ';
			while (isspace(*buf))
				buf++;
		}
	}
	newstr[i] = '\0';
	str = realloc(str,(strlen(newstr)+1)*sizeof(char));
	strcpy(str, newstr);
	free(newstr);
}

char *readuci_line(FILE *fp, char* tmp)
{
	tmp = readline(fp, tmp);
	if (tmp){
		remove_comment(tmp);
		clean_str(tmp);
	}
	return tmp;
}

uci_reg *newucireg()
{
	uci_reg *reg = malloc(sizeof(uci_reg));
	reg->ret = 0;
	reg->type=malloc(33*sizeof(char));
	reg->name=malloc(65*sizeof(char));
	reg->value=NULL;
	return reg;
}

void *freeucireg(uci_reg *reg)
{
	if (reg->type) free(reg->type);
	if (reg->name) free(reg->name);
	if (reg->value) free(reg->value);
	free(reg);
	return NULL;
}


int getucinext(FILE *fp, uci_reg *reg)
{
	int ret=0;
	char *line = NULL;
	memset(reg->type,'\0', 32* sizeof(char));
	memset(reg->name,'\0', 64* sizeof(char));
	if (reg->value!=NULL)
		free(reg->value);
	reg->value=NULL;
	do {
		ret = -1;
		if (line) free(line);
		line=NULL;
		line = readuci_line(fp, line);
		if (line && strcmp(line,"")) {
			reg->value = realloc(reg->value, (strlen(line)+1)*sizeof(char));
			reg->ret = ret = sscanf(line, "%s %s %[^\1]", reg->type, reg->name, reg->value);
		}
	} while(line!=NULL && ret < 2);
	if (line) free(line);
	line=NULL;
	return ret;
}


void read_conf(const char *conffile)
{
	FILE *fp; 
	if ((fp=(FILE *)fileOpen(conffile, "rb")) == NULL){
		exit(-1);
	}

	listlogcheck = listNew();
	files = newFileList();

	int ret = 0;
	uci_reg *reg=newucireg();
	
	ret = getucinext(fp, reg);
	while (ret >= 0){
		if (ret == 2 && !strcmp(reg->name, "rule")){
			ret = getucinext(fp, reg);
				int enable;
				char *name;
				char *pattern;
				char *fields;
				int maxfail = 0;
				char *script;
				pairlist_st *params = (pairlist_st *)newPairList();
			
				while (ret == 3)
				{
					if (!strcmp(reg->name,"enable")){
						enable=atoi(reg->value);
					} else if (!strcmp(reg->name,"name")){
						name = strndup(reg->value,strlen(reg->value));
					} else if (!strcmp(reg->name,"pattern")){
						pattern = strndup(reg->value,strlen(reg->value));
					} else if (!strcmp(reg->name,"fields")){
						fields = strndup(reg->value,strlen(reg->value));
					} else if (!strcmp(reg->name,"script")){
						script = strndup(reg->value,strlen(reg->value));
					} else if (!strcmp(reg->name,"maxfail")){
						maxfail = atoi(reg->value);
					} else {  // Add user parameters to destination script
						char tmp[68];
						sprintf( tmp, "LT_%s", reg->name );
						addPair(params, (char *)strndup(tmp, strlen(tmp)), (char *)strndup(reg->value, strlen(reg->value)));
					}
					if (DEBUG > 5)
						printf("\t%s = %s\n", reg->name, reg->value);
					ret = getucinext(fp, reg);
				}
				if (enable){
					listAddlogcheck(listlogcheck, enable, name, pattern, fields, maxfail, script, params );
				} else {
					if (name) free(name);
					if (pattern) free(pattern);
					if (fields) free(fields);
					if (script) free(script);
					if (params) params = freePairList(params);
				}
				if (DEBUG > 5) printf("\n");				
		} else if (ret == 2 && !strcmp(reg->name, "logfile")){
			ret = getucinext(fp, reg);
			int disabled = 0;
			char *logfilename=NULL;
			while (ret == 3 && !strcmp(reg->type, "option"))
			{
				if (!strcmp(reg->type, "option") && !strcmp(reg->name,"file") && ret == 3)
					logfilename = strndup(reg->value, strlen(reg->value));
				if (!strcmp(reg->type, "option") && !strcmp(reg->name,"disabled") && ret == 3)
					disabled = atoi(reg->value);
				ret = getucinext(fp, reg);
			}
				addFile(files,logfilename,disabled);
			if (logfilename)
				free(logfilename);
		} else {
			ret = getucinext(fp, reg);
		}
	}
	reg = freeucireg(reg);
	uci_logcheck *checklog = listlogcheck->first;
}
