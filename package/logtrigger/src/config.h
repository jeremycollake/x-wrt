#ifndef _LOGTRIGGER_CONFIG_H
#define _LOGTRIGGER_CONFIG_H
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
	int ret;
	char *type;
	char *name;
	char *value;
} uci_reg;

uci_logcheck *newData();
uci_list *listNew();
uci_logcheck *listAddlogcheck(uci_list* list, int enable, char* name, char* pattern, char* fields, int maxfail, char *script, pairlist_st *params );
void remove_comment(char *str);
void clean_str(char *str);
void set_vars(char* line);
char *readuci_line(FILE *fp, char* tmp);
uci_reg *newucireg();
void *freeucireg(uci_reg *reg);
int getucinext(FILE *fp, uci_reg *reg);
void read_conf(const char *conffile);

extern int errno;
//extern int DEBUG;

uci_list *listlogcheck;
#endif