#ifndef _LOGTRIGGER_TIGGEE_H
#define _LOGTRIGGER_TIGGER_H
char *matchre(const char *string, const char *pattern);
int stringtimes(const char *string, const char *pattern);
int read_syslog(void);
void logtrigger_main(void);
char *readlines(const char *filename, long *last);

#endif
