#include "listaSimbolos.h"
#include <string.h>
#include <stdio.h>

int main(int argc, char **argv) {

  // Creación de la lista
  Lista l = creaLS();

  // Inserción de una constante "a" con valor 0.
  Simbolo aux;
  strncpy(aux.nombre,"a",16);
  aux.tipo = CONSTANTE;
  aux.valor = 0;
  insertaLS(l,finalLS(l),aux);

  // Inserción de una variable "b" con valor 1.
  strncpy(aux.nombre,"b",16);
  aux.tipo = VARIABLE;
  aux.valor = 1;
  insertaLS(l,finalLS(l),aux);
  
  // Búsqueda del símbolo "b"
  PosicionLista p = buscaLS(l,"b");
  if (p != finalLS(l)) {
    Simbolo aux = recuperaLS(l,p);
    printf("Encontrado b, tipo: %s\n",(aux.tipo == VARIABLE ? "variable" : "constante"));

    // Modificación del símbolo "b" con valor 10.
    aux.valor = 10;
    asignaLS(l,p,aux);
  }
  else {
    printf("No encontrado b\n");
  }

  // Búsqueda de un símbolo "c"
  p = buscaLS(l,"c");
  if (p != finalLS(l)) {
    Simbolo aux = recuperaLS(l,p);
    printf("Encontrado c, tipo: %s\n",(aux.tipo == VARIABLE ? "variable" : "constante"));
  }
  else {
    printf("No encontrado c\n");
  }

  // Recorrido de la lista de símbolos
  printf("Imprimiendo lista de %d símbolos\n",longitudLS(l));
  p = inicioLS(l);
  while (p != finalLS(l)) {
    Simbolo aux = recuperaLS(l,p);
    printf("%s %s %d\n",aux.nombre,(aux.tipo == VARIABLE ? "variable" : "constante"),aux.valor);
    p = siguienteLS(l,p);
  }

  // Liberación de memoria de la lista.
  liberaLS(l);
}
