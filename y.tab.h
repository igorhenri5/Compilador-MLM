/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 27 "cp.y" /* yacc.c:1909  */


  #include <iostream>
  #include <unordered_map>
  #include <vector>
  #include <string>
  #include "SymbolTable.hpp"


#line 54 "y.tab.h" /* yacc.c:1909  */

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    PROGRAM = 258,
    INTEGER = 259,
    REAL = 260,
    BOOLEAN = 261,
    CHAR = 262,
    BEGIN_T = 263,
    END = 264,
    IF = 265,
    THEN = 266,
    ELSE = 267,
    DO = 268,
    WHILE = 269,
    UNTIL = 270,
    READ = 271,
    WRITE = 272,
    INTEGER_CONSTANT = 273,
    BOOLEAN_CONSTANT = 274,
    REAL_CONSTANT = 275,
    CHAR_CONSTANT = 276,
    IDENTIFIER = 277,
    T_DOISP = 278,
    T_PVIRG = 279,
    T_VIRG = 280,
    T_IGUAL = 281,
    T_ABRE = 282,
    T_FECHA = 283,
    RELOP = 284,
    NOT = 285,
    ADDOP = 286,
    MENOS = 287,
    MULOP = 288
  };
#endif
/* Tokens.  */
#define PROGRAM 258
#define INTEGER 259
#define REAL 260
#define BOOLEAN 261
#define CHAR 262
#define BEGIN_T 263
#define END 264
#define IF 265
#define THEN 266
#define ELSE 267
#define DO 268
#define WHILE 269
#define UNTIL 270
#define READ 271
#define WRITE 272
#define INTEGER_CONSTANT 273
#define BOOLEAN_CONSTANT 274
#define REAL_CONSTANT 275
#define CHAR_CONSTANT 276
#define IDENTIFIER 277
#define T_DOISP 278
#define T_PVIRG 279
#define T_VIRG 280
#define T_IGUAL 281
#define T_ABRE 282
#define T_FECHA 283
#define RELOP 284
#define NOT 285
#define ADDOP 286
#define MENOS 287
#define MULOP 288

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 38 "cp.y" /* yacc.c:1909  */

  int    int_t;
  int    bool_t;
  double double_t;
  char   char_t;
  char*  string_t;
  Expression* expr_t;
  FlowControl* flow_t;
  Block * block_t;

#line 143 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
