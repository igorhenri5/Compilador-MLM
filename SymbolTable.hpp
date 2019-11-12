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
  };

  class Expression {
  public:
    Expression *e1, *e2;
    std::string op, result, type;
  public:
    Expression(Expression *e1, std::string op, Expression *e2, std::string type, std::string result, SymbolTable::SymbolTable *table, std::vector<Quadrupla*> *quadruplas){
      this->e1 = e1;
      this->e2 = e2;
      this->op = op;
      this->result = result;      
      this->type   = type;
      
      table->install(this->result, this->type);
      quadruplas->push_back(new Quadrupla(op, e1->result, e2->result, this->result));
    }
    Expression(Expression *e1, std::string op, std::string result, SymbolTable::SymbolTable *table, std::vector<Quadrupla*> *quadruplas){
      this->e1 = e1;
      this->op = op;
      this->result = result;
      this->type   = e1->type;
      
      table->install(this->result, this->type);
      quadruplas->push_back(new Quadrupla(op, e1->result, NULL, this->result));
    }
    Expression(std::string result, std::string type){
      this->result = result;
      this->type   = type;
    }
    ~Expression(){
      delete e1;
      delete e2;
    }
  };

#endif