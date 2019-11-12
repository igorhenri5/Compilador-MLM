%{
  #include "SymbolTable.hpp"
  using namespace std;

// int insideFlowControl = 0;

  void yyerror(char *s);
  int yylex();

  void printQuadruplas();

  SymbolTable::SymbolTable table;
  std::vector<Quadrupla*> quadruplas;
  std::vector<FlowControl*> pilhaFlowControl;
  std::vector<std::string> installBuffer;
  std::string type;

  std::string getType(std::string op, std::string e1Type, std::string e2Type){
    std::string type;
    if((e1Type == "REAL" && (e2Type != "BOOLEAN")) || (e2Type == "REAL" && (e1Type != "BOOLEAN"))){
      return "REAL";
    }else if((e1Type == "INTEGER" && e2Type != "BOOLEAN") || (e2Type == "INTEGER" && e1Type != "BOOLEAN") ){
      return "INTEGER";
    }else if(e1Type == "CHAR" && e2Type == "CHAR"){
      return "CHAR";
    }else if(e1Type == "BOOLEAN" && e2Type == "BOOLEAN"){
      return "BOOLEAN";
    }   
    std::cout << "SEMANTIC ERROR - TYPE MISMATCH" << std::endl;
    exit(1);
  }
  
  int serial = 0;
  std::string newtemp(){
    std::string temp;
    temp = "" + std::to_string(serial) + "t";
    serial++;
    return temp;
  }

%}

%code requires {
  
  #include <iostream>
  #include <unordered_map>
  #include <vector>
  #include <string>
  #include "SymbolTable.hpp"

}


