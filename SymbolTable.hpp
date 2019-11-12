#ifndef SBTB
#define SBTB

  #include <iostream>
  #include <unordered_map>
  #include <vector>
  #include <string>

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
        std::cout << type << " - " << name << std::endl;
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
        std::cout << "\n\nSymbol Table" << std::endl;
        for(auto it = table.cbegin(); it != table.cend(); ++it){
          it->second->printEntry();
        }
      }

    };

  }

  class Quadrupla{
  public:
    std::string op, arg1, arg2, result;
  public:
    Quadrupla(std::string op, std::string arg1, std::string arg2, std::string result){
      this->op = op;
      this->arg1 = arg1;
      this->arg2 = arg2;
      this->result = result;
    }
    void print(){
      std::cout << op << " " << arg1  << " " << arg2 << " " <<  result << std::endl;
    }
  };

  class Expression {
  public:
    Expression *e1, *e2;
    std::string op, result, type, jumpType;
  public:
    Expression(Expression *e1, std::string op, Expression *e2, std::string result, std::string type, SymbolTable::SymbolTable *table, std::vector<Quadrupla*> *quadruplas){
      this->e1 = e1;
      this->e2 = e2;
      this->op = op;
      this->result = result;
      this->type   = type;
      this->jumpType = checkJumpType("op");

      table->install(this->result, this->type);
      quadruplas->push_back(new Quadrupla(op, e1->result, e2->result, this->result));
    }
    Expression(Expression *e1, std::string op, std::string result, SymbolTable::SymbolTable *table, std::vector<Quadrupla*> *quadruplas){
      this->e1 = e1;
      this->op = op;
      this->result = result;
      this->type   = e1->type;
      this->jumpType = "JNZ";

      table->install(this->result, this->type);
      quadruplas->push_back(new Quadrupla(op, e1->result, NULL, this->result));
    }
    Expression(std::string result, std::string type){
      this->result = result;
      this->type   = type;
      this->jumpType = "JNZ";
    }
    ~Expression(){
      delete e1;
      delete e2;
    }
    std::string checkJumpType(std::string op){
      if(op == ">")
        return "JG";
      if(op == ">=")
        return "JGE";
      if(op == "=")
        return "JEQ";
      if(op == "!=")
        return "JNE";
      if(op == "<")
        return "JL";
      if(op == "<=")
        return "JLE";
      return "JNZ";
    }
  };

  class FlowControl{
    public:
      std::vector<Quadrupla*> trueList;
      std::vector<Quadrupla*> falseList;
      std::string activeList;
    FlowControl(){
    }
    ~FlowControl(){
      //delete das lista ali
    }
    void setActiveList(std::string activeList){
      this->activeList = activeList;
    }
    void addQuadrupla(Quadrupla* quadrupla){
      if(activeList == "true"){
        this->trueList.push_back(quadrupla);
      }else{
        this->falseList.push_back(quadrupla);
      }
    }
    void commitLists(std::vector<Quadrupla*>* quadruplas){
      //Aqui que a mágica acontece, mas tem uma pa de coisa pra fazer aq
      //quadruplas->push_back(new Quadrupla("GOTO", std::to_string(quadruplas->size()+trueList.size()), "", ""));
      for(int i=0; i<trueList.size() ;i++){
        quadruplas->push_back(trueList[i]);
      }
      quadruplas->push_back(new Quadrupla("GOTO", std::to_string(quadruplas->size()+trueList.size()+falseList.size()), "", ""));
      for(int i=0; i<falseList.size() ;i++){
        quadruplas->push_back(falseList[i]);
      }

    }
  };

  class Block{
  private:
      std::vector<Quadrupla*> quadruplas;
  public:
      void addQuadrupla(Quadrupla* quadrupla){
          this->quadruplas.push_back(quadrupla);
      }

      std::vector<Quadrupla*>* getQuadruplas(){
          return &this->quadruplas;
      }

      int getSize(){
          return this->quadruplas.size();
      }
  };

#endif
