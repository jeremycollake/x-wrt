#include <stdio.h> 
#include <string.h> 
#include <malloc.h> 

#include "confreg.h"
#include "util.h"
#include "tail.h"


int DEBUG = 5;
uci_list *listlogcheck;
filelist_st *files;

int main(void)
{
	return logsread();
}