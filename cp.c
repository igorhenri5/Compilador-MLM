#include <stdio.h>
#include <stdlib.h>
#include "cp.h"

extern int yylex();
extern int yylineno();
extern char* yytext;

//char *names[] = {NULL}

int main(){
	int ntoken, vtoken;

	ntoken = yylex();
	while(ntoken){
		printf("%d\n",ntoken);
		ntoken = yylex();
/*
		switch(ntoken){
			case PROGRAM 			:
				printf();
				break;
			case INTEGER 			:
				printf();
				break;
			case REAL 				:
				printf();
				break;
			case BOOLEAN 			:
				printf();
				break;
			case CHAR 				:
				printf();
				break;
			case BEGIN_T 			:
				printf();
				break;
			case END 				:
				printf();
				break;
			case IF 				:
				printf();
				break;
			case THEN 				:
				printf();
				break;
			case ELSE 				:
				printf();
				break;
			case DO 				:
				printf();
				break;
			case WHILE 				:
				printf();
				break;
			case UNTIL 				:
				printf();
				break;
			case READ 				:
				printf();
				break;
			case WRITE 				:
				printf();
				break;
			case INTEGER_CONSTANT	:
				printf();
				break;
			case REAL_CONSTANT 		:
				printf();
				break;
			case CHAR_CONSTANT 		:
				printf();
				break;
			case BOOLEAN_CONSTANT	:
				printf();
				break;
			case IDENTIFIER 		:
				printf();
				break;
			case T_DOISP 			:
				printf();
				break;
			case T_PVIRG 			:
				printf();
				break;
			case T_VIRG 			:
				printf();
				break;
			case T_IGUAL 			:
				printf();
				break;
			case T_ABRE 			:
				printf();
				break;
			case T_FECHA 			:
				printf();
				break;
			case RELOP 				:
				printf();
				break;
			case NOT 				:
				printf();
				break;
			case ADDOP 				:
				printf();
				break;
			case MENOS 				:
				printf();
				break;
			case MULOP 				:
				printf();
				break;
		}
*/
	}
	return 0;
}