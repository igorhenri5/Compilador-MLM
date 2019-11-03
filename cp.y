%{
  #include <stdio.h>
  #include <iostream>
  #include <unordered_map>
  #include <vector>

  using namespace std;

  void yyerror(char *s);
  int yylex();

  std::unordered_map<std::string,std::string> symbolTable;
  
  namespace SymbolTable{
    class Entry{
    private:
      std::string type, name;
    public: 
      Entry(std::string name, std::string type){
        this->name = name;
        this->type = type;
      }

      void setType(std::string type){
        this->type = type;
      }
      std::string getType(){
        return type;
      }

      void setName(std::string name){
        this->name = name;
      }
      std::string getName(){
        return name;
      }
      
      void printEntry(){
        std::cout << type << " - " << name << endl;
      }
      
    };

    class SymbolTable{
    private:
      std::unordered_map<std::string,Entry *> table;
    public:
      SymbolTable(){}

      ~SymbolTable(){
        for(auto it = table.cbegin(); it != table.cend(); ++it){
            delete it->second;
        }
      }   
      
      void install(std::string name, std::string type){
        Entry *entry;
        entry = new Entry(name, type);
        this->table[name] = entry;                  
      }
      
      void install(std::vector<std::string> *names, std::string type){
        for(auto it = names->begin(); it != names->end(); ++it){        
          install(*it, type);
        }
      }
      
      Entry* get(std::string name){
        return this->table[name];
      }

      void printSymbolTable(){
        cout << "\n\nSymbol Table" << endl; 
        for(auto it = table.cbegin(); it != table.cend(); ++it){
          it->second->printEntry();
        }
      }
        
    };
    
  }
  
SymbolTable::SymbolTable table;
std::vector<std::string> installBuffer;

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

%token  <string_t> RELOP
%token  <string_t> NOT
%token  <string_t> ADDOP
%token  <string_t> MENOS
%token  <string_t> MULOP

%left   T_IGUAL MENOS
%right  RELOP ADDOP MULOP

%type <double_t> expr term factor_a factor simple_expr

%%
program:      PROGRAM IDENTIFIER T_PVIRG decl_list compound_stmt {table.printSymbolTable();}
              ;

decl_list:    decl_list decl
              | decl
              ;

decl:         |
              ident_list T_DOISP type T_PVIRG
              ;

ident_list:   ident_list T_VIRG IDENTIFIER {installBuffer.push_back($3);}
              | IDENTIFIER                 {installBuffer.push_back($1);}
              ;

type :        INTEGER     {table.install(&installBuffer, "INTEGER"); installBuffer.clear();}
              | REAL      {table.install(&installBuffer, "REAL");    installBuffer.clear();}
              | BOOLEAN   {table.install(&installBuffer, "BOOLEAN"); installBuffer.clear();}
              | CHAR      {table.install(&installBuffer, "CHAR");    installBuffer.clear();}
              ;

compound_stmt: BEGIN_T stmt_list END;

stmt_list:    stmt_list stmt          
              | stmt                  
              ;

stmt:         
              | assign_stmt   T_PVIRG 
              | if_stmt
              | loop_stmt     T_PVIRG
              | read_stmt     T_PVIRG
              | write_stmt    T_PVIRG
              | compound_stmt T_PVIRG
              ;

assign_stmt:  IDENTIFIER T_IGUAL expr         {}
              ;

if_stmt:      IF cond THEN stmt               {}
              | IF cond THEN stmt ELSE stmt   {}
              ;

cond:         expr
              ;

loop_stmt:    stmt_prefix DO stmt_list stmt_suffix {}
              ;

stmt_prefix:  
              | WHILE cond
              ;

stmt_suffix:  UNTIL cond
              | END
              ;

read_stmt:    READ T_ABRE ident_list T_FECHA  {  }

write_stmt:   WRITE T_ABRE expr_list T_FECHA  {  }
              ;

expr_list:    expr
              | expr_list T_VIRG expr
              ;

expr:         simple_expr                                    
              | simple_expr RELOP simple_expr { $$ = 1; }
              ;

simple_expr:  term
              | simple_expr ADDOP term        { $$ = $1 + $3; }
              | simple_expr MENOS term        { $$ = $1 - $3; }
              ;

term:         factor_a
              | term MULOP factor_a           { $$ = $1 * $3; }
              ;

factor_a:     MENOS factor                    { $$ = -1 * $2; }
              | factor
              ;

factor:       IDENTIFIER                
              | constant
              | T_ABRE expr T_FECHA
              | NOT factor
              ;

constant:     INTEGER_CONSTANT 
              | REAL_CONSTANT
              | CHAR_CONSTANT
              | BOOLEAN_CONSTANT
              ;

%%

void updateSymbolVal(char* symbol, char* value){
  std::string sym(symbol);
  std::string val(value);
  cout << endl << "[" << sym << "][" << val << "]" << endl;
  symbolTable[sym] = val;
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

