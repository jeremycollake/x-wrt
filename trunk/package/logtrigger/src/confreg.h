#ifndef _LOGTRIGGER_CONFREG_H
#define _LOGTRIGGER_CONFREG_H
#include "pairs.h"

typedef struct st_list {
	struct st_logcheck *first;
	struct st_logcheck *last;
	int count;
} uci_list;

typedef struct st_logcheck {
	int enable;
	char *name;
	char *pattern;
	char *fields;
	int maxfail;
	char *script;
	pairlist_st *params;
	struct st_logcheck *next;
	struct st_logcheck *prev;
} uci_logcheck;

typedef struct {
	char *name;
	long lasteof;
	int key;
	int disabled;
	struct file_st *next;
	struct file_st *prev;
} file_st;

typedef struct {
	struct file_st *first;
	struct file_st *last;
	int count;
} filelist_st;



uci_logcheck *newData();
uci_list *listNew();
uci_logcheck *listAddlogcheck(uci_list* list, int enable, char* name, char* pattern, char* fields, int maxfail, char *script, pairlist_st *params );

filelist_st *newFileList();
file_st * addFile(filelist_st *list, const char *filename, int disabled);
void *freeFileList(filelist_st *list);
#endif