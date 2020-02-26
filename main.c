#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
extern int yyparse();
extern int yydebug;
FILE *fich;
int main(int argc, char ** argv)
{
	int i;
	if (argc !=2){
		printf("Uso: %s fichero\n", argv[0]);
		exit(1);
	}
	if ((fich=fopen(argv[1],"r"))==NULL) {
		printf("***ERROR,no se puede abrir el fichero\n");
	perror("Error leyendo: ");
		exit(1);
	}
	yyin=fich;
	yydebug = 0;
	yyparse();
	fclose(fich);
	return 0;
}
