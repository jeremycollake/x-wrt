/*
 * scan - functions to find and match text 
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
#include <syslog.h>

#include "util.h"
#include "scan.h"
extern int DEBUG;

#define isoctdigit(a) (a >= '0' && a <= '7')

/* Returns number of values scan will return */
int scan_count(const char *fmt)
{
	int count = 0;
	while (*fmt) {
		if (*fmt == '%') {
			if (*(++fmt) == '*')
				continue;

			while (isdigit(*fmt))
				fmt++;

			if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u' ||
				*fmt == 'f' ||
				*fmt == 'o' || *fmt == 'x' || *fmt == 'X' ||
				*fmt == 'c' || *fmt == 's' || *fmt == 'b') {
				count++;
			} else {
				printf("Error: unrecognized pattern type: `%%%c'\n", *fmt);
				syslog(LOG_DEBUG, "Error: unrecognized pattern type: `%%%c'\n", *fmt);
				exit(1); // FIXME
			}
		}

		fmt++;
	}
	return count;
}

void matchString(match_t *results)
{
	if (results->values->count == results->find)
	{
		int lentotal=0;
		char *fmt = results->pattern;
		char *newstr;
		element_st *values = (element_st *)results->values->first;
		while (values){
			lentotal += strlen(values->value)+1;
			values = (element_st *)values->next;
		}
		lentotal += strlen(results->pattern);
		newstr = malloc(lentotal+1);
		int cnew = 0;
		values = (element_st *)results->values->first;
		while (*fmt && values) {
			if (*fmt == '%') {
				if (*(++fmt) == '*')
					continue;
				while (isdigit(*fmt))
					fmt++;
				if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u' ||
					*fmt == 'f' ||
					*fmt == 'o' || *fmt == 'x' || *fmt == 'X' ||
					*fmt == 'c' || *fmt == 's' || *fmt == 'b') {
					char *toadd = values->value;
					while(*toadd){
						newstr[cnew++] = *toadd;
						newstr[cnew] = '\0';
						toadd++;
					}
					values = (element_st *)values->next;
				} else {
					printf("Error: unrecognized pattern type: `%%%c'\n", *fmt);
					syslog(LOG_DEBUG, "Error: unrecognized pattern type: `%%%c'\n", *fmt);
					exit(1); // FIXME
				}
			} else {
				newstr[cnew++] = *fmt;
				newstr[cnew] = '\0';
			}
			fmt++;
		}
		lentotal = strlen(newstr);
		results->string = malloc(lentotal+1);
		strcpy(results->string,newstr);
		results->string[lentotal] = '\0';
		free(newstr);
	}
}		

void addToList(list_st *list, const char *value)
{
	element_st *d;
	element_st *p;
	int len = strlen(value);
	d = ( element_st *) malloc(sizeof( element_st ));
	d->value = (char *) malloc((len+1) * sizeof(char));
	strcpy(d->value, value);
	d->value[len] = '\0';
	d->next = NULL;
	if (list->last){
		p = (element_st *)list->last;
		p->next = (struct element_st *) d;
		d->prev = (struct element_st *) p;
	}
	if (list->first == NULL)
		list->first = (struct element_st *) d;
	list->last = (struct element_st *) d;
	list->count++;
}

list_st * initList(){
	list_st *list = (list_st *) malloc( sizeof(list_st));
	list->first = NULL;
	list->last = NULL;
	list->count = 0;
	return list;
}

match_t *initMatch(uci_logcheck *checklog)
{
	match_t *result = (match_t *) malloc(sizeof(match_t));
	result->find = scan_count(checklog->pattern);
	result->pattern = (char *) malloc((strlen(checklog->pattern)+1) * sizeof(char));
	if (result->pattern==NULL)
	{
		printf("Error: Memory could not be allocated creating match_t*\n");
		exit(-1);
	}
	result->values = initList();
	result->labels = initList();
	if (checklog->fields){
		char delims[] = " ";
		char *varname = NULL;
		char *flds = strdup(checklog->fields);
		varname = strtok( flds, delims );
		while( varname != NULL ) 
		{
			char tmp[65];
			sprintf( tmp, "LT_%s", varname );
			addToList(result->labels, tmp);
			varname = strtok( NULL, delims );
		}
	}

	strcpy(result->pattern, checklog->pattern);
	result->string = NULL;	
	return result;
}

void *freeList(list_st *list)
{
	element_st *d = (element_st *)list->first;
	while(d){
		element_st * e = d;
		d = (element_st *)d->next;
		free(e->value);
		free(e);
	}
	free(list);
	return NULL;
}

match_t *matchFree(match_t *result)
{
	if (result){
		result->values = freeList(result->values);
		result->labels = freeList(result->labels);
		result->find = 0;
		if (result->string!=NULL){
			free(result->string);
			result->string = NULL;
		}
		if (result->pattern!=NULL){
			free(result->pattern);
			result->pattern = NULL;
		}
		free(result);
		result = NULL;
	}
	return result;
}

