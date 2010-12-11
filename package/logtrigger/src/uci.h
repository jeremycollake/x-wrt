#ifndef _LOGTRIGGER_UCI_H
#define _LOGTRIGGER_UCI_H
#include <uci.h>

#include "confreg.h"

void read_conf_uci(const char *name);
void do_logcheck(struct uci_section *s);
void do_logfiles(struct uci_section *s);
void parse_sections(struct uci_package *p);

#endif