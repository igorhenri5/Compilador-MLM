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

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    INTEGER_CONSTANT = 258,
    REAL_CONSTANT = 259,
    CHAR_CONSTANT = 260,
    BOOLEAN_CONSTANT = 261,
    IDENTIFIER = 262,
    PROGRAM = 263,
    INTEGER = 264,
    REAL = 265,
    BOOLEAN = 266,
    CHAR = 267,
    BEGIN_T = 268,
    END = 269,
    IF = 270,
    THEN = 271,
    ELSE = 272,
    DO = 273,
    WHILE = 274,
    UNTIL = 275,
    READ = 276,
    WRITE = 277,
    MENOS = 278,
    NOT = 279,
    T_DOISP = 280,
    T_PVIRG = 281,
    T_VIRG = 282,
    T_IGUAL = 283,
    T_ABRE = 284,
    T_FECHA = 285,
    RELOP = 286,
    ADDOP = 287,
    MULOP = 288
  };
#endif
/* Tokens.  */
#define INTEGER_CONSTANT 258
#define REAL_CONSTANT 259
#define CHAR_CONSTANT 260
#define BOOLEAN_CONSTANT 261
#define IDENTIFIER 262
#define PROGRAM 263
#define INTEGER 264
#define REAL 265
#define BOOLEAN 266
#define CHAR 267
#define BEGIN_T 268
#define END 269
#define IF 270
#define THEN 271
#define ELSE 272
#define DO 273
#define WHILE 274
#define UNTIL 275
#define READ 276
#define WRITE 277
#define MENOS 278
#define NOT 279
#define T_DOISP 280
#define T_PVIRG 281
#define T_VIRG 282
#define T_IGUAL 283
#define T_ABRE 284
#define T_FECHA 285
#define RELOP 286
#define ADDOP 287
#define MULOP 288

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 12 "cp.y" /* yacc.c:1909  */
 
  int		int_t;
  float	float_t;
  char	char_t;
  char*	string_t;

#line 127 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
