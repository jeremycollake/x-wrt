/*
 * trigger - Trigger script for syslog message
 *
 * Copyright (C) 2010 Fabian Omar Franzotti <fofware@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 2.1
 * as published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */
 /*
  * Special Thanks to Jo-Philipp Wich 
  */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <malloc.h>
#include <time.h>
#include <regex.h>
#include <syslog.h>
#include <unistd.h>

#include "config.h"
#include "scan.h"
#include "pairs.h"
#include "util.h"
#include "confreg.h"
#include "trigger.h"
#ifdef OPENWRT
	#include "logread.h"
	#include "uci.h"
#else
	#include "config.h"
#endif


extern int DEBUG;
uci_list *listlogcheck;
filelist_st *files;

char *matchre(const char *strdata, const char *pattern) 
{
    regex_t    preg;                                                            
    int        rc;                                                              
    size_t     nmatch = 10;                                                      
    regmatch_t pmatch[10];                                                       
	char *ret_val = NULL;
	
	if (strlen(strdata) == 0 || strlen(pattern) == 0)
		return NULL;

    if ((rc = regcomp(&preg, pattern, REG_EXTENDED)) != 0) {                    
//       printf("regcomp() failed, returning nonzero (%d)\n", rc);                
       return NULL;                                                                 
    }                                                                           
                                                                                
	if ((rc = regexec(&preg, strdata, nmatch, pmatch, 0)) != 0) {                
//		printf("failed to ERE match \nstring :'%s' \nwith pattern: '%s'\nreturning %d.\n",             
//		string, pattern, rc);                                                    
		regfree(&preg);
		return NULL;
	}
	int len = (pmatch[0].rm_eo-pmatch[0].rm_so);
	ret_val = malloc(len+1);
	memset(ret_val,0,len+1);
	strncpy(ret_val,strdata +pmatch[0].rm_so,len);
	regfree(&preg);
	return ret_val;
}

int stringtimes(const char *string, const char *pattern)
{
	size_t str_pos;
	size_t str_len;

	size_t pat_pos;
	size_t pat_len;
	
	int count;
	
	pat_pos = 0;
	count = 0;
	str_len = strlen(string);
	pat_len = strlen(pattern);
	for (str_pos=0; str_pos<str_len; str_pos++){
		if (string[str_pos] == pattern[pat_pos])
		{
			pat_pos++;
			if (pat_pos == pat_len){
				count++;
				pat_pos = 0;
			}
		} else {
			pat_pos = 0;
		}
	}
	return count;
}

int runscript(uci_logcheck *checklog, match_t *matchst, const char *str_ip, const char *str_mac, int fail, const char *message)
{
	pairlist_st *data = (pairlist_st *) newPairList();
	pair_st *params;
	
	if (checklog->name)
		addPair(data, "LT_name", checklog->name);
	if (message)
		addPair(data, "LT_message", message);
	if (checklog->pattern)
		addPair(data, "LT_pattern", checklog->pattern);
	if (matchst->string)
		addPair(data, "LT_string", matchst->string);
	if (fail)
		addPair(data, "LT_count", (char *)valuedup(fail));

	params = (pair_st *)checklog->params->first;
	
	element_st *labels = (element_st *)matchst->labels->first;
	element_st *values = (element_st *)matchst->values->first;
	
	time_t tm1;
	struct tm *ltime;
	time( &tm1 );
	ltime = localtime( &tm1 );
	char mes[4];
	char str_date[16];
	sscanf (message, "%s %d %d:%d:%d", mes, &ltime->tm_mday, &ltime->tm_hour, &ltime->tm_min,&ltime->tm_sec);

	strftime(str_date, sizeof(str_date), "%Y/%m/%d", ltime);
	addPair(data, "LT_date", str_date);

	strftime(str_date, sizeof(str_date), "%H:%M:%S", ltime);
	addPair(data, "LT_time", str_date);
	tm1 = mktime(ltime);
	sprintf(str_date,"%ld", tm1);
	addPair(data, "LT_datetime", str_date); 
	while (labels && values){
		addPair(data, labels->value, values->value);
		values = (element_st *)values->next;
		labels = (element_st *)labels->next;
	}

	while (params){
		addPair(data, params->name, params->value);
		params = (pair_st *)params->next;
	}

	pair_st *tosend = (pair_st *)data->first;
	if(DEBUG)
		printf("\033[0m%24s: \033[33m\033[1m%s\033[0m\n", "Call action script", checklog->script);
	if(DEBUG > 1){
		while(tosend)
		{
			printf("\033[1m%24s: \033[32m%s\033[0m\n", tosend->name, tosend->value);
			tosend = (pair_st *)tosend->next;
		}
		tosend = (pair_st *)data->first;
	}

	int status;
	if ((status = fork()) < 0) {
		printf("\033[0m");
		syslog (LOG_ERR, "logtrigger: fork() returned -1!");
		data = (pairlist_st *)freePairList((pairlist_st *)data);
		return 0;
	}

	if (status > 0) { /* Parent */
		data = (pairlist_st *)freePairList((pairlist_st *)data);
		return 0; 
	}

	int ret;
	while(tosend)
	{
		if ((ret=setenv(tosend->name, tosend->value, 1)) != 0){
			syslog(LOG_ERR, "logtrigger: setenv(%s=%s) did return %d",tosend->name, tosend->value,ret);
			data = (pairlist_st *)freePairList((pairlist_st *)data);
			exit(0);
		}
		tosend = (pair_st *)tosend->next;
	}

	if ( (ret = execl(checklog->script, checklog->script, (char *)0)) != 0 ) {
		syslog (LOG_ERR,"logtrigger: run script (%s) did return %d", checklog->script,ret);
		data = (pairlist_st *)freePairList((pairlist_st *)data);
		exit(0);
	}

	data = (pairlist_st *)freePairList((pairlist_st *)data);
	exit(0);
}


