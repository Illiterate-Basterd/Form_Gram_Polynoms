#include <stdio.h>

extern FILE* yyin;
extern int yyparse();

int main(int argc, char *argv[])
{
   	if( argc != 2 )
    	{
        	fprintf(stderr, "Ошибка: Не задан входной файл");
        	return -1;
   	}
    	int	res;
    	FILE* file;
    	if( (file = fopen(argv[1], "r")) == NULL )
    	{
    	    fprintf(stderr, "Ошибка: Не удалось открыть входной файл `%s'",
    	            argv[1]);
    	    return -1;
    	}
    	yyin = file;
    	res = yyparse();
    	fclose(file);
	return res;
}