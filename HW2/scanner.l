%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"
int yylex();
void yyerror();

%}

Space [ \t]
%x  COMMENT

%%
"++" { return INCREASE; }
"--" { return DECREASE; }
"<=" { return LESS_OR_EQUAL_THAN; }
">=" { return GREATER_OR_EQUAL_THAN; }
"<<" { return SHIFT_LEFT; }
">>" { return SHIFT_RIGHT; }
"==" { return EQUAL; }
"!=" { return NOT_EQUAL; }
"&&" { return AND; }
"||" { return OR; }
"+" {return ADD; }
"-" { return MINUS; }
"*" { return MULTIPLY; }
"/" { return DIVIDE; }
"%" { return MOD; }
"!" { return LOGICAL_NOT; }
"~" { return BITWISE_NOT; }
"<" { return LESS_THAN; }
">" { return GREATER_THAN; }
"&" { return BITWISE_AND; }
"|" { return BITWISE_OR; }
"^" { return BITWISE_XOR; }
"=" { return ASSIGN; }

";" { return SEMICOLON; }
"," { return COMMA; }
":" { return COLON; }
"(" { return L_PARENTHESIS; }
")" { return R_PARENTHESIS; }
"[" { return L_BRACKET; }
"]" { return R_BRACKET; }
"{" { return L_BRACE; }
"}" { return R_BRACE; }

"if" { return IF; }
"else" { return ELSE; }
"switch" { return SWITCH; }
"case" { return CASE; }
"default" { return DEFAULT; }
"do" { return DO; }
"while" { return WHILE; }
"for" { return FOR; }
"return" { return RETURN; }
"break" { return BREAK;}
"continue" { return CONTINUE; }

"const" {yylval.strVal = strdup(yytext); return CONST;}
"int" {yylval.strVal = strdup(yytext); return INT;}
"char" {yylval.strVal = strdup(yytext); return CHAR;}
"float" {yylval.strVal = strdup(yytext); return FLOAT;}
"double" {yylval.strVal = strdup(yytext); return DOUBLE;}
"void" {yylval.strVal = strdup(yytext); return VOID;}
"signed" {yylval.strVal = strdup(yytext); return SIGNED;}
"unsigned" {yylval.strVal = strdup(yytext); return UNSIGNED;}
"long" {yylval.strVal = strdup(yytext); return LONG;}
"short" {yylval.strVal = strdup(yytext); return SHORT;}
"NULL" {yylval.strVal = strdup("0"); return NL;}

[a-zA-Z_][a-zA-Z0-9_]*  {yylval.strVal = strdup(yytext); return IDENTIFIER;}
[0-9]+ {yylval.intVal = atoi(yytext); return INT_LITERAL;}
("."[0-9]+|[0-9]+"."|[0-9]+"."[0-9]+)  {yylval.doubleVal = atof(yytext); return FLOAT_LITERAL;}
\'(\\.|[^'])\'  {yylval.strVal = strdup(yytext); return CHAR_LITERAL; }
\"(\\.|[^"])*\" {yylval.strVal = strdup(yytext); return STRING_LITERAL; }

{Space} {}
\n  {}

"//".* {}
"/*"    {}
<COMMENT>"*/"   {}
<COMMENT>.  {}
<COMMENT>\n {}

%%