void  processMsg(char *msglog, file_st *file)
{
		char *sep = "\n";
		char *message, *brkt;

		for (message = strtok_r(msglog, sep, &brkt);
			message;
			message = strtok_r(NULL, sep, &brkt))
		{
			if (message == NULL) break;
			if(DEBUG>1)
				printf("\033[1m\nMsg: %s\033[0m\n", message);
			uci_logcheck *checklog = listlogcheck->first;

			while (checklog!=NULL){
				match_t *matchst = match(message, checklog);
				if (DEBUG >= 3)
					showMatch(matchst);
				if (matchst->string) 
				{
					char *retlog;
					if (!strcmp(file->name,"OpenWrtLogSharedMemory"))
						retlog = logread(0);
					else {
						long from = file->lasteof-16000;
						if (from < 0 ) from = 0;
						retlog = readlines(file->name, &from);
						file->lasteof = from;
					}
					int fail = stringtimes(retlog, matchst->string);
					if (DEBUG>4)
						printf("\tcount \033[1;1mfails(%d)\033[0m / max fails(%d)\n", fail, checklog->maxfail);
					if ( fail >= checklog->maxfail){
						char *str_ip = matchre(message,"([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})");
						char *str_mac = matchre(message,"([0-9a-fA-F]{2}[:-]){6}");
						runscript(checklog, matchst, str_ip, str_mac, fail, message);
						if (str_ip)
							free(str_ip);
						if (str_mac)
							free(str_mac);
					}
					if (retlog)
						free(retlog);
					checklog = listlogcheck->last;
				}
				checklog = checklog->next;
				matchst = matchFree(matchst);
			}
		}

}

char *readfile(FILE *fp)
{
	char line[4096];
	long r = 0;
	char *tmp=NULL;
	while (!feof(fp)) {
		r++;
		if (fgets(line,4096,fp)){
			if (tmp==NULL) {
				tmp = malloc(strlen(line)+1 * sizeof(char));
				strcpy(tmp, line);
			} else {
				int len = strlen(tmp);
				len += strlen(line) + 1;
				tmp = realloc(tmp, (len * sizeof(char)));
				tmp = strcat(tmp,line);
			}
		}
	}
	return tmp;
}	

char *readlines(const char *filename, long *last)
{
	FILE *fp=fopen(filename,"rb");
	char *line=NULL;
	if(fp==NULL) { 
		printf("Opening: %s file not found!\n", filename);
		*last = 0;
	} else {
		fseek(fp, (long) *last, SEEK_SET);
		if (DEBUG>5)
		printf("------------ %s -----------------\n", filename);
		line = readfile(fp);
	}
	*last = (long) ftell(fp);
	fclose(fp);
	return line;
}

void logtrigger_main()
{
	listlogcheck = listNew();
	files = newFileList();
	long checkfile;
	file_st *file = NULL;
#ifdef OPENWRT
	addFile(files,"OpenWrtLogSharedMemory",0);
	read_conf_uci("logtrigger");
#else
	read_conf("/etc/logtrigger/logtrigger.conf");
#endif
	int active = files->count;
	while (active>0)
	{
		if (file == NULL) file = files->first;
		while(file && active){
#ifdef OPENWRT
			if (!strcmp(file->name,"OpenWrtLogSharedMemory")){
				checkfile = (long) get_tail();
			} else {
				checkfile = getsize(file->name);
			}
#else
			checkfile = getsize(file->name);
#endif
			if (DEBUG>8)
				printf("(%d)(%ld = %ld) - (%d - %s)\n", active, checkfile, file->lasteof, file->disabled, file->name);
			if (checkfile < 0)
			{
				if (file->disabled < 11) file->disabled++;
				if (file->disabled == 10){
					active--;
					if (DEBUG>4)
						printf("\n\tDisabling readlog for %s\n\n", file->name);
				}
			} else {
				// check if file changed
				if (file->disabled > 9){
					active++;
					if (DEBUG>4)
						printf("\n\tEnabling readlog for %s\n\n", file->name);
				}
				file->disabled = 0;
				
				if (checkfile != file->lasteof){
					// Read new messages
					char *message=NULL;
					if (DEBUG>8)
						printf("\n\n\tLeer log de %s\n\n",file->name);
#ifdef OPENWRT
					if (!strcmp(file->name,"OpenWrtLogSharedMemory")){
						 message = logreadlast((unsigned) file->lasteof, &file->lasteof);
					} else
#endif
						message = readlines(file->name, &file->lasteof);
					if (message){	// process message
						processMsg(message, file);
						free(message);
					}
				}
			}
			file = file->next;
		}
		sleep(1);
	}
	printf("No logfile to check\n");
}
