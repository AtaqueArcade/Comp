%{
#include <stdio.h>
#include <string.h>
#include "listaSimbolos.h"
#include "listaCodigo.h"

extern int FALLO;
Lista l;
Tipo tipoId;
int contacadena = 0;
void yyerror();
void liberaRegistro();
void imprimesimbolos();
char* generaRegistro();
void imprimeCodigo();
char* creaET();
char* creaStr();
char* dosPuntos();
char* barrabaja();
extern int yylineno;
extern int yylex();
int reg[10] = {0,0,0,0,0,0,0,0,0,0};
int etiqueta = 0;
%}

%union{
	char *cadena;
	ListaC codigo;
}

%type <codigo> program declarations asig statement print_item read_list expresion identifier_list statement_list print_list

%token PARI PARD IGUAL FUNCION VARIABLES CONSTANTES SI ENTONCES SINO MIENTRAS HACER IMPRIMIR LEER COMIENZO FIN COMA PUNTO
%token <cadena> ID STRING NUM
%left MAS MENOS
%left POR DIV MOD 
%left UMENOS
%%
program :{l = creaLS();} FUNCION ID COMIENZO declarations statement_list FIN{
			if (FALLO == 0){
			imprimesimbolos();
			printf(".text\n.globl main\nmain:\n");
			imprimeCodigo($5);
			imprimeCodigo($6);
			printf("li $v0,10\nsyscall\n");
			liberaLS(l);
			liberaLC($5);liberaLC($6);
			}
			else printf("Codigo con errores. Compilación detenida.\n");
			};
declarations : {$$ = creaLC();}
	     | declarations VARIABLES {tipoId=VARIABLE;} identifier_list PUNTO{$$ = creaLC();concatenaLC($$,$1);concatenaLC($$,$4);}
	     | declarations CONSTANTES {tipoId=CONSTANTE;} identifier_list PUNTO{$$ = creaLC();concatenaLC($$,$1);concatenaLC($$,$4);};
identifier_list : asig {$$ = $1;}
	   | identifier_list COMA asig{$$ = creaLC(); concatenaLC($$,$1);concatenaLC($$,$3);liberaLC($1);liberaLC($3);};
asig : ID {  PosicionLista p = buscaLS(l,$1);
  		if (p != finalLS(l)){ printf("Error: Redeclaración de identificador %s en linea %d\n", $1, yylineno);FALLO = 1;}
		else {  Simbolo aux;
  		strncpy(aux.nombre,$1,16);
 		 aux.tipo = tipoId;
  		aux.valor = 0; 
  		insertaLS(l,finalLS(l),aux);}

		$$ = creaLC();
		}
	   | ID IGUAL expresion {PosicionLista p = buscaLS(l,$1);
 		if (p != finalLS(l)){ printf("Error: Redeclaración de identificador %s en linea %d\n", $1, yylineno);FALLO = 1;}
		else {  Simbolo aux;
  		strncpy(aux.nombre,$1,16);
  		aux.tipo = tipoId;
  		aux.valor = 0;
  		insertaLS(l,finalLS(l),aux);} 
		
		$$ = creaLC();
		concatenaLC($$,$3);
		liberaLC($3);
		Operacion SAVEWORLD;
		SAVEWORLD.op="sw";
		SAVEWORLD.res=recuperaResLC($3);
		SAVEWORLD.arg1= barrabaja($1);
		SAVEWORLD.arg2=NULL;
		insertaLC($$,finalLC($$),SAVEWORLD);
		liberaRegistro(SAVEWORLD.res);
		};
statement_list : {$$ = creaLC();}
	   | statement_list statement {$$ = creaLC();
		concatenaLC($$,$1);
		concatenaLC($$,$2);
		liberaLC($1);
		liberaLC($2);}
		;
