%{
#include <string>
#include "y.tab.h"
%}

delim 		[ \t\n]
stoken 		{delim}+
letter 		[A-Za-z]
digit 		[0-9]
identifier 	{letter}({letter}|{digit})*

unsigned_integer        {digit}+
sign                    [+\-]?
scale_factor            "E"{sign}{unsigned_integer}
unsigned_real           {unsigned_integer}(\.{unsigned_integer})?({scale_factor})?
integer_constant        {unsigned_integer}
real_constant           {unsigned_real}
ascii                   {letter}|{digit}|{delim}
char_constant           "'"{ascii}"'"

%%

"program"       { return PROGRAM; }
"integer"       { return INTEGER; }
"real"          { return REAL; 	  }
"boolean"       { return BOOLEAN; }
"char"          { return CHAR;    }
"begin"         { return BEGIN_T; }
"end"           { return END;     }
"if"            { return IF;      }
"then"          { return THEN;    }
"else"          { return ELSE;    }
"do"            { return DO;      }
"while"         { return WHILE;   }
"until"         { return UNTIL;   }
"read"          { return READ;    }
"write"         { return WRITE;   }

{integer_constant}  { yylval.int_t 		= atoi(yytext); return INTEGER_CONSTANT; }
{real_constant}     { yylval.double_t	= atof(yytext); return REAL_CONSTANT;    }
{char_constant}     { yylval.char_t 	= yytext[0]; 	return CHAR_CONSTANT;    }
"false"             { yylval.bool_t 	= 0; 	  		return BOOLEAN_CONSTANT; }
"true"              { yylval.bool_t 	= 1; 	  		return BOOLEAN_CONSTANT; }

":"     { return T_DOISP; }
";"     { return T_PVIRG; }
","     { return T_VIRG;  }
":="    { return T_IGUAL; }
"("     { return T_ABRE;  }
")"     { return T_FECHA; }

"=" 	{ yylval.string_t = "=";  return RELOP; }
"<" 	{ yylval.string_t = "<";  return RELOP; }
"<=" 	{ yylval.string_t = "<="; return RELOP; }
">" 	{ yylval.string_t = ">";  return RELOP; }
">=" 	{ yylval.string_t = ">="; return RELOP; }
"!=" 	{ yylval.string_t = "!="; return RELOP; }

"NOT"   { yylval.string_t = "NOT"; return NOT;  }

"+"     {  yylval.string_t = "+";  return ADDOP; }
"or"    {  yylval.string_t = "or"; return ADDOP; }

"-"     { return MENOS; }

"*"		{ yylval.string_t = "*"; return MULOP; }
"/" 	{ yylval.string_t = "/"; return MULOP; }
"div"	{ yylval.string_t = "div"; return MULOP; }
"mod"	{ yylval.string_t = "mod"; return MULOP; }
"and"	{ yylval.string_t = "and"; return MULOP; }

{identifier} { yylval.string_t = strdup(yytext);  return IDENTIFIER; }

{stoken}     { ;}
.       	 { ;}

%%

int yywrap(void){
    return 1;    
}
