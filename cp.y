%{
  #include "SymbolTable.hpp"
  using namespace std;

// int insideFlowControl = 0;

  extern int yylineno;

  void yyerror(char *s);
  int yylex();
  std::string getType(std::string op, std::string e1Type, std::string e2Type);
  std::string newtemp();

  SymbolTable::SymbolTable table;
  std::stack<Block*> blockStack;
  std::vector<FlowControl*> pilhaFlowControl;
  std::vector<Expression*> expressionList;
  std::vector<std::string> indentifierList;
  std::string type;
  int nivel = 0;
  bool semanticError = false;
  int serial = 0;

  //Dps a gente passa isso aqui pra um lugar melhor
  //Gera código objeto MEPA(melhorzinho parece)? (tudo é arquitetura de pilha parece, até bytecode java)
  //Tbm tem o MIPS, se quiser da de olhar
  void gerarCodigoObjeto(Quadruplas *quadruplas){
    std::cout << "\nCODIGO OBJETO" << std::endl;
    int size = quadruplas->size();
    /*
    for(int i=0; i<size; i++){
      //converterQuadrupla(quadruplas->at(i));
      if(quadruplas->at(i)->op == "JFLSE"){

      }else if(quadruplas->at(i)->op == "JTRUE"){

      }else if(quadruplas->at(i)->op == ">"){

      }else if(quadruplas->at(i)->op == "<"){

      }else
    }
    */
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
  Block * block_t;
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
%type <flow_t> if_stmt if_aux loop_stmt loop_prefix
%type <string_t> RELOP NOT ADDOP MENOS MULOP
%type <block_t> compound_stmt block_aux

%left   T_IGUAL MENOS
%right  RELOP ADDOP MULOP

%%
program:      PROGRAM IDENTIFIER T_PVIRG decl_list compound_stmt    {
                                                                        table.printSymbolTable();
                                                                        Block *block = $5;
                                                                        Quadruplas *quadruplas;
                                                                        quadruplas = block->getQuadruplas();
                                                                        quadruplas->print();
                                                                        gerarCodigoObjeto(quadruplas);
                                                                        quadruplas->deleteAll();
                                                                        delete block;
                                                                    }
              ;

decl_list:    decl_list decl
              | decl
              ;

decl:         ident_list T_DOISP type T_PVIRG {table.install(&indentifierList, type); indentifierList.clear();}
              ;

ident_list:   ident_list T_VIRG IDENTIFIER {indentifierList.push_back($3);}
              | IDENTIFIER                 {indentifierList.push_back($1);}
              ;

type :        INTEGER     {type = "INTEGER"; }
              | REAL      {type = "REAL";    }
              | BOOLEAN   {type = "BOOLEAN"; }
              | CHAR      {type = "CHAR";    }
              ;

compound_stmt: block_aux BEGIN_T stmt_list END  {
                                                    if(blockStack.size() > 1){
                                                        Block *block;
                                                        block = blockStack.top();
                                                        blockStack.pop();
                                                        blockStack.top()->addQuadruplas(block);

                                                        delete block;
                                                        nivel--;
                                                    }
                                                }
                ;

block_aux:      {
                $$ = new Block(nivel);
                blockStack.push($$);
                nivel++;
            }
            ;


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
                                                        blockStack.top()->addQuadrupla(new Quadrupla(":=", $3->result, "", $1));
                                                      }
                                                    }
              ;

if_stmt:      if_aux if_true_list stmt                      {
                                                                FlowControl *flowControl;
                                                                flowControl = pilhaFlowControl.back();
                                                                pilhaFlowControl.pop_back();
                                                                if(pilhaFlowControl.size() > 0){
                                                                    flowControl->commitLists(pilhaFlowControl.back()->getQuadruplas());
                                                                }
                                                                else{
                                                                    flowControl->commitLists(blockStack.top()->getQuadruplas());
                                                                }

                                                            }
              | if_aux if_true_list stmt if_false_list stmt {
                                                              FlowControl *flowControl;
                                                              flowControl = pilhaFlowControl.back();
                                                              pilhaFlowControl.pop_back();
                                                              if(pilhaFlowControl.size() > 0){
                                                                  flowControl->commitLists(pilhaFlowControl.back()->getQuadruplas());
                                                              }
                                                              else{
                                                                  flowControl->commitLists(blockStack.top()->getQuadruplas());
                                                              }
                                                            }
              ;

if_aux:       IF cond                               {
                                                      pilhaFlowControl.push_back(new If($2));
                                                    }
              ;

if_true_list: THEN                                  { pilhaFlowControl.back()->setActiveList("true"); }
              ;

if_false_list: ELSE                                 { pilhaFlowControl.back()->setActiveList("false"); }
              ;

cond:         expr
              ;

loop_stmt:    loop_prefix DO stmt_list loop_suffix  {
                                                      FlowControl *flowControl;
                                                      flowControl = pilhaFlowControl.back();
                                                      pilhaFlowControl.pop_back();
                                                      if(pilhaFlowControl.size() > 0){
                                                          flowControl->commitLists(pilhaFlowControl.back()->getQuadruplas());
                                                      }
                                                      else{
                                                          flowControl->commitLists(blockStack.top()->getQuadruplas());
                                                      }
                                                    }
              ;

loop_prefix:                                        {
                                                      pilhaFlowControl.push_back(new DoUntil());
                                                    }
              | WHILE cond                          {
                                                      pilhaFlowControl.push_back(new While($2));
                                                    }
              ;

