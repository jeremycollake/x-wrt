#ifndef _LOGTRIGGER_SCAN_H
#define _LOGTRIGGER_SCAN_H
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "pairs.h"
#include "confreg.h"

typedef struct {
	char *value;
	struct element_st *next;
	struct element_st *prev;
} element_st;

typedef struct {
	struct element_st *first;
	struct element_st *last;
	int count;
} list_st;

typedef struct {
	int find;
	list_st *labels;
	list_st *values;
	char *pattern;
	char *string;
} match_t;

//int scan(const char *buf, const char *fmt, counter_t **counter);
//match_t *match(const char *buf, const char *fmt);
//int scan(const char *buf, const char *fmt, char ** results);
//char *strndup(const char *s, size_t n);
//char *valuedup(const long int value);

int scan_count(const char *fmt);
void matchString(match_t *result);
match_t *initMatch(uci_logcheck *checklog);
match_t *matchFree(match_t *result);
void showMatch(match_t *result);
match_t *match(const char *buf, uci_logcheck *checklog);
#endif