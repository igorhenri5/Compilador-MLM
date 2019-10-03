/*
 *  GERADOR DE ANALISADOR SINTÁTICO
 * */

//declaracoes C
%{
#include<stdio.h>
#include<string>
int yyerror(char *s);
int yylex(void);
%}

//declaracoes
%union{ //specifies the entire collection of possible data types for semantic values
  int		int_t;
  float		float_t;
  char		char_t;
  string	string_t;
}

%token	<int_t>		INTEGER_CONSTANT
%token	<double_t>	REAL_CONSTANT
%token	<string_t>	CHAR_CONSTANT
%token	<int_t>		BOOLEAN_CONSTANT
%token  <string_t>	IDENTIFIER

%token	PROGRAM
%token	INTEGER
%token	REAL
%token	BOOLEAN
%token	CHAR
%token	BEGIN
%token	END
%token	IF
%token	THEN
%token	ELSE
%token	DO
%token	WHILE
%token	UNTIL
%token	READ
%token	WRITE
%token	MENOS
%token	NOT

%token T_DOISP
%token T_PVIRG
%token T_VIRG
%token T_IGUAL
%token T_ABRE
%token T_FECHA

%left	RELOP
%left	ADDOP
%left	MENOS
%left	MULOP
%right	NOT
%right	T_IGUAL

%start	program

%%
//regras de traducao - gramaticas LC
program: 	PROGRAM IDENTIFIER T_PVIRG decl_list compound_stmt;

decl_list: 	decl_list T_PVIRG decl
			| decl;

decl: 		ident_list T_DOISP type;

ident_list: ident_list T_VIRG IDENTIFIER
			| IDENTIFIER;

type : 	INTEGER
        | REAL
        | BOOLEAN
        | CHAR;

compound_stmt: BEGIN stmt_list END;

stmt_list: 	stmt_list T_PVIRG stmt
			| stmt;

stmt: 	assign_stmt
        | if_stmt
        | loop_stmt
        | read_stmt
        | write_stmt
        | compound_stmt;

assign_stmt: IDENTIFIER T_IGUAL expr;

if_stmt: 	IF cond THEN stmt
          	| IF cond THEN stmt ELSE stmt;

cond: expr;

loop_stmt: stmt_prefix DO stmt_list stmt_suffix;

stmt_prefix: 	/*vazio*/
				| WHILE cond;

stmt_suffix: 	UNTIL cond
              	| END;

read_stmt: READ T_ABRE ident_list T_FECHA  { printf("\nREAD: ?"); };

write_stmt: WRITE T_ABRE expr_list T_FECHA  { printf("\nWRITE : ?"); };

expr_list: 	expr
			| expr_list T_VIRG expr;

expr: 		simple_expr
			| simple_expr RELOP simple_expr ;

simple_expr: 	term
				| simple_expr ADDOP term ;

term: 		factor_a
			| term MULOP factor_a ;

factor_a: 	MENOS factor ;
			| factor;

factor: 	IDENTIFIER
            | constant
            | T_ABRE expr T_FECHA
            | NOT factor;

constant: 	INTEGER_CONSTANT
            | REAL_CONSTANT
            | CHAR_CONSTANT
            | BOOLEAN_CONSTANT;


%%

//rotinas C
int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c

  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}