%union{ 
  int    int_t;
  int    bool_t;
  double double_t;
  char   char_t;
  char*  string_t;
  Expression* expr_t;
  FlowControl* flow_t;
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

%token  <string_t>  INTEGER_CONSTANT
%token  <string_t>  BOOLEAN_CONSTANT
%token  <string_t>  REAL_CONSTANT
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

%type <expr_t> expr_list cond expr term factor_a factor simple_expr constant
%type <flow_t> if_stmt if_aux
%type <string_t> RELOP NOT ADDOP MENOS MULOP

%left   T_IGUAL MENOS
%right  RELOP ADDOP MULOP

%%
program:      PROGRAM IDENTIFIER T_PVIRG decl_list compound_stmt {table.printSymbolTable(); printQuadruplas();}
              ;

decl_list:    decl_list decl
              | decl
              ;

decl:         ident_list T_DOISP type T_PVIRG {table.install(&installBuffer, type); installBuffer.clear();}
              ;

ident_list:   ident_list T_VIRG IDENTIFIER {installBuffer.push_back($3);}
              | IDENTIFIER                 {installBuffer.push_back($1);}
              ;

type :        INTEGER     {type = "INTEGER"; }
              | REAL      {type = "REAL";    }
              | BOOLEAN   {type = "BOOLEAN"; }
              | CHAR      {type = "CHAR";    }
              ;

compound_stmt: BEGIN_T stmt_list END;

stmt_list:    stmt_list stmt          
              | stmt                  
              ;

stmt:         assign_stmt   T_PVIRG   
              | if_stmt
              | loop_stmt     T_PVIRG
              | read_stmt     T_PVIRG
              | write_stmt    T_PVIRG
              | compound_stmt T_PVIRG
              ;

assign_stmt:  IDENTIFIER T_IGUAL expr               { 
                                                      if(pilhaFlowControl.size()){
                                                        pilhaFlowControl.back()->addQuadrupla(new Quadrupla(":=", $3->result, "", $1));
                                                      }else{
                                                        quadruplas.push_back(new Quadrupla(":=", $3->result, "", $1));
                                                      }
                                                    }
              ;

if_stmt:      if_aux IF cond if_true_list THEN stmt                            { 
                                                                                if(pilhaFlowControl.size() > 1){
                                                                                  pilhaFlowControl.back()->addQuadrupla(new Quadrupla("IF"+$3->jumpType, $3->result, "goto", "?"));
                                                                                  $$ = new FlowControl();
                                                                                  pilhaFlowControl.push_back($$);
                                                                                }else{
                                                                                  quadruplas.push_back(new Quadrupla("IF"+$3->jumpType, $3->result, "goto", "?"));
                                                                                  pilhaFlowControl.back()->commitLists(&quadruplas);
                                                                                  pilhaFlowControl.pop_back(); 
                                                                                }
                                                                              }
              | if_aux IF cond THEN if_true_list stmt if_false_list ELSE stmt { 
                                                                                if(pilhaFlowControl.size() > 1){

                                                                                  pilhaFlowControl.back()->addQuadrupla(new Quadrupla("IF"+$3->jumpType, $3->result, "goto", "?"));
                                                                                  $$ = new FlowControl();
                                                                                  pilhaFlowControl.push_back($$);
                                                                                }else{
                                                                                  quadruplas.push_back(new Quadrupla("IF"+$3->jumpType, $3->result, "goto", "?"));
                                                                                  pilhaFlowControl.back()->commitLists(&quadruplas);
                                                                                  pilhaFlowControl.pop_back();
                                                                                }
                                                                              }
              ;

if_aux:                                             { 
                                                      $$ = new FlowControl();
                                                      pilhaFlowControl.push_back($$);
                                                    }
              ;

if_true_list:                                       { pilhaFlowControl.back()->setActiveList("true"); }
              ;

if_false_list:                                      { pilhaFlowControl.back()->setActiveList("false"); }
              ;

cond:         expr
              ;

loop_stmt:    stmt_prefix DO stmt_list stmt_suffix  { }
              ;

stmt_prefix:  
              | WHILE cond
              ;

stmt_suffix:  UNTIL cond
              | END
              ;

read_stmt:    READ T_ABRE ident_list T_FECHA  { 
                                                if(pilhaFlowControl.size()){
                                                  pilhaFlowControl.back()->addQuadrupla(new Quadrupla("READ",  "_", "", ""));
                                                }else{
                                                  quadruplas.push_back(new Quadrupla("READ",  "_", "", ""));
                                                }
                                              }
              ;

write_stmt:   WRITE T_ABRE expr_list T_FECHA  { 
                                                if(pilhaFlowControl.size()){
                                                  pilhaFlowControl.back()->addQuadrupla(new Quadrupla("WRITE",  "_", "", ""));
                                                }else{
                                                  quadruplas.push_back(new Quadrupla("WRITE",  "_", "", ""));
                                                }
                                              }
              ;

expr_list:    expr
              | expr_list T_VIRG expr
              ;

expr:         simple_expr                                    
              | simple_expr RELOP simple_expr { $$ = new Expression($1, $2, $3, newtemp(), getType($2, $1->type, $3->type), &table, &quadruplas); }
              ;

simple_expr:  term
              | simple_expr ADDOP term        { $$ = new Expression($1, "+", $3, newtemp(), getType("+", $1->type, $3->type), &table, &quadruplas);}
              | simple_expr MENOS term        { $$ = new Expression($1, "-", $3, newtemp(), getType("-", $1->type, $3->type), &table, &quadruplas);}
              ;

term:         factor_a
              | term MULOP factor_a           { $$ = new Expression($1, "*", $3, newtemp(), getType("*", $1->type, $3->type), &table, &quadruplas);}
              ;

factor_a:     MENOS factor                    { $$ = new Expression($2, "-", newtemp(), &table, &quadruplas); }
              | factor
              ;

factor:       IDENTIFIER              { $$ = new Expression($1, (table.get($1))->getType()); } 
              | constant          
              | T_ABRE expr T_FECHA   { $$ = $2; }
              | NOT factor            { $$ = new Expression($2, "NOT", newtemp(), &table, &quadruplas); }
              ;

constant:     INTEGER_CONSTANT    { $$ = new Expression($1, "INTEGER"); }
              | REAL_CONSTANT     { $$ = new Expression($1, "REAL");    }
              | CHAR_CONSTANT     { $$ = new Expression($1, "BOOLEAN"); }
              | BOOLEAN_CONSTANT  { $$ = new Expression($1, "CHAR");    }
              ;

%%

int main(){
  int i;
  return yyparse();
}

void yyerror(char *s){
  printf("\nERROR - %s",s);
}

void printQuadruplas(){  
  std::cout << "\n\nQuadruplas" << std::endl; 
  //std::cout << "op | arg1 | arg2 | rslt" << std::endl; 
  for(int i=0; quadruplas.size(); i++){
    quadruplas.at(i)->print();
  }
}

/*
void desempilhaQuadruplas(int numQuadruplas){
  for(int i=0; i<numQuadruplas; i++){

    pilhaQuadruplasFlowControl.pop_back();
  }
}*/