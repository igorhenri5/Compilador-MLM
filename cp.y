%{
  void yyerror(char *s);
  int yylex();
  #include <stdio.h>
  #include <stdlib.h>
  #include <ctype.h>
  int symbols[52];
  int symbolVal(char symbol);
  void updateSymbolVal(char symbol, int val);
%}

%union{ 
  int		int_t;
  float	float_t;
  char	char_t;
  char*	string_t;
}

%start program

%token	<int_t>		  INTEGER_CONSTANT
%token	<double_t>	REAL_CONSTANT
%token	<string_t>	CHAR_CONSTANT
%token	<int_t>		  BOOLEAN_CONSTANT
%token  <string_t>	IDENTIFIER

%token	PROGRAM
%token	INTEGER
%token	REAL
%token	BOOLEAN
%token	CHAR
%token	BEGIN_T
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

%left	  RELOP
%left	  ADDOP
%left	  MENOS
%left	  MULOP
%right	NOT
%right	T_IGUAL

%%
program: 	PROGRAM IDENTIFIER T_PVIRG decl_list compound_stmt { printf("\nPRGM"); };;

decl_list:    decl_list T_PVIRG decl
		          | decl;

decl: 		    ident_list T_DOISP type;

ident_list:   ident_list T_VIRG IDENTIFIER
			        | IDENTIFIER;

type : 	      INTEGER     { printf("\nt_INTEGER"); };
              | REAL      { printf("\nt_REAL"); };
              | BOOLEAN   { printf("\nt_BOOLEAN"); };
              | CHAR      { printf("\nt_CHAR"); };;

compound_stmt: BEGIN_T stmt_list END;

stmt_list:    stmt_list T_PVIRG stmt
			        | stmt;

stmt:       	assign_stmt
              | if_stmt
              | loop_stmt
              | read_stmt
              | write_stmt
              | compound_stmt;

assign_stmt: IDENTIFIER T_IGUAL expr;

if_stmt: 	    IF cond THEN stmt                 { printf("\n_IF"); };
          	  | IF cond THEN stmt ELSE stmt   { printf("\n_IF_ELSE"); };;

cond:         expr;

loop_stmt:    stmt_prefix DO stmt_list stmt_suffix;

stmt_prefix: 	
				      | WHILE cond;

stmt_suffix: 	UNTIL cond
      	      | END;

read_stmt:    READ T_ABRE ident_list T_FECHA  { printf("\nREAD"); };

write_stmt:   WRITE T_ABRE expr_list T_FECHA  { printf("\nWRITE"); };

expr_list: 	  expr
			        | expr_list T_VIRG expr;

expr: 		    simple_expr     { printf("\n_exp"); };
			        | simple_expr RELOP simple_expr ;

simple_expr: 	term
			        | simple_expr ADDOP term ;

term: 		    factor_a
			        | term MULOP factor_a ;

factor_a: 	  MENOS factor ;
			        | factor;

factor: 	    IDENTIFIER               { printf("\n_IDENTIFIER"); };
              | constant
              | T_ABRE expr T_FECHA
              | NOT factor;

constant: 	  INTEGER_CONSTANT 
              | REAL_CONSTANT
              | CHAR_CONSTANT
              | BOOLEAN_CONSTANT;

%%

int computeSymbolIndex(char token){
  int idx = -1;
  if(islower(token)){
    idx = token - 'a' + 26;
  }else if(isupper(token)){
    idx = token - 'A';
  }
  return idx;
}

int symbolVal(char symbol){
  int bucket = computeSymbolIndex(symbol);
  return symbols[bucket];
}

void updateSymbolVal(char symbol, int val){
  int bucket = computeSymbolIndex(symbol);
  symbols[bucket] = val;
}

int main(){
  int i;
  for(i=0; i<52; i++){
    symbols[i]=0;
  }
  return yyparse();
}

void yyerror(char *s){
  printf("ERR - %s",s);
}
