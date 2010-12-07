#ifndef _LOGTRIGGER_CONFIG_H
#define _LOGTRIGGER_CONFIG_H

#include "confreg.h"
#include "files.h"

typedef struct {
	int ret;
	char *type;
	char *name;
	char *value;
} uci_reg;


uci_reg *newucireg();
void remove_comment(char *str);
void clean_str(char *str);
//void set_vars(char* line);
char *readuci_line(FILE *fp, char* tmp);
void *freeucireg(uci_reg *reg);
int getucinext(FILE *fp, uci_reg *reg);
void read_conf(const char *conffile);

#endif