%{
#include "y.tab.h"
char* copy(const char *str) {
    char *buffer = malloc(strlen(str)+1);
    strcpy(buffer, str);
    return buffer;
}
%}

%x                  COMMENT
%x                  COMMENTS

Identifiers         [_a-zA-Z][_a-zA-Z0-9]*
Integer             [0-9]+
Double              [0-9]+"."[0-9]*|[0-9]*"."[0-9]+
Operators           "+"|"-"|"*"|"/"|"%"|"="|"!"|"~"|"^"|"&"|"|"
Punctuations        ":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}"
Char                \'(\\.|[^'\\])\'|\'"\\"[0-7]{1,3}\'|\'"\\x"[0-9A-Fa-f]+\'|\'"\\u"[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]\'|\'"\\U"[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]\'
String              \"(\\.|[^"\\])*\"
Others              .

%%

[ \t\n]            

"LOW"               {yylval.strVal = copy(yytext); return LOW;}
"HIGH"              {yylval.strVal = copy(yytext); return HIGH;}

"const"             {yylval.strVal = copy(yytext); return TYPECONST;}
"signed"            {yylval.strVal = copy(yytext); return TYPESIGNED;}
"unsigned"          {yylval.strVal = copy(yytext); return TYPEUNSIGNED;}
"long"              {yylval.strVal = copy(yytext); return TYPELONG;}
"short"             {yylval.strVal = copy(yytext); return TYPESHORT;}
"int"               {yylval.strVal = copy(yytext); return TYPEINT;}
"char"              {yylval.strVal = copy(yytext); return TYPECHAR;}
"float"             {yylval.strVal = copy(yytext); return TYPEFLOAT;}
"double"            {yylval.strVal = copy(yytext); return TYPEDOUBLE;}
"void"              {yylval.strVal = copy(yytext); return TYPEVOID;}

"if"                {yylval.strVal = copy(yytext); return IF;}
"else"              {yylval.strVal = copy(yytext); return ELSE;}
"switch"            {yylval.strVal = copy(yytext); return SWITCH;}
"case"              {yylval.strVal = copy(yytext); return CASE;}
"default"           {yylval.strVal = copy(yytext); return DEFAULT;}
"while"             {yylval.strVal = copy(yytext); return WHILE;}
"do"                {yylval.strVal = copy(yytext); return DO;}
"for"               {yylval.strVal = copy(yytext); return FOR;}
"return"            {yylval.strVal = copy(yytext); return RETURN;}
"break"             {yylval.strVal = copy(yytext); return BREAK;}
"continue"          {yylval.strVal = copy(yytext); return CONTINUE;}
"NULL"              {yylval.strVal = copy(yytext); return NL;}

{Identifiers}       {yylval.strVal = copy(yytext); return ID;}
{Integer}           {yylval.intVal = atoi(yytext); return INT;}
{Double}            {yylval.doubleVal = atof(yytext); return DOUBLE;}
{Operators}         {yylval.strVal = copy(yytext); return yytext[0];}
{Punctuations}      {yylval.strVal = copy(yytext); return yytext[0];}
{Char}              {yylval.strVal = copy(yytext); return CHAR;}
{String}            {yylval.strVal = copy(yytext); return STRING;}

"++"                {yylval.strVal = copy(yytext); return INC;}
"--"                {yylval.strVal = copy(yytext); return DEC;}
"<"                 {yylval.strVal = copy(yytext); return LESSTHAN;}
"<="                {yylval.strVal = copy(yytext); return LESSEQUAL;}
">"                 {yylval.strVal = copy(yytext); return GREATERTHAN;}
">="                {yylval.strVal = copy(yytext); return GREATEREQUAL;}
"=="                {yylval.strVal = copy(yytext); return EQUAL;}
"!="                {yylval.strVal = copy(yytext); return NOTEQUAL;}
">>"                {yylval.strVal = copy(yytext); return RIGHTSHIFT;}
"<<"                {yylval.strVal = copy(yytext); return LEFTSHIFT;}

"//".*             
"//".*"\\\n"        {BEGIN COMMENT;}
<COMMENT>"\\\n"    
<COMMENT>"\n"       {BEGIN 0;}

"/*"                {BEGIN COMMENTS;}
<COMMENTS>"*/"      {BEGIN 0;}
<COMMENTS>"\n"     

{Others}           
<COMMENT>{Others}  
<COMMENTS>{Others} 

%%