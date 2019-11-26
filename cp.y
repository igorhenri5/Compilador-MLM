%{
  #include "SymbolTable.hpp"

  using namespace std;

  extern int yylineno;

  void yyerror(char *s);
  int yylex();
  std::string getType(std::string op, std::string e1Type, std::string e2Type);
  std::string newtemp();
  void gerarCodigoObjeto(Quadruplas *quadruplas);
  void checkType(std::string tipoDesejado, std::string tipoObtido);

  SymbolTable::SymbolTable table;
  std::stack<Block*> blockStack;
  std::vector<FlowControl*> pilhaFlowControl;
  std::vector<Expression*> expressionList;
  std::vector<std::string> indentifierList, declList;
  std::string type;
  int nivel = 0;
  bool semanticError = false;
  int serial = 0;
  std::string outputFileName;

%}

%code requires {
  #include "SymbolTable.hpp"
  #include <unordered_map>
  #include <iostream>
  #include <fstream>
  #include <vector>
  #include <string>
  #include <map>
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
                                                                        if(!semanticError){
                                                                        	quadruplas->print();
                                                                        	gerarCodigoObjeto(quadruplas);
                                                                        }
                                                                        quadruplas->deleteAll();
                                                                        delete block;
                                                                    }
              ;

decl_list:    decl_list decl
              | decl
              ;

