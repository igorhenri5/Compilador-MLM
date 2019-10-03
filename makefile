# Makefile

#OBJS	= bison.o lex.o main.o

CC	= g++
CFLAGS	= -g -Wall -ansi -pedantic

#calc:		$(OBJS)
#		$(CC) $(CFLAGS) $(OBJS) -o calc -lfl

lex.o:		lex.c
		$(CC) $(CFLAGS) -c lex.c -o lex.o

lex:		yy.lex 
		flex yy.lex
		cp lex.yy.c lex.c

stx.o:	bison.c
		$(CC) $(CFLAGS) -c bison.c -o bison.o

stx:	stx.y
		bison -d -v stx.y
		cp stx.tab.c bison.c
		cmp -s stx.tab.h tok.h || cp stx.tab.h tok.h

#main.o:		main.cc
#		$(CC) $(CFLAGS) -c main.cc -o main.o

#lex.o yac.o main.o	: heading.h
#lex.o main.o		: tok.h

#clean:
#	rm -f *.o *~ lex.c lex.yy.c bison.c tok.h calc.tab.c calc.tab.h calc.output calc
