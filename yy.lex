%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

//#include "calc.tab.h"

%}

/* definicoes regulares */

//indetificadores
delim [ \t \n ]
stoken { delim } +
letter [A – Z a – z]
digit [0 – 9]
identifier { letter } ({ letter } | { digit })*

//constantes
unsigned_integer	{ digit } +
sign							E [ + \-]?
scale_factor			"E" sign unsigned_integer
unsined_real			unsigned_integer ( \ . unsigned_integer ) ? (sign { digit } +)?
integer_constant	unsigned_integer
real_constant			unsined_real
ascii							letter | digit | delim | ' '
char_constant			'\'' ascii '\'' //SHUD Faltou definir os caracteres asciis

%%
  
//  PALAVRAS RESERVADAS
"program"		{ return PROGRAM; }
"integer"		{ return INTEGER; }
"real"			{ return REAL; }
"boolean"		{ return BOOLEAN; }
"char"			{ return CHAR; }
"begin"			{ return BEGIN; }
"end"				{ return END; }
"if" 				{ return IF; }
"then"			{ return THEN; }
"else"			{ return ELSE; }
"do"				{ return DO; }
"while"			{ return WHILE; }
"until"			{ return UNTIL; }
"read"			{ return READ; }
"write"			{ return WRITE; }
//------------------------


//	CONSTANTES ***** SHRUD a nem
{integer_constant} 	{ yylval.int_t = atou(yytext); return INTEGER_CONSTANT; }
{real_constant} 		{ yylval.float_t = atof(yytext); return REAL_CONSTANT; }
{char_constant} 		{ yylval.char_t = atof(yytext); return CHAR_CONSTANT; }
"false"							{ yylval.bool_t = false; return BOOLEAN_CONSTANT; }
"true"							{ yylval.bool_t = true; return BOOLEAN_CONSTANT; }  
//------------------------

//indetificadores
{identifier} {yyval.string_t = yytext; return IDENTIFIER;}

// 	OPERADORES & CIA 
':'		{ return T_DOISP; }
';'		{ return T_PVIRG; }
','		{ return T_VIRG; }
":="	{ return T_IGUAL; }
'('		{ return T_ABRE; }
')'		{ return T_FECHA; }
//------------------------

//relacoes
'=' 	{ yyval.string_t = "="; return RELOP; }
"<" 	{ yyval.string_t = "<"; return RELOP; }
"<=" 	{ yyval.string_t = "<="; return RELOP; }
">" 	{ yyval.string_t = ">"; return RELOP; }
">=" 	{ yyval.string_t = ">="; return RELOP; }
"!=" 	{ yyval.string_t = "!="; return RELOP; }
// NOT
"NOT"	{ yyval.string_t = "NOT"; return NOT; }
  
//operador de adicao
'+'		{ yyval = '*'; return ADDOP; }
"or"  { yyval = '*'; return ADDOP; }
//benos -
'-'		{ return MENOS; }

//operador de multiplicacao
'*'		{ yyval = '*'; return MULOP; }
'/' 	{ yyval = '/'; return MULOP; }
"div"	{ yyval = "div"; return MULOP; }
"mod"	{ yyval = "mod"; return MULOP; }
"and"	{ yyval = "and"; return MULOP; }
  
%%