loop_suffix:  UNTIL cond                            {
                                                      ((DoUntil*)pilhaFlowControl.back())->setCondition($2);
                                                    }
              | END
              ;

read_stmt:    READ T_ABRE ident_list T_FECHA  {
                                                if(pilhaFlowControl.size()){
                                                	for(auto it = indentifierList.begin(); it != indentifierList.end(); it++){
                                                  	pilhaFlowControl.back()->addQuadrupla(new Quadrupla("READ",  *it, "", ""));
                                                  }
                                                }
                                                else{
                                               		for(auto it = indentifierList.begin(); it != indentifierList.end(); it++){
                                                  	blockStack.top()->addQuadrupla(new Quadrupla("READ",  *it, "", ""));
                                                  }
                                                }
                                                indentifierList.clear();
                                              }
              ;

write_stmt:   WRITE T_ABRE expr_list T_FECHA  {
                                                if(pilhaFlowControl.size()){
                                                	for(auto it = expressionList.begin(); it != expressionList.end(); it++){
                                                  	pilhaFlowControl.back()->addQuadrupla(new Quadrupla("WRITE",  (*it)->result, "", ""));
                                                    delete *it;
                                                  }
                                                }else{
                                                	for(auto it = expressionList.begin(); it != expressionList.end(); it++){
                                                  	blockStack.top()->addQuadrupla(new Quadrupla("WRITE",  (*it)->result, "", ""));
                                                    delete *it;
                                                  }
                                                }
                                                expressionList.clear();
                                              }
              ;

expr_list:    expr											{expressionList.push_back($1);}
              | expr_list T_VIRG expr		{expressionList.push_back($3);}
              ;

expr:         simple_expr
              | simple_expr RELOP simple_expr {
                                                if(pilhaFlowControl.size()){
                                                  $$ = new Expression($1, $2, $3, newtemp(), getType($2, $1->type, $3->type), &table, pilhaFlowControl.back()->getQuadruplas());
                                                }else{
                                                  $$ = new Expression($1, $2, $3, newtemp(), getType($2, $1->type, $3->type), &table, blockStack.top()->getQuadruplas());
                                                }
                                              }
              ;

simple_expr:  term
              | simple_expr ADDOP term        {
                                                if(pilhaFlowControl.size()){
                                                  $$ = new Expression($1, "+", $3, newtemp(), getType("+", $1->type, $3->type), &table, pilhaFlowControl.back()->getQuadruplas());
                                                }else{
                                                  $$ = new Expression($1, "+", $3, newtemp(), getType("+", $1->type, $3->type), &table, blockStack.top()->getQuadruplas());
                                                }
                                              }
              | simple_expr MENOS term        {
                                                if(pilhaFlowControl.size()){
                                                  $$ = new Expression($1, "-", $3, newtemp(), getType("-", $1->type, $3->type), &table, pilhaFlowControl.back()->getQuadruplas());
                                                }else{
                                                  $$ = new Expression($1, "-", $3, newtemp(), getType("-", $1->type, $3->type), &table, blockStack.top()->getQuadruplas());
                                                }
                                              }
              ;

term:         factor_a
              | term MULOP factor_a           {
                                                if(pilhaFlowControl.size()){
                                                  $$ = new Expression($1, "*", $3, newtemp(), getType("*", $1->type, $3->type), &table, pilhaFlowControl.back()->getQuadruplas());
                                                }else{
                                                  $$ = new Expression($1, "*", $3, newtemp(), getType("*", $1->type, $3->type), &table, blockStack.top()->getQuadruplas());
                                                }
                                              }
              ;

factor_a:     MENOS factor                    {
                                                if(pilhaFlowControl.size()){
                                                  $$ = new Expression($2, "-", newtemp(), &table, pilhaFlowControl.back()->getQuadruplas());
                                                }else{
                                                  $$ = new Expression($2, "-", newtemp(), &table, blockStack.top()->getQuadruplas());
                                                }
                                              }
              | factor
              ;

factor:       IDENTIFIER              { $$ = new Expression($1, (table.get($1))->getType()); }
              | constant
              | T_ABRE expr T_FECHA   { $$ = $2; }
              | NOT factor            {
										if(pilhaFlowControl.size())
											$$ = new Expression($2, "NOT", newtemp(), &table, pilhaFlowControl.back()->getQuadruplas());
										else
                                            $$ = new Expression($2, "NOT", newtemp(), &table, blockStack.top()->getQuadruplas());
										}
              ;

constant:     INTEGER_CONSTANT    { $$ = new Expression($1, "INTEGER"); }
              | REAL_CONSTANT     { $$ = new Expression($1, "REAL");    }
              | CHAR_CONSTANT     { $$ = new Expression($1, "CHAR"); }
              | BOOLEAN_CONSTANT  { $$ = new Expression($1, "BOOLEAN");    }
              ;

%%



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
  std::cout << "Semantic error - type mismatch on line " << yylineno << std::endl;
  semanticError = true;
}

std::string newtemp(){
  std::string temp;
  temp = "" + std::to_string(serial) + "t";
  serial++;
  return temp;
}

int main(){
    return yyparse() != 0 || semanticError;
}

void yyerror(char *s){
  std::cout << "Sintatic error - " << s << " on line " << yylineno << std::endl;
}