statement : ID IGUAL expresion PUNTO {PosicionLista p = buscaLS(l,$1);
			if (p == finalLS(l)){ printf("Error: Identificador %s no declarado en linea %d\n", $1, yylineno);FALLO = 1;}
			else{Simbolo aux = recuperaLS(l,p); 
			if (aux.tipo == CONSTANTE) {printf("Error: Identificador %s debe ser variable en linea %d\n", $1, yylineno);FALLO = 1;}}

		$$ = creaLC();
		concatenaLC($$,$3);
		liberaLC($3);
		Operacion SAVEWORLD;
		SAVEWORLD.op="sw";
		SAVEWORLD.res=recuperaResLC($3);
		SAVEWORLD.arg1= barrabaja($1);
		SAVEWORLD.arg2=NULL;
		insertaLC($$,finalLC($$),SAVEWORLD);
		liberaRegistro(SAVEWORLD.res);
			}
	  | COMIENZO statement_list FIN {$$ = $2;}
	  | SI expresion ENTONCES statement SINO statement{		
		char* et1 = creaET(); char* et2 = creaET();

		$$=creaLC();
		concatenaLC($$,$2);
		liberaLC($2);
		Operacion STATEMENTUNO;
		STATEMENTUNO.op="beqz";
		STATEMENTUNO.res=recuperaResLC($2);
		STATEMENTUNO.arg1=et1;
		STATEMENTUNO.arg2=NULL;
		insertaLC($$,finalLC($$), STATEMENTUNO);

		concatenaLC($$,$4);
		liberaLC($4);
		Operacion STATEMENTDOS;
		STATEMENTDOS.op="b";
		STATEMENTDOS.res=et2;
		STATEMENTDOS.arg1=NULL;
		STATEMENTDOS.arg2=NULL;
		insertaLC($$,finalLC($$), STATEMENTDOS);
		
		Operacion STATEMENTRES;
		STATEMENTRES.op=dosPuntos(et1);
		STATEMENTRES.res=NULL;
		STATEMENTRES.arg1=NULL;
		STATEMENTRES.arg2=NULL;
		insertaLC($$,finalLC($$), STATEMENTRES);
		
		concatenaLC($$,$6);
		liberaLC($6);
		Operacion STATEMENTCUATRO;
		STATEMENTCUATRO.op=dosPuntos(et2);
		STATEMENTCUATRO.res=NULL;
		STATEMENTCUATRO.arg1=NULL;
		STATEMENTCUATRO.arg2=NULL;
		insertaLC($$,finalLC($$), STATEMENTCUATRO);
		liberaRegistro(STATEMENTUNO.res);
		}
	  | SI expresion ENTONCES statement {
		char* et1 = creaET(); $$=creaLC();
		concatenaLC($$,$2);
		liberaLC($2);
		Operacion SIUNO;
		SIUNO.op="beqz";
		SIUNO.res=recuperaResLC($2);
		SIUNO.arg1=et1;
		SIUNO.arg2=NULL;
		insertaLC($$,finalLC($$), SIUNO);

		concatenaLC($$,$4);
		Operacion SITRES;
		SITRES.op=dosPuntos(et1);
		SITRES.res=NULL;
		SITRES.arg1=NULL;
		SITRES.arg2=NULL;
		insertaLC($$,finalLC($$), SITRES);
		liberaRegistro(SIUNO.res);
		}
	  | MIENTRAS expresion HACER statement {
	char* et1 = creaET(); char* et2 = creaET();
		$$=creaLC();
		Operacion WHILEUNO;
		WHILEUNO.op=dosPuntos(et1);
		WHILEUNO.res=NULL;
		WHILEUNO.arg1=NULL;
		WHILEUNO.arg2=NULL;
		insertaLC($$,finalLC($$), WHILEUNO);

		concatenaLC($$,$2);
		liberaLC($2);

		Operacion WHILEDOS;
		WHILEDOS.op="beqz";
		WHILEDOS.res=recuperaResLC($2);
		WHILEDOS.arg1=et2;
		WHILEDOS.arg2=NULL;
		insertaLC($$,finalLC($$), WHILEDOS);
		concatenaLC($$,$4);
		liberaLC($4);

		Operacion WHILETRES;
		WHILETRES.op="b";
		WHILETRES.res=et1;
		WHILETRES.arg1=NULL;
		WHILETRES.arg2=NULL;
		insertaLC($$,finalLC($$), WHILETRES);

		Operacion WHILEOTRO;
		WHILEOTRO.op=dosPuntos(et2);
		WHILEOTRO.res=NULL;
		WHILEOTRO.arg1=NULL;
		WHILEOTRO.arg2=NULL;
		insertaLC($$,finalLC($$), WHILEOTRO);
		liberaRegistro(WHILEDOS.res);
		}			
	  | IMPRIMIR print_list PUNTO {$$ = $2;
		}
	  | LEER read_list PUNTO {$$ = $2;
		};
print_list : print_item{$$ = $1;}
	   | print_list COMA print_item{
			$$ = creaLC();
			concatenaLC($$,$1);
			concatenaLC($$,$3);
			liberaLC($1);
			liberaLC($3);
		};
