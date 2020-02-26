%{
#include "listaCodigo.h"
#include "comp.tab.h"
#include <string.h>
#include <stdio.h>
void error();
int FALLO=0;
%}
digito [0-9]
caracter  [a-zA-Z_]
%option yylineno
%x comentario

%%
[ \t\n]+				  ;
{digito}+				{yylval.cadena=strdup(yytext);if (atol(yytext)>2147483648) {printf("Error: Numero demasiado largo en linea %d\n", yylineno);FALLO = 1;} return NUM;}
\"([^"\n])*\"			{yylval.cadena=strdup(yytext);return STRING;}
"funcion"				return FUNCION;
"variables"				return VARIABLES;
"constantes"			return CONSTANTES;
"si"					return SI;
"entonces"				return ENTONCES;
"sino"					return SINO;
"mientras"				return MIENTRAS;
"hacer"					return HACER;
"imprimir"				return IMPRIMIR;
"leer"					return LEER;
"comienzo"				return COMIENZO;
"fin"					return FIN;

{caracter}({caracter}|{digito})* 	{yylval.cadena=strdup(yytext);if (strlen(yytext)>16) {printf("Error: variable demasiado larga en linea %d\n", yylineno);FALLO = 1;} return ID;}

"+"					return MAS;
"-"					return MENOS;
"*"					return POR;
"/"					return DIV;
"("					return PARI;
")"					return PARD;
"="					return IGUAL;
"."					return PUNTO;
"%"					return MOD;
","					return COMA;
"/*"					BEGIN (comentario);
<comentario>[*]+"/"			BEGIN (INITIAL);
<comentario>([^*]|[*]+[^*/])*		;
[^a-zA-Z0-9_"(),.+\-=/*\n]+ 					{error();}
%%

void error(){
	printf("Error en el carácter %s\n",yytext);
	FALLO = 1;
}
