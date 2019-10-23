%{
//#include "cp.h"
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

{integer_constant}  { return INTEGER_CONSTANT; }
{real_constant}     { return REAL_CONSTANT;    }
{char_constant}     { return CHAR_CONSTANT;    }
"false"             { return BOOLEAN_CONSTANT; }
"true"              { return BOOLEAN_CONSTANT; }

":"     { return T_DOISP; }
";"     { return T_PVIRG; }
","     { return T_VIRG;  }
":="    { return T_IGUAL; }
"("     { return T_ABRE;  }
")"     { return T_FECHA; }

"="     { return RELOP; }
"<"     { return RELOP; }
"<="    { return RELOP; }
">"     { return RELOP; }
">="    { return RELOP; }
"!="    { return RELOP; }
"NOT"   { return NOT;   }

"+"     { return ADDOP; }
"or"    { return ADDOP; }
"-"     { return MENOS; }

"*"     {  return MULOP; }
"/"     {  return MULOP; }
"div"   {  return MULOP; }
"mod"   {  return MULOP; }
"and"   {  return MULOP; }

{identifier} { return IDENTIFIER; }

{stoken}       {  		 	 ; }
.       	   {             ; }

%%

int yywrap(void){
    return 1;    
}
