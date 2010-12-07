#ifndef _LOGTRIGGER_UCI_H
#define _LOGTRIGGER_UCI_H
#include <uci.h>

#include "confreg.h"

void read_conf_uci(const char *name);
static void parse_sections(struct uci_package *p);
static void do_logcheck(struct uci_section *s);
static void do_logfiles(struct uci_section *s);

#endif