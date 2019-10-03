# Makefile

OBJS	= bison.o lex.o main.o

CC	= g++
CFLAGS	= -g

main:		$(OBJS)
		$(CC) $(CFLAGS) $(OBJS) -o a.out

lex.o:		lex.yy.c
		$(CC) $(CFLAGS) -c lex.yy.c -o lex.o

lex:		yy.lex
		flex yy.lex

stx.o:	stx.tab.c
		$(CC) $(CFLAGS) -c stx.tab.c -o bison.o

stx:	stx.y
		bison -d -v stx.y
		#cp stx.tab.c bison.c
		#cmp -s stx.tab.h tok.h || cp stx.tab.h tok.h

# main.o: main.cpp
# 		$(CC) $(CFLAGS) -c main.cpp -o main.o

#lex.o yac.o main.o	: heading.h
#lex.o main.o		: tok.h

clean:
	rm -f *.o *~ lex.c lex.yy.c stx.tab.c stx.tab.h stx.output a.out
