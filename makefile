#all:
#	clear
#	lex cp.lex
#	gcc cp.c lex.yy.c -o cp
#	./cp < teste2.txt
#
#build:
#	lex cp.lex
#	gcc cp.c lex.yy.c -o cp
#
#run:
#	./cp < teste2.txt
#
#l:
#	lex cp.lex
#
#c:
#	gcc cp.c lex.yy.c -o cp
#
#ry:
#	./cply < teste4.txt

y:
	yacc -d cp.y
	lex cp.lex
	#gcc lex.yy.c y.tab.c -o cply
	g++ lex.yy.c y.tab.c -o cply
	./cply saida.out < teste4.txt
