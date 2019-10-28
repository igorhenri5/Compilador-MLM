%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <ctype.h>
  #include <iostream>
  #include <unordered_map>

  using namespace std;

  void yyerror(char *s);
  int yylex();

  std::unordered_map<std::string,std::string> symbolTable;
  //                       Chave       Valor 

  //map.insert (std::make_pair<std::string,double>("eggs",6.0));

  //int symbols[52];
  void updateSymbolVal(char* symbol, char* val);
  void printSymbolTable();

  std::string aux;
%}

%union{ 
  int    int_t;
  int    bool_t;
  double double_t;
  char   char_t;
  char*  string_t;
}

%start program

%token  PROGRAM
%token  INTEGER
%token  REAL
%token  BOOLEAN
%token  CHAR
%token  BEGIN_T
%token  END
%token  IF
%token  THEN
%token  ELSE
%token  DO
%token  WHILE
%token  UNTIL
%token  READ
%token  WRITE

%token  <int_t>     INTEGER_CONSTANT
%token  <bool_t>    BOOLEAN_CONSTANT
%token  <double_t>  REAL_CONSTANT
%token  <string_t>  CHAR_CONSTANT
%token  <string_t>  IDENTIFIER

%token  T_DOISP
%token  T_PVIRG
%token  T_VIRG
%token  T_IGUAL
%token  T_ABRE
%token  T_FECHA

%token  RELOP
%token  NOT
%token  ADDOP
%token  MENOS
%token  MULOP

%left   T_IGUAL MENOS
%right  RELOP ADDOP MULOP

%%
program:      PROGRAM IDENTIFIER T_PVIRG decl_list compound_stmt { /*updateSymbolVal($2," ");*/ printSymbolTable(); };

decl_list:    decl_list decl
              | decl;

decl:         |
              ident_list T_DOISP type T_PVIRG;

ident_list:   ident_list T_VIRG IDENTIFIER {updateSymbolVal($3,"?");}
              | IDENTIFIER                 {updateSymbolVal($1,"?");};

type :        INTEGER     { printf("\nt_INTEGER"); }
              | REAL      { printf("\nt_REAL");    }
              | BOOLEAN   { printf("\nt_BOOLEAN"); }
              | CHAR      { printf("\nt_CHAR");    };

compound_stmt: BEGIN_T stmt_list END;

stmt_list:    stmt_list stmt          {printf("STMTLIST FULL");}
              | stmt                  {printf("STMT");};

stmt:         
              | assign_stmt   T_PVIRG {printf("ASSIGN");}
              | if_stmt
              | loop_stmt     T_PVIRG
              | read_stmt     T_PVIRG
              | write_stmt    T_PVIRG
              | compound_stmt T_PVIRG;

assign_stmt:  IDENTIFIER T_IGUAL expr;

if_stmt:      IF cond THEN stmt               { printf("\n_IF");      }
              | IF cond THEN stmt ELSE stmt   { printf("\n_IF_ELSE"); };

cond:         expr;

loop_stmt:    stmt_prefix DO stmt_list stmt_suffix;

stmt_prefix:  
              | WHILE cond;

stmt_suffix:  UNTIL cond
              | END;

read_stmt:    READ T_ABRE ident_list T_FECHA  { printf("\nREAD");  }

write_stmt:   WRITE T_ABRE expr_list T_FECHA  { printf("\nWRITE"); };

expr_list:    expr
              | expr_list T_VIRG expr;

expr:         simple_expr                     { printf("\n_exp"); }
              | simple_expr RELOP simple_expr;

simple_expr:  term
              | simple_expr ADDOP term;

term:         factor_a
              | term MULOP factor_a;

factor_a:     MENOS factor 
              | factor;

factor:       IDENTIFIER               { printf("\n_IDENTIFIER"); };
              | constant
              | T_ABRE expr T_FECHA
              | NOT factor;

constant:     INTEGER_CONSTANT 
              | REAL_CONSTANT
              | CHAR_CONSTANT
              | BOOLEAN_CONSTANT;

%%

void updateSymbolVal(char* symbol, char* val){
  symbolTable[symbol] = val;
}

void printSymbolTable(){
  cout << "\n\nSymbol Table" << endl; 
  for(auto it = symbolTable.cbegin(); it != symbolTable.cend(); ++it){
      std::cout << it->first << "  -  " << it->second << endl;
  }
}

int main(){
  int i;
  return yyparse();
}

void yyerror(char *s){
  printf("\nERR - %s",s);
}
