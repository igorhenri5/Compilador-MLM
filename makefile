# Makefile

OBJS	= bison.o lex.o main.o

CC	= gcc
CFLAGS	= -g -Wall -ansi -pedantic

cp:		$(OBJS)
		$(CC) $(CFLAGS) $(OBJS) -o cp -lfl

lex.o:		lex.c
		$(CC) $(CFLAGS) -c lex.c -o lex.o

lex.c:		cp.lex 
		flex cp.lex
		cp lex.yy.c lex.c

bison.o:	bison.c
		$(CC) $(CFLAGS) -c bison.c -o bison.o

bison.c:	cp.y
		bison -d -v cp.y
		cp cp.tab.c bison.c
		cmp -s cp.tab.h tok.h || cp cp.tab.h tok.h

main.o:		main.cc
			$(CC) $(CFLAGS) -o main.o -c main.cc 

lex.o yac.o main.o	: heading.h
lex.o main.o		: tok.h

clean:
	rm -f *.o *~ lex.c lex.yy.c bison.c tok.h cp.tab.c cp.tab.h cp.output cp