print_item : expresion{
			$$ = $1;
			Operacion EX;
			EX.op ="li";
			EX.res = "$v0";
			EX.arg1 = "1";
			EX.arg2 = NULL;			
			insertaLC($$,finalLC($$), EX);
			
			Operacion SYSEX;
			SYSEX.op = "move";
  			SYSEX.res = "$a0";
  			SYSEX.arg1 = recuperaResLC($1);
  			SYSEX.arg2 = NULL;
			insertaLC($$,finalLC($$), SYSEX);

			Operacion PASAEX;
			PASAEX.op = "syscall";
			PASAEX.res = NULL;
			PASAEX.arg1 = NULL;
			PASAEX.arg2 = NULL;
			insertaLC($$,finalLC($$), PASAEX);
			liberaRegistro(recuperaResLC($1));
				}
	   | STRING {Simbolo aux;
 		aux.cadena = $1;
  		aux.tipo = CADENA;
 		aux.valor = contacadena++;
  		insertaLS(l,finalLS(l),aux); 

		$$ = creaLC();
		Operacion METEPIUNO;
		METEPIUNO.op = "li";
		METEPIUNO.res = "$v0";
		METEPIUNO.arg1 = "4";
		METEPIUNO.arg2 = NULL;			
		insertaLC($$,finalLC($$), METEPIUNO);
		
		Operacion METEPIDOS;
		METEPIDOS.op = "la";
		METEPIDOS.res = "$a0";
		METEPIDOS.arg1 = creaStr(contacadena);
		METEPIDOS.arg2 = NULL;
		insertaLC($$,finalLC($$), METEPIDOS);

		Operacion SYSPI;
		SYSPI.op = "syscall";
		SYSPI.res = NULL;
		SYSPI.arg1 = NULL;
		SYSPI.arg2 = NULL;
		insertaLC($$,finalLC($$), SYSPI);
		};
read_list : ID {PosicionLista p = buscaLS(l,$1);
				if (p == finalLS(l)){ printf("Error: Identificador %s no declarado en linea %d\n", $1, yylineno);FALLO = 1;}
				else{Simbolo aux = recuperaLS(l,p);
				if (aux.tipo == CONSTANTE) {printf("Error: Identificador %s debe ser variable en linea %d\n", $1, yylineno);FALLO = 1;}}

			$$ = creaLC();
			Operacion METEV;
			METEV.op ="li";
			METEV.res = "$v0";
			METEV.arg1 = "5";
			METEV.arg2 = NULL;			
			insertaLC($$,finalLC($$), METEV);
			
			Operacion IDSYSCALL;
			IDSYSCALL.op = "syscall";
  			IDSYSCALL.res = NULL;
  			IDSYSCALL.arg1 = NULL;
  			IDSYSCALL.arg2 = NULL;
			insertaLC($$,finalLC($$), IDSYSCALL);

			Operacion IDPASASYS;
			IDPASASYS.op = "sw";
			IDPASASYS.res = "$v0";
			IDPASASYS.arg1 = barrabaja($1);
			IDPASASYS.arg2 = NULL;
			insertaLC($$,finalLC($$), IDPASASYS);
				}
		  | read_list COMA ID { PosicionLista p = buscaLS(l,$3);
			if (p == finalLS(l)){ printf("Error: Identificador %s no declarado en linea %d\n", $3, yylineno);FALLO = 1;}
			else{Simbolo aux = recuperaLS(l,p);
			if (aux.tipo == CONSTANTE) {printf("Error: Identificador %s debe ser variable en linea %d\n", $3, yylineno);FALLO = 1;}}

			$$ = creaLC();
			concatenaLC($$, $1);
			liberaLC($1);

			Operacion METEV;
			METEV.op ="li";
			METEV.res = "$v0"; 
			METEV.arg1 = "5";
			METEV.arg2 = NULL;			
			insertaLC($$,finalLC($$), METEV);
			
			Operacion IDSYSCALL;
			IDSYSCALL.op = "syscall";
  			IDSYSCALL.res = NULL;
  			IDSYSCALL.arg1 = NULL;
  			IDSYSCALL.arg2 = NULL;
			insertaLC($$,finalLC($$), IDSYSCALL);

			Operacion IDPASASYS;
			IDPASASYS.op = "sw";
			IDPASASYS.res = "$v0";
			IDPASASYS.arg1 = barrabaja($3);
			IDPASASYS.arg2 = NULL;
			insertaLC($$,finalLC($$), IDPASASYS);
		};
