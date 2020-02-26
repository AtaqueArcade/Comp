comp: comp_main.c comp.tab.c lex.yy.c comp.tab.h listaSimbolos.c listaCodigo.c
	gcc -g lex.yy.c comp_main.c comp.tab.c listaSimbolos.c listaCodigo.c -lfl -o comp
comp.tab.c comp.tab.h: comp.y
	bison -d comp.y
lex.yy.c: comp.l
	flex comp.l
limpia:
	rm lex.yy.c comp.tab.c comp.tab.h comp
run: 
	./comp p
