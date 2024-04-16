%option yylineno

%{
    /* Definition Section */

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

char content[256];
bool isSourceOn = true;
bool isTokenOn = true;
void PrintToken(char *);
void PrintContent();

%}

/* Regular expressions */
%x COMMENTs
%x COMMENTm

KEYWORD       ("for"|"do"|"while"|"break"|"continue"|"if"|"else"|"return"|"struct"|"switch"|"case"|"default"|"void"|"int"|"double"|"float"|"char"|"const"|"signed"|"unsigned"|"short"|"long")
MACRO         ("NULL"|"__COUNTER__"|"__LINE__"|"INT_MAX"|"INT_MIN"|"CHAR_MAX"|"CHAR_MIN"|"MAX"|"MIN")
IDENTIFIER    ([_a-zA-Z][_a-zA-Z0-9]*)
OPERATOR      ("+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"|"&"|"|")
PUNCTUATION   (":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}")
INTEGER       ([+-]?[0-9]+)
FLOATING      ([+-]?([0-9]*"."[0-9]+|[0-9]+"."(0-9)*))
CHARACTER     (\'(\\.|[^'\\])\'|\'"\\"[0-7]{1,3}\'|\'"\\x"[0-9A-Fa-f]+\'|\'"\\u"[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]\'|\'"\\U"[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]\')
STRING        (\"(\\.|[^"\\])*\")

SOURCEOFF     ("#pragma"[ \t]+"source"[ \t]+"off")
SOURCEON      ("#pragma"[ \t]+"source"[ \t]+"on")
TOKENOFF      ("#pragma"[ \t]+"token"[ \t]+"off")
TOKENON	      ("#pragma"[ \t]+"token"[ \t]+"on")

OTHERS        .



%%
    /* Rules Section */

"\n"           { strcat(content, yytext); if (isSourceOn) {PrintContent();} content[0] = '\0'; }
<COMMENTm>"\n" { strcat(content, yytext); if (isSourceOn) {PrintContent();} content[0] = '\0'; }

{SOURCEON}  { strcat(content, yytext); isSourceOn = true; }
{SOURCEOFF} { strcat(content, yytext); isSourceOn = false; }
{TOKENON}   { strcat(content, yytext); isTokenOn = true; }
{TOKENOFF}  { strcat(content, yytext); isTokenOn = false; }

{KEYWORD}     { strcat(content, yytext); if (isTokenOn) {PrintToken("key");} }
{MACRO}       { strcat(content, yytext); if (isTokenOn) {PrintToken("macro");} }
{IDENTIFIER}  { strcat(content, yytext); if (isTokenOn) {PrintToken("id");} }
{OPERATOR}    { strcat(content, yytext); if (isTokenOn) {PrintToken("op");} } 
{PUNCTUATION} { strcat(content, yytext); if (isTokenOn) {PrintToken("punc");} }
{INTEGER}     { strcat(content, yytext); if (isTokenOn) {PrintToken("integer");} }
{FLOATING}    { strcat(content, yytext); if (isTokenOn) {PrintToken("float");} } 
{CHARACTER}   { strcat(content, yytext); if (isTokenOn) {PrintToken("char");} }
{STRING}      { strcat(content, yytext); if (isTokenOn) {PrintToken("string");} }

"//".*           { strcat(content, yytext); }
"//".*"\\\n"     { strcat(content, yytext); if (isSourceOn) {PrintContent();} content[0] = '\0'; BEGIN(COMMENTs); }
<COMMENTs>"\\\n" { strcat(content, yytext); if (isSourceOn) {PrintContent();} content[0] = '\0'; }
<COMMENTs>"\n"   { strcat(content, yytext); if (isSourceOn) {PrintContent();} content[0] = '\0'; BEGIN(0); }

"/*"           { strcat(content, yytext); BEGIN(COMMENTm);}
<COMMENTm>"*/" { strcat(content, yytext); BEGIN(0);}

{OTHERS}           { strcat(content, yytext); }
<COMMENTs>{OTHERS} { strcat(content, yytext); }
<COMMENTm>{OTHERS} { strcat(content, yytext); }



%%
    /* User Code Section */

void PrintToken(char *tokenType) {
    printf("#%s:%s\n", tokenType, yytext);
    return;
}

void PrintContent() {
    printf("%d:%s", yylineno - 1, content);
    return;
}