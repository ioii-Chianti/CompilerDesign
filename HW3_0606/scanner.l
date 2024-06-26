%{
#include "y.tab.h"
char* Buffer(const char *str) {
    char *buffer = malloc(strlen(str) + 1);
    strcpy(buffer, str);
    return buffer;
}
%}

%x                  COMMENT
%x                  COMMENTS

Identifiers         ([_a-zA-Z][_a-zA-Z0-9]*)
Integer             ([0-9]+)
Double              ([0-9]+"."[0-9]*|[0-9]*"."[0-9]+)
Operators           ("+"|"-"|"*"|"/"|"%"|"="|"!"|"~"|"^"|"&"|"|")
Punctuations        (":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}")
Char                (\'(\\.|[^'\\])\'|\'"\\"[0-7]{1,3}\'|\'"\\x"[0-9A-Fa-f]+\'|\'"\\u"[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]\'|\'"\\U"[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]\')
String              (\"(\\.|[^"\\])*\")
Others              .

%%

[ \t\n]             {}

"LOW"               {yylval.strVal = Buffer(yytext); return LOW;}
"HIGH"              {yylval.strVal = Buffer(yytext); return HIGH;}

"const"             {yylval.strVal = Buffer(yytext); return TYPECONST;}
"signed"            {yylval.strVal = Buffer(yytext); return TYPESIGNED;}
"unsigned"          {yylval.strVal = Buffer(yytext); return TYPEUNSIGNED;}
"long"              {yylval.strVal = Buffer(yytext); return TYPELONG;}
"short"             {yylval.strVal = Buffer(yytext); return TYPESHORT;}
"int"               {yylval.strVal = Buffer(yytext); return TYPEINT;}
"char"              {yylval.strVal = Buffer(yytext); return TYPECHAR;}
"float"             {yylval.strVal = Buffer(yytext); return TYPEFLOAT;}
"double"            {yylval.strVal = Buffer(yytext); return TYPEDOUBLE;}
"void"              {yylval.strVal = Buffer(yytext); return TYPEVOID;}

"if"                {yylval.strVal = Buffer(yytext); return IF;}
"else"              {yylval.strVal = Buffer(yytext); return ELSE;}
"switch"            {yylval.strVal = Buffer(yytext); return SWITCH;}
"case"              {yylval.strVal = Buffer(yytext); return CASE;}
"default"           {yylval.strVal = Buffer(yytext); return DEFAULT;}
"while"             {yylval.strVal = Buffer(yytext); return WHILE;}
"do"                {yylval.strVal = Buffer(yytext); return DO;}
"for"               {yylval.strVal = Buffer(yytext); return FOR;}
"return"            {yylval.strVal = Buffer(yytext); return RETURN;}
"break"             {yylval.strVal = Buffer(yytext); return BREAK;}
"continue"          {yylval.strVal = Buffer(yytext); return CONTINUE;}
"NULL"              {yylval.strVal = Buffer(yytext); return NUL;}

{Identifiers}       {yylval.strVal = Buffer(yytext); return ID;}
{Integer}           {yylval.intVal = atoi(yytext); return INT;}
{Double}            {yylval.douVal = atof(yytext); return DOUBLE;}
{Operators}         {yylval.strVal = Buffer(yytext); return yytext[0];}
{Punctuations}      {yylval.strVal = Buffer(yytext); return yytext[0];}
{Char}              {yylval.strVal = Buffer(yytext); return CHAR;}
{String}            {yylval.strVal = Buffer(yytext); return STRING;}

"++"                {yylval.strVal = Buffer(yytext); return INCREMENT;}
"--"                {yylval.strVal = Buffer(yytext); return DECREMENT;}
"<"                 {yylval.strVal = Buffer(yytext); return LESSTHAN;}
"<="                {yylval.strVal = Buffer(yytext); return LESSEQUAL;}
">"                 {yylval.strVal = Buffer(yytext); return GREATERTHAN;}
">="                {yylval.strVal = Buffer(yytext); return GREATEREQUAL;}
"=="                {yylval.strVal = Buffer(yytext); return EQUAL;}
"!="                {yylval.strVal = Buffer(yytext); return NOTEQUAL;}
"&&"                {yylval.strVal = Buffer(yytext); return LOGICAND;}
"||"                {yylval.strVal = Buffer(yytext); return LOGICOR;}
">>"                {yylval.strVal = Buffer(yytext); return RIGHTSHIFT;}
"<<"                {yylval.strVal = Buffer(yytext); return LEFTSHIFT;}

"//".*              {}
"//".*"\\\n"        {BEGIN COMMENT;}
<COMMENT>"\\\n"     {}
<COMMENT>"\n"       {BEGIN 0;}

"/*"                {BEGIN COMMENTS;}
<COMMENTS>"*/"      {BEGIN 0;}
<COMMENTS>"\n"      {}

{Others}            {}
<COMMENT>{Others}   {}
<COMMENTS>{Others}  {}

%%