expresion : expresion MAS expresion {
			$$ = creaLC();

			Operacion MAS;
			concatenaLC($$, $1);
			concatenaLC($$, $3);
			MAS.op = "add";
			MAS.res = generaRegistro();
			MAS.arg1 = recuperaResLC($1);
			MAS.arg2 = recuperaResLC($3);
			insertaLC($$,finalLC($$), MAS);
			guardaResLC($$,MAS.res);
			liberaRegistro(recuperaResLC($1));
			liberaRegistro(recuperaResLC($3));
			liberaLC($1);
			liberaLC($3);
			}
          | expresion MENOS expresion {
			$$ = creaLC();

			Operacion MENOS;
			concatenaLC($$, $1);
			concatenaLC($$, $3);
			MENOS.op = "sub";
			MENOS.res = generaRegistro();
			MENOS.arg1 = recuperaResLC($1);
			MENOS.arg2 = recuperaResLC($3);
			insertaLC($$,finalLC($$), MENOS);
			guardaResLC($$,MENOS.res);
			liberaRegistro(recuperaResLC($1));
			liberaRegistro(recuperaResLC($3));
			liberaLC($1);
			liberaLC($3);
			}
          | expresion POR expresion {
			$$ = creaLC();

			Operacion POR;
			concatenaLC($$, $1);
			concatenaLC($$, $3);
			POR.op = "mul";
			POR.res = generaRegistro();
			POR.arg1 = recuperaResLC($1);
			POR.arg2 = recuperaResLC($3);
			insertaLC($$,finalLC($$), POR);
			guardaResLC($$,POR.res);
			liberaRegistro(recuperaResLC($1));
			liberaRegistro(recuperaResLC($3));
			liberaLC($1);
			liberaLC($3);
			}
       	  | expresion DIV expresion {
			$$ = creaLC();

			Operacion DIV;
			concatenaLC($$, $1);
			concatenaLC($$, $3);
			DIV.op = "div";
			DIV.res = generaRegistro();
			DIV.arg1 = recuperaResLC($1);
			DIV.arg2 = recuperaResLC($3);
			insertaLC($$,finalLC($$), DIV);
			guardaResLC($$,DIV.res);
			liberaRegistro(recuperaResLC($1));
			liberaRegistro(recuperaResLC($3));
			liberaLC($1);
			liberaLC($3);
			}
          | PARI expresion PARD {
			$$ = $2;
			}
		  | MENOS expresion %prec UMENOS {

			Operacion MENOS;
			MENOS.op = "neg";
			MENOS.res = generaRegistro();
			MENOS.arg1 = recuperaResLC($2);
			MENOS.arg2 = NULL;
			insertaLC($$, finalLC($$),MENOS);
			liberaRegistro(recuperaResLC($2));
			}
		  | ID{  PosicionLista p = buscaLS(l,$1);
  			if (p == finalLS(l)){ printf("Error: Identificador %s no declarado en linea %d\n", $1, yylineno);FALLO = 1;}

			$$ = creaLC();
			Operacion ID;
			ID.op = "lw";
			ID.res = generaRegistro();
			ID.arg1 = barrabaja($1);
			ID.arg2 = NULL;
			insertaLC($$, finalLC($$),ID);
			guardaResLC($$,ID.res);	
			}
          | NUM {$$ = creaLC();

			Operacion NUM;
			NUM.op = "li";
			NUM.res = generaRegistro();
			NUM.arg1 = $1;
			NUM.arg2 = NULL;
			insertaLC($$,finalLC($$), NUM);
			guardaResLC($$,NUM.res);
			};

%%

void yyerror(const char* msg)
{
printf("Se ha producido un error: %s en la linea %d\n",msg, yylineno);
FALLO = 1;
}
void imprimesimbolos() {
 PosicionLista p = inicioLS(l);
  printf(".data\n");
  while (p != finalLS(l)) {
    Simbolo aux = recuperaLS(l,p);
	if (aux.tipo == CADENA) printf("$str%d: .asciiz %s\n", aux.valor+1, aux.cadena);
	else printf("_%s: .word 0\n",aux.nombre);
    p = siguienteLS(l,p);
  }}
char* generaRegistro(){
	int t = 0;
	while (reg[t]==1 && t <10)t++;
	if (t >= 10) {
		printf("ERROR: no hay registros disponibles.\n");
		FALLO = 1;
		return(NULL);
	}
	reg[t] = 1;
	char ch[32];
	sprintf(ch,"$t%d",t);
	return strdup(ch);
}
void liberaRegistro(char* posicion){
	int p = posicion[2]-'0';
	reg[p] = 0;
}
void imprimeCodigo(ListaC codigo1){
  PosicionListaC p = inicioLC(codigo1);
  Operacion oper;
  while (p != finalLC(codigo1)) {
    oper = recuperaLC(codigo1,p);
    printf("%s",oper.op);
    if (oper.res) printf(" %s",oper.res);
    if (oper.arg1) printf(",%s",oper.arg1);
    if (oper.arg2) printf(",%s",oper.arg2);
    printf("\n");
    p = siguienteLC(codigo1,p);
  }
}
char* creaET(){
	char aux[10];
	sprintf(aux,"$etiq%d",etiqueta);
	etiqueta++;
	return (strdup(aux));
}
char* creaStr(int x){
	char aux[10];
	sprintf(aux,"$str%d",x);
	return (strdup(aux));
}
char* dosPuntos(char* etq){
	char aux[10];
	sprintf(aux,"%s:",etq);
	return (strdup(aux));
}
char* barrabaja(char* id){
	char aux[10];
	sprintf(aux,"_%s",id);
	return (strdup(aux));
}
