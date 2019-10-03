/*
 *  GERADOR DE ANALISADOR SINTÁTICO
 * */

//declaracoes C
%{
int yyerror(char *s);
int yylex(void);
%}

//declaracoes
%union{ //specifies the entire collection of possible data types for semantic values
  int		int_t;
  double	double_t;
  string	string_t;
}

%token	<int_t>		INTCONST
%token	<double_t>	REALCONST
%token	<string_t>	CHARCONST
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
%token	FALSE
%token	TRUE
%token	UNIMENOS
%token	NOT

%token	PONTOVIRGULA
%token	VIRGULA
%token	DOISPONTOS
%token	IGUAL
%token	ABREPAR
%token	FECHAPAR
%token	INTEGER_CONSTANT
%token	REAL_CONSTANT
%token	CHAR_CONSTANT
%token	BOOLEAN_CONSTANT

%left	RELOP
%left	ADDOP
%left	MULOP
%right	NOT
%right	UNIMENOS
%right	IGUAL

%start	program

%%
//regras de traducao - gramaticas LC
program: 	PROGRAM IDENTIFIER PONTOVIRGULA decl_list compound_stmt;

decl_list: 	decl_list PONTOVIRGULA decl
			| decl;

decl: 		ident_list DOISPONTOS type;

ident_list: ident_list VIRGULA IDENTIFIER
			| identifier;

type : 	INTEGER
        | REAL
        | BOOLEAN
        | CHAR;

compound_stmt: BEGIN stmt_list END;

stmt_list: 	stmt_list PONTOVIRGULA stmt
			| stmt;

stmt: 	assign_stmt
        | if_stmt
        | loop_stmt
        | read_stmt
        | write_stmt
        | compound_stmt;

assign_stmt: identifier IGUAL expr;

if_stmt: 	IF cond THEN stmt
          	| IF cond THEN stmt ELSE stmt;

cond: expr; 

loop_stmt: stmt_prefix DO stmt_list stmt_suffix;

stmt_prefix: 	/*vazio*/
				| WHILE cond;

stmt_suffix: 	UNTIL cond
              	| END;

read_stmt: READ ABREPAR ident_list FECHAPAR  { printf("\nREAD: ?"); };

write_stmt: WRITE ABREPAR expr_list FECHAPAR  { printf("\nWRITE : ?"); };

expr_list: 	expr
			| expr_list VIRGULA expr;

expr: 		simple_expr
			| simple_expr RELOP simple_expr { $$ = $1 > $3; };

simple_expr: 	term
				| simple_expr ADDOP term { $$ = $1 + $3; };

term: 		factor_a
			| term MULOP factor_a { $$ = $1 * $3; };

factor_a: 	UNIMENOS factor { $$ = -1* $2 };
			| factor;

factor: 	identifier
            | constant
            | ABREPAR expr FECHAPAR
            | NOT factor;

constant: 	INTEGER_CONSTANT
            | REAL_CONSTANT
            | CHAR_CONSTANT
            | BOOLEAN_CONSTANT;

boolean_constant: 	FALSE
					| TRUE;


%%
  
int yylex(){
	/*Tokens * tokens = analisadorLexico();
    for(tokens)
    if(token.nome == "id"){
        yylval.string_t = token.valor;
        return IDENTIFIER;
    }
    else{

    }*/
    
}

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