void showMatch(match_t *result)
{
	if (result->string)
		printf("\033[1m%24s: %s\033[0m\n", "string", result->string);
	element_st *labels = (element_st *)result->labels->first;
	element_st *values = (element_st *)result->values->first;
	while (labels && values){
		printf("\033[1m%24s: \033[32m%s\033[0m\n",  labels->value, values->value);
		values = (element_st *)values->next;
		labels = (element_st *)labels->next;
	}
}

match_t *match(const char *buf, uci_logcheck *checklog)
{
	int init = 1;
	if (DEBUG>4)
		printf("\t%s\n",checklog->pattern);
	match_t *results = initMatch(checklog);
	char *fmt = checklog->pattern;
	while (*fmt && *buf) {
		switch (*fmt)
		{
			case '%':
				init = 0;
				if (*(++fmt) == '%'){
					if (*buf != '%')
						return results;
					buf++;
				} else {
					int ignore = 0;
					int length = -1;
					long int value = 0;
					const char *start;

					if (*fmt == '*')
						ignore = 1, fmt++;

					if (isdigit(*fmt)) {
						length = atoi(fmt);
						do {
							fmt++;
						} while (isdigit(*fmt));
					}

					/* skip white spaces like scanf does */
					if (strchr("difuoxX", *fmt))
						while (isspace(*buf))
							buf++;

					/* FIXME: we should check afterward:
					* if (start == buf || start == '-' && buf-start == 1)
					*      die("WTF???  zero-length number???");
					*/
					start = buf;

					switch (*fmt) {
						/* if it is signed int or float,
						* we can have minus in front */
						case 'd':
						case 'i':
						case 'f':
							if (*buf == '-' && length)
							buf++, length--;
						case 'u':
							while (isdigit(*buf) && length)
								buf++, length--;

							/* integer value ends here */
							if (*fmt == 'f' && *buf == '.' && length) {
								buf++, length--;
								while (isdigit(*buf) && length)
									buf++, length--;
							}

							/* ignore if value not found */
							if((start == buf) || ((atoi(start) == '-') && (buf-start == 1)))
								break;

							if (!ignore){
								addToList(results->values, strndup(start, buf-start));
							}
							break;

						case 'o':
							while (isoctdigit(*buf) && length) {
								value <<= 3;
								value += *buf - '0';
								buf++, length--;
							}

							/* ignore if value not found */
							if(start == buf)
								break;

							if (!ignore){
								addToList(results->values, valuedup(value));
							}
							break;

						case 'x':
						case 'X':
							while (isxdigit(*buf) && length) {
								value <<= 4;
								if (isdigit(*buf))
									value += *buf - '0';
								else if (islower(*buf))
										value += *buf - 'a' + 10;
									else
										value += *buf - 'A' + 10;

								buf++, length--;
							}

							/* ignore if value not found */
							if(start == buf)
								break;

							if (!ignore){
								addToList(results->values, valuedup(value));
							}
							break;

						case 's':
							while (!isspace(*buf) && length && *buf != *(fmt + 1)) {
								buf++, length--;
							}
 
							if (!ignore){
								addToList(results->values, strndup(start, buf-start));
							}
							break;

						case 'b':
							while (buf && *buf != *(fmt + 1)) {
								buf++, length--;
							}
 
							if (!ignore){
								addToList(results->values, strndup(start, buf-start));
							}
							break;

						case 'c':
							if (length < 0)
								length = 1;        // default length is 1

							while (*buf && length > 0) {
								buf++, length--;
							}
							if (length > 0)
								return results;
							if (!ignore){
								addToList(results->values, strndup(start, buf-start));
							}
							break;
						default: /* should never happen! */
//							send_log(LOG_DEBUG,"Error: unrecognized pattern type: `%%%c'\n", *fmt);
							exit(1); // FIXME
					}
					if (buf-start <= 0)
						return results;
				}
				fmt++;
				break;
/*
			case ' ':
			case '\t':
			case '\n':
			case '\r':
			case '\f':
			case '\v':
				// don't match if not at least one space 
				if(!isspace(*buf))
					return 0;
				else
					buf++;

				// if next char in the form isn't a "space" pattern harvest remaining spaces 
				switch(*(fmt+1))
				{
					case ' ':
					case '\t':
					case '\n':
					case '\r':
					case '\f':
					case '\v':
						break;
					default:
						while (isspace(*buf))
							buf++;
				}
				fmt++;
				break;
*/
			default:
				if (init){
					while (*buf != *fmt && *buf && *fmt)
						buf++;
				}
		}
		if (*buf != *fmt) break;
		fmt++; buf++;
	}
	matchString(results);
	return results;
}
