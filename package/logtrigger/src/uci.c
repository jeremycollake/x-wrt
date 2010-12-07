/*
 * uci - interface to read uci files
 *
 * Copyright (C) 2010 Fabian Omar Franzotti <fofware@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 2.1
 * as published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */
/*
 * Special Thanks to Jo-Philipp Wich 
 */
#include <stdio.h>
#include <strings.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include "util.h"
#include "files.h"
#include "uci.h"

extern int DEBUG;
extern uci_list *listlogcheck;
extern filelist_st *files;

void read_conf_uci(const char *name)
{
	struct uci_context *ctx;
	struct uci_package *p = NULL;

	ctx = uci_alloc_context();
	if (!ctx)
		return;

	uci_load(ctx, name, &p);
	if (!p) {
		uci_perror(ctx, "Failed to load config file: ");
		uci_free_context(ctx);
		exit(-1);
	}

	parse_sections(p);
	uci_free_context(ctx);
}

static void do_logcheck(struct uci_section *s)
{
	struct uci_element *n;
	bool enable;
	char *name;
	char *pattern;
	char *fields;
	int maxfail = 0;
	char *script;
	pairlist_st *params = (pairlist_st *)newPairList();
	
	uci_foreach_element(&s->options, n) {
		struct uci_option *o = uci_to_option(n);
		if (!strcmp(n->name,"enable")){
			if(!strcmp(o->v.string,"1")){
				enable=1;
			}else{
				enable=0;
			}
		} else if (!strcmp(n->name,"name")){
			name = malloc(strlen(o->v.string));
			strcpy(name,o->v.string);
		} else if (!strcmp(n->name,"pattern")){
			pattern = malloc(strlen(o->v.string));
			strcpy(pattern,o->v.string);
		} else if (!strcmp(n->name,"fields")){
			fields = malloc(strlen(o->v.string));
			strcpy(fields,o->v.string);
		} else if (!strcmp(n->name,"script")){
			script = malloc(strlen(o->v.string));
			strcpy(script,o->v.string);
		} else if (!strcmp(n->name,"maxfail")){
			maxfail = atoi(o->v.string);
		} else {  // Add user parameters to destination script
			char tmp[65];
			sprintf( tmp, "LT_%s", n->name );

			addPair(params, (char *)strndup(tmp, strlen(tmp)), (char *)strndup(o->v.string, strlen(o->v.string)));
		}
	}
	if (enable == 1){
		listAddlogcheck(listlogcheck, enable, name, pattern, fields, maxfail, script, params );
	} else {
		if (name) free(name);
		if (pattern) free(pattern);
		if (fields) free(fields);
		if (script) free(script);
		if (params) params = freePairList(params);
	}
}

static void do_logfiles(struct uci_section *s)
{
	struct uci_element *n;
	
	uci_foreach_element(&s->options, n) {
		struct uci_option *o = uci_to_option(n);
		printf("\t%s->%s\n", n->name, o->v.string);
	}
}

/*
static void do_logfiles(struct uci_section *s)
{
	struct uci_element *n;
//	este es para leer list y no option
	struct uci_element *l;
//
	printf("Permanent Blocked\n");
	uci_foreach_element(&s->options, n) {
		struct uci_option *o = uci_to_option(n);
		uci_foreach_element(&o->v.list,l) {
			printf("\t%s->%s\n", n->name, l->name);
		}
	}
}
*/
/*
static void do_blocked(struct uci_section *s)
{
	struct uci_element *n;
//	char *tmp=NULL;
	char *hasta=NULL;
	char *host=NULL;
	char *mask=NULL;
	
	uci_foreach_element(&s->options, n) {
		struct uci_option *o = uci_to_option(n);
		int len = strlen(o->v.string)+1;
		if (!strcmp(n->name,"host")){
			host = (char*)realloc(host,sizeof(char)*len);
			strcpy(host,o->v.string);
		}
		if (!strcmp(n->name,"mask")){
			mask = (char*)realloc(mask,sizeof(char)*len);
			mask = strcpy(mask,o->v.string);
		}

		if (!strcmp(n->name,"until")){
			hasta = (char*)realloc(hasta,sizeof(char)*len);
			strcpy(hasta,o->v.string);
		}

	}

	if (host){
		printf("Block: %s",host);
		if (mask) 
			printf("/%s",mask);
	}
	if (hasta)
		printf(" until %s", hasta);
	printf("\n");

}
*/
static void parse_sections(struct uci_package *p)
{
	struct uci_element *e;
	struct uci_section *s;
	uci_foreach_element(&p->sections, e) {
		s = uci_to_section(e);
		if (strcmp(s->type, "rule") == 0){
			do_logcheck(s);
		}

		if (strcmp(s->type, "logfile") == 0){
			do_logfiles(s);
		}
	}
	
}



/*
int main(void)
{
	listlogcheck = listNew();
	int j = 4;
	hostblock_load_uci("hostblock");
	printf("en la lista %d\n", listlogcheck->count);
	uci_logcheck *algo = listlogcheck->first;
	while (algo!=NULL){
		printf("%s - %s %d\r\n",algo->pattern, algo->action, algo->maxfail);
		if (!(j < algo->maxfail))
			printf("---------------------------------- Este llegó al maximo --------------\n");
		algo = algo->next;

	}
	printf("Salio\n");
	return 0;
}
*/