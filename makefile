all:
	clear
	lex cp.lex
	gcc cp.c lex.yy.c -o cp
	./cp < teste2.txt

build:
	lex cp.lex
	gcc cp.c lex.yy.c -o cp

run:
	./cp < teste2.txt

l:
	lex cp.lex

c: 
	gcc cp.c lex.yy.c -o cp

