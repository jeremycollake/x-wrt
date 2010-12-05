#include <stdio.h> 
#include <string.h> 
#include <malloc.h> 
#include <errno.h>
#include <ctype.h>
#include "util.h"
#include "files.h"
#include "pairs.h"
#include "config.h"

uci_logcheck *newData(){
	return ( uci_logcheck *)malloc( sizeof( uci_logcheck )) ;
}

uci_list *listNew(){
	uci_list *list = ( uci_list *)malloc( sizeof( uci_list )) ;
	list->first = NULL;
	list->last = NULL;
	list->count = 0;
	return list;
}

uci_logcheck *listAddlogcheck(uci_list* list, int enable, char* name, char* pattern, char* fields, int maxfail, char *script, pairlist_st *params ){
	uci_logcheck *d;
	uci_logcheck *p;
	d = ( uci_logcheck *)malloc( sizeof( uci_logcheck ));
	d->enable = enable;
	d->name = name;
	d->pattern = pattern;
	d->fields = fields;
	d->maxfail = maxfail;
	d->script = script;
	d->params = (struct pairlist_st *) params;
	d->next = NULL;
	if (list->last){
		p = list->last;
		p->next = d;
		d->prev = p;
	}
	if (list->first == NULL)
		list->first = d;
	list->last = d;
	list->count++;
	return d;
}

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
	int len = strlen(buf)+1;
	int i = 0;

	while (isspace(*buf)) buf++;
	while(*buf)
	{
		if(*buf == '\''
		|| *buf == '"' )
		{
			buf++;
			while( *buf != '\0'
				&& *buf != '\'' 
				&& *buf != '\"' )
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

void set_vars(char* line)
{
	char *name;
	char *value;
	name = malloc(strlen(line));
	value = malloc(strlen(line));
	if (strcmp(line, "")){
		printf("%d\n",sscanf(line, "option %s %[^\1]", name, value));
		printf("\t\t%s = %s\n", name, value);
	}
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
	char *line=NULL;
	if ((fp=fopen(conffile,"rb")) == NULL){
		printf("File Open Error: %s\n",strerror(errno));
		return -1;
	}
	listlogcheck = listNew();
	char type[33];
	char uname[65];
	char *uvalue=NULL;
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
//printf("\t%s = %s\n", reg->name, reg->value);
				ret = getucinext(fp, reg);
			}
			if (enable){
//				printf("enable: %d\nname: %s\npattern: %s\nfield: %s\nscript: %s\nmaxfail: %d\n", enable, name, pattern, fields, script, maxfail);
				listAddlogcheck(listlogcheck, enable, name, pattern, fields, maxfail, script, params );
//				printf("agrego a lista\nret: %d, type: %s, name: %s, value: %s\n", ret, type, uname, uvalue);
			} else {
				if (name) free(name);
				if (pattern) free(pattern);
				if (fields) free(fields);
				if (script) free(script);
				if (params) params = freePairList(params);
			}
		}
	}
//	reg = freeucireg(reg);
	uci_logcheck *checklog = listlogcheck->first;
printf("registros");
	while (checklog!=NULL){
		printf("LT_enable: %d\n", checklog->enable);
		printf("LT_name: %s\n", checklog->name);
		printf("LT_pattern: %s\n", checklog->pattern);
		printf("LT_fields: %s\n", checklog->fields);
		printf("LT_maxfail: %d\n", checklog->maxfail);
		printf("LT_script: %s\n", checklog->script);
		pair_st *params = checklog->params->first;
		while(params!=NULL){
			printf("%s: %s\n", params->name, params->value);
			params = params->next;
		}
		checklog = checklog->next;
printf("\n");
	}
}
