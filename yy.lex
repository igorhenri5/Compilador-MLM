%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

%}

delim \t|\n
letter [A–Z]|[a–z]
digit [0–9]
identifier [letter]|[letter|digit]+

unsigned_integer	{ digit } +
sign							E [ + \-]?
scale_factor			"E" sign unsigned_integer
unsined_real			unsigned_integer ( \. unsigned_integer ) ? (sign { digit } +)?
integer_constant	unsigned_integer
real_constant			unsined_real
ascii							letter | digit | delim
char_constant			"'"ascii"'"

%%
  
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

{integer_constant} 	{ yylval.int_t = atou(yytext); return INTEGER_CONSTANT; }
{real_constant} 		{ yylval.float_t = atof(yytext); return REAL_CONSTANT; }
{char_constant} 		{ yylval.char_t = yytext; return CHAR_CONSTANT; }
"false"							{ yylval.bool_t = false; return BOOLEAN_CONSTANT; }
"true"							{ yylval.bool_t = true; return BOOLEAN_CONSTANT; }  

{identifier} { yyval.string_t = yytext; return T_IDENTIFIER; }

":"		{ return T_DOISP; }
";"		{ return T_PVIRG; }
","		{ return T_VIRG; }
":="	{ return T_IGUAL; }
"("		{ return T_ABRE; }
")"		{ return T_FECHA; }

"=" 	{ yyval.string_t = "="; return RELOP; }
"<" 	{ yyval.string_t = "<"; return RELOP; }
"<=" 	{ yyval.string_t = "<="; return RELOP; }
">" 	{ yyval.string_t = ">"; return RELOP; }
">=" 	{ yyval.string_t = ">="; return RELOP; }
"!=" 	{ yyval.string_t = "!="; return RELOP; }
"NOT"	{ yyval.string_t = "NOT"; return NOT; }

"+"		{ yyval = "*"; return ADDOP; }
"or"  { yyval = "*"; return ADDOP; }
"-"		{ return MENOS; }

"*"		{ yyval = "*"; return MULOP; }
"/" 	{ yyval = "/"; return MULOP; }
"div"	{ yyval = "div"; return MULOP; }
"mod"	{ yyval = "mod"; return MULOP; }
"and"	{ yyval = "and"; return MULOP; }
  
%%