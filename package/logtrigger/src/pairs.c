#include <malloc.h>
#include <string.h>

#include "util.h"
#include "pairs.h"

extern int DEBUG;

pairlist_st *newPairList(){
	pairlist_st *list = (pairlist_st *) malloc( sizeof(pairlist_st));
	list->first = NULL;
	list->last = NULL;
	list->count = 0;
	return list;
}

void addPair(pairlist_st *list, const char *name, const char *value)
{
	pair_st *d;
	pair_st *p = (pair_st *)list->last;

	int lname = strlen(name);
	int lvalue = strlen(value);
	d = ( pair_st *) malloc(sizeof( pair_st ));
	d->name = strndup(name,lname);
	d->value = strndup(value,lvalue);
	d->next = NULL;
	if (list->last){
//		p = (pair_st *)list->last;
		p->next = (struct pair_st *) d;
		d->prev = (struct pair_st *) p;
	}
	if (list->first == NULL)
		list->first = (struct pair_st *) d;
	list->last = (struct pair_st *) d;
	list->count++;
}

void *freePairList(pairlist_st *list)
{
	pair_st *d = (pair_st *)list->first;
	while(d){
		pair_st * e = d;
		d = (pair_st *)d->next;
		free(e->name);
		free(e->value);
		free(e);
	}
	free(list);
	return NULL;
}

