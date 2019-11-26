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
	./cply saida0.out < teste0.txt > log0.out
	./cply saida1.out < teste1.txt > log1.out
	./cply saida2.out < teste2.txt > log2.out
	./cply saida3.out < teste3.txt > log3.out
	./cply saida4.out < teste4.txt > log4.out
