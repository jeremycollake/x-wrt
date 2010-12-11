#ifndef _LOGTRIGGER_PAIRS_H
#define _LOGTRIGGER_PAIRS_H

typedef struct {
	char *name;
	char *value;
	struct pair_st *next;
	struct pair_st *prev;
} pair_st;

typedef struct {
	struct pair_st *first;
	struct pair_st *last;
	int count;
} pairlist_st;

pairlist_st *newPairList();
void addPair(pairlist_st *list, const char *name, const char *value);
void *freePairList(pairlist_st *list);
#endif