decl:         ident_list T_DOISP type T_PVIRG {
												                        table.install(&indentifierList, type);
                                                for(int i = 0; i < indentifierList.size(); i++){
                                                  declList.push_back(indentifierList[i]);
                                                }
                                                indentifierList.clear();
                                              }
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
                                                      checkType(table.get($1)->getType(), $3->type);
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
                                                  $$ = new Expression($1, $2, $3, newtemp(), getType($2, $1->type, $3->type), &table, pilhaFlowControl.back()->getQuadruplas());
                                                }else{
                                                  $$ = new Expression($1, $2, $3, newtemp(), getType($2, $1->type, $3->type), &table, blockStack.top()->getQuadruplas());
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
                                                  $$ = new Expression($1, $2, $3, newtemp(), getType($2, $1->type, $3->type), &table, pilhaFlowControl.back()->getQuadruplas());
                                                }else{
                                                  $$ = new Expression($1, $2, $3, newtemp(), getType($2, $1->type, $3->type), &table, blockStack.top()->getQuadruplas());
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

constant:     INTEGER_CONSTANT    { $$ = new Expression($1, "INTEGER");  }
              | REAL_CONSTANT     { $$ = new Expression($1, "REAL");     }
              | CHAR_CONSTANT     { $$ = new Expression($1, "CHAR");     }
              | BOOLEAN_CONSTANT  { $$ = new Expression($1, "BOOLEAN");  }
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

void checkType(std::string tipoDesejado, std::string tipoObtido){
  if( tipoDesejado != tipoObtido){
    if( tipoDesejado == "REAL" && tipoObtido == "INTEGER")
      return;
    if( tipoDesejado == "REAL" && tipoObtido == "CHAR")
      return;
    if( tipoDesejado == "INTEGER" && tipoObtido == "CHAR")
      return;
    std::cout << "Semantic error - type mismatch on line " << yylineno << std::endl;
    std::cout << "Wanted: " << tipoDesejado << std::endl;
    std::cout << "Got:    " << tipoObtido   << std::endl; 
    semanticError = true;
  }
}

bool isConstant(std::string candidato){
  return candidato.length() > 0 && candidato[0] >= '0' && candidato[0] <= '9' && candidato[candidato.length() - 1] != 't';
}

void carregarArg(std::ofstream *codigoObjeto, std::string arg, std::map<std::string, int> *declLocation){
  if(isConstant(arg)){
    (*codigoObjeto) << "CRCT " << arg << std::endl;
  }
  else if(declLocation->find(arg) != declLocation->end())
  	(*codigoObjeto) << "CRVL 0 " << (*declLocation)[arg] << std::endl;
}

void armazenarResult(std::ofstream *codigoObjeto, std::string result, std::map<std::string, int> *declLocation){
  if(declLocation->find(result) != declLocation->end())
        (*codigoObjeto) << "ARMZ 0 " << (*declLocation)[result] << std::endl;
}

void geraCodigoDoisArgumentos(std::ofstream *codigoObjeto, Quadrupla *quadrupla, std::string comando, std::map<std::string, int> *declLocation){
  	carregarArg(codigoObjeto, quadrupla->arg1, declLocation);
    carregarArg(codigoObjeto, quadrupla->arg2, declLocation);
  	(*codigoObjeto)  << comando << "I" << std::endl;
    armazenarResult(codigoObjeto, quadrupla->result, declLocation);
}

void geraCodigoDoisArgumentosType(std::ofstream *codigoObjeto, Quadrupla *quadrupla, std::string comandoInt, std::string comandoF, std::map<std::string, int> *declLocation){
  	carregarArg(codigoObjeto, quadrupla->arg1, declLocation);
    carregarArg(codigoObjeto, quadrupla->arg2, declLocation);
  	if(quadrupla->type == "INTEGER") (*codigoObjeto)  << comandoInt << std::endl;
    else (*codigoObjeto)  << comandoF << std::endl;
    armazenarResult(codigoObjeto, quadrupla->result, declLocation);
}

void gerarCodigoObjeto(Quadruplas *quadruplas){
  std::map<std::string, int> declLocation;
  int size = quadruplas->size();
  std::ofstream codigoObjeto(outputFileName);

  codigoObjeto << "INPP" << std::endl;
  codigoObjeto << "AMEM " << declList.size() << std::endl;

  for(int i = 0; i < declList.size(); i++){
    declLocation[declList[i]] = i;
  }

  for(int i = 0; i < size; i++){
    codigoObjeto << "Q" << i << " ";
    if(quadruplas->at(i)->op == ":="){
      carregarArg(&codigoObjeto, quadruplas->at(i)->arg1, &declLocation);
      armazenarResult(&codigoObjeto, quadruplas->at(i)->result, &declLocation);

    }else if(quadruplas->at(i)->op == "+"){
      geraCodigoDoisArgumentosType(&codigoObjeto, quadruplas->at(i), "SOMA" , "SOMF", &declLocation);

    }else if(quadruplas->at(i)->op == "-"){
      if(quadruplas->at(i)->arg2 != ""){
        geraCodigoDoisArgumentosType(&codigoObjeto, quadruplas->at(i), "SUBT" , "SUBF", &declLocation);
      }
      else{
        geraCodigoDoisArgumentosType(&codigoObjeto, quadruplas->at(i), "INVI" , "INVF", &declLocation);
      }

    }else if(quadruplas->at(i)->op == "or"){
      geraCodigoDoisArgumentos(&codigoObjeto, quadruplas->at(i), "DISJ", &declLocation);

    }else if(quadruplas->at(i)->op == "*"){
      geraCodigoDoisArgumentosType(&codigoObjeto, quadruplas->at(i), "MULT" , "MULF", &declLocation);

    }else if(quadruplas->at(i)->op == "/"){
      geraCodigoDoisArgumentosType(&codigoObjeto, quadruplas->at(i), "DIVI" , "DIVF", &declLocation);

    }else if(quadruplas->at(i)->op == "div"){
      geraCodigoDoisArgumentos(&codigoObjeto, quadruplas->at(i), "DIVI", &declLocation);

    }else if(quadruplas->at(i)->op == "mod"){
      carregarArg(&codigoObjeto, quadruplas->at(i)->arg1, &declLocation);
      carregarArg(&codigoObjeto, quadruplas->at(i)->arg1, &declLocation);
      carregarArg(&codigoObjeto, quadruplas->at(i)->arg2, &declLocation);
      codigoObjeto << "DIVI" << std::endl;
      carregarArg(&codigoObjeto, quadruplas->at(i)->arg2, &declLocation);
      codigoObjeto << "MULT" << std::endl;
      codigoObjeto << "SUBI" << std::endl;
      armazenarResult(&codigoObjeto, quadruplas->at(i)->result, &declLocation);

    }else if(quadruplas->at(i)->op == "and"){
      geraCodigoDoisArgumentos(&codigoObjeto, quadruplas->at(i), "CONJ", &declLocation);

    }else if(quadruplas->at(i)->op == ">"){
      geraCodigoDoisArgumentosType(&codigoObjeto, quadruplas->at(i), "CMMA", "CMMF", &declLocation);
    }else if(quadruplas->at(i)->op == "<"){
      geraCodigoDoisArgumentosType(&codigoObjeto, quadruplas->at(i), "CMME", "CMMF", &declLocation);
    }else if(quadruplas->at(i)->op == "<="){
      geraCodigoDoisArgumentosType(&codigoObjeto, quadruplas->at(i), "CMEG", "CMEF", &declLocation);
    }else if(quadruplas->at(i)->op == ">="){
      geraCodigoDoisArgumentosType(&codigoObjeto, quadruplas->at(i), "CMAG", "CMAF", &declLocation);
    }else if(quadruplas->at(i)->op == "!="){
      geraCodigoDoisArgumentosType(&codigoObjeto, quadruplas->at(i), "CMDG", "CMDF", &declLocation);
    }else if(quadruplas->at(i)->op == "NOT"){
        codigoObjeto << "NEGA" << std::endl;

    }else if(quadruplas->at(i)->op == "IFFALSE"){
        codigoObjeto << "DSVF Q" << i+std::stoi(quadruplas->at(i)->arg1) << std::endl;
    }else if(quadruplas->at(i)->op == "JUMP"){
		codigoObjeto << "DSVS Q" << i+std::stoi(quadruplas->at(i)->arg1) << std::endl;

    }else if(quadruplas->at(i)->op == "READ"){
		if(quadruplas->at(i)->type == "REAL") codigoObjeto << "LEIF" << std::endl;
        else codigoObjeto << "LEIT" << std::endl;
      	armazenarResult(&codigoObjeto, quadruplas->at(i)->arg1, &declLocation);
    }else if(quadruplas->at(i)->op == "WRITE"){
      	carregarArg(&codigoObjeto, quadruplas->at(i)->arg1, &declLocation);
		if(quadruplas->at(i)->type == "REAL") codigoObjeto << "IMPF " << std::endl;
        else if(quadruplas->at(i)->type == "INTEGER") codigoObjeto << "IMPR " << std::endl;
      	else codigoObjeto << "IMPC" << std::endl;
    }
  }
  codigoObjeto << "Q" << size << " PARA" << std::endl;
  codigoObjeto.close();
}

int main(int argc, char **argv){
    if(argc != 2){
        std::cout << "Passar o seguinte parametro: <outputFileName>" << std::endl;
        return 1;
    }
    outputFileName = argv[1];
    return yyparse() != 0 || semanticError;
}

void yyerror(char *s){
  std::cout << "Sintatic error - " << s << " on line " << yylineno << std::endl;
}

