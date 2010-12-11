#ifndef _LOGTRIGGER_FILES_H
#define _LOGTRIGGER_FILES_H

//char *readfile(FILE *fp);
char *readfile(FILE *fp, char *ret);
char *readNewLines(const char *filename, long *last, char *ret);
char *readline(FILE *pf, char *tmp);
long getsize(const char *filename);
#endif