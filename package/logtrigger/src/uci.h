#ifndef _LOGTRIGGER_UCI_H
#define _LOGTRIGGER_UCI_H

#include <uci.h>
#include "pairs.h"

typedef struct st_list {
	struct st_logcheck *first;
	struct st_logcheck *last;
	int count;
} uci_list;

typedef struct st_logcheck {
	bool enable;
	char *name;
	char *pattern;
	char *fields;
	int maxfail;
	char *script;
	pairlist_st *params;
	struct st_logcheck *next;
	struct st_logcheck *prev;

} uci_logcheck;

void hostblock_load_uci(const char *name);
uci_list *listNew();
static void parse_sections(struct uci_package *p);
//static void do_logcheck(struct uci_section *s);
//static void do_blacklist(struct uci_section *s);
//static void do_whitelist(struct uci_section *s);
//static void do_blocked(struct uci_section *s);

uci_list *listlogcheck;

#endif