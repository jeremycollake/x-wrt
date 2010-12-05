#include <stdio.h> 
#include <string.h> 
#include <malloc.h> 

typedef struct {
	char *name;
	long lasteof;
	struct file_st *next;
	struct file_st *prev;
} file_st;

typedef struct {
	struct file_st *first;
	struct file_st *last;
	int count;
} filelist_st;


char *strndup(const char *s, size_t n);
filelist_st *newFileList();
void addFile(filelist_st *list, const char *filename);
void *freeFileList(filelist_st *list);
char *readfile(FILE *fp);
char *readlines(const char *filename, long *last);
long getsize(const char *filename);

char *strndup(const char *s, size_t n)
{
	char *d;
	size_t i;
 
	if (!n)
		return NULL;

	d = malloc(n + 1);
	for (i = 0; i < n; i++)
		d[i] = s[i];
	d[i] = '\0';
	return d;
}

filelist_st *newFileList(){
	filelist_st *list = (filelist_st *) malloc( sizeof(filelist_st));
	list->first = NULL;
	list->last = NULL;
	list->count = 0;
	return list;
}

void addFile(filelist_st *list, const char *filename)
{
	file_st *d;
	file_st *p;

	int lname = strlen(filename);
	d = ( file_st *) malloc(sizeof( file_st ));
	d->name = strndup(filename,lname);
	d->lasteof = getsize(filename);
	d->next = NULL;
	if (list->last){
		p = (file_st *)list->last;
		p->next = (file_st *)d;
		d->prev = (file_st *)p;
	}
	if (list->first == NULL)
		list->first = (file_st *)d;
	list->last = (file_st *)d;
	list->count++;
}

void *freeFileList(filelist_st *list)
{
	file_st *d = (file_st *)list->first;
	while(d){
		file_st * e = d;
		d = (file_st *)d->next;
		free(e->name);
		free(e);
	}
	free(list);
	return NULL;
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
		printf("file not found!\n");
		*last = 0;
	} else {
		fseek(fp, (long) *last, SEEK_SET);
		printf("------------ %s -----------------\n", filename);
		line = readfile(fp);
	}
	*last = (long) ftell(fp);
	fclose(fp);
	return line;
}

long getsize(const char *filename)
{
	long length;
	FILE *fp=fopen(filename,"rb"); 
	if(fp==NULL) { 
		printf("file not found!\n");
		length = -1;
	} else { 
		fseek(fp,0L,SEEK_END); 
		length=ftell(fp); 
	}
	fclose(fp);
	return length;
}	

int main(void) 
{ 
	FILE *fp; 
	int i;
	long length; 
	long lineas;
	filelist_st *files = newFileList();
	addFile(files, "/var/log/asterisk/full");
	addFile(files, "/var/log/asterisk/messages");
	addFile(files, "/var/log/syslog");
	addFile(files, "/var/log/auth.log");

	char *filename = "/var/log/asterisk/full";
	long lastread = getsize(filename);
	long checkfile;
	while(1){
		file_st *file = files->first;
		while(file){
			if ((checkfile = getsize(file->name)) != file->lasteof)
			{
				if (checkfile < file->lasteof ) file->lasteof = 0;
				char *line = readlines(file->name, &file->lasteof);
				printf("%s", line);
			}
			file = file->next;
		}
		sleep(1);
	}

	return 0; 
} 
