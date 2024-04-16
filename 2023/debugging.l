%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int currentLine = 1;
    char currentContent[256];
    int isSourceOn = 1;
    int isTokenOn = 1;
    void printToken(int token);
    void printErrorMsg();
    void newLine();

    typedef enum {
        TYPE_INT = 10,
        TYPE_DOUBLE,
        TYPE_CHAR,
        TYPE_BOOL
    } TYPES;

    typedef enum {
        OP_PLUS = 20,
        OP_MINUS,
        OP_MULTIPLE,
        OP_DIVIDE,
        OP_MOD,
        OP_INCREMENT,
        OP_DECREMENT,

        OP_LESS,
        OP_LESSEQUAL,
        OP_GREATER,
        OP_GREATEREQUAL,
        OP_EQUAL,
        OP_NOTEQUAL,

        OP_ASSIGN,
        OP_AND,
        OP_OR,
        OP_NOT,

        OP_BITAND,
        OP_BITOR
    } OPERATORS;

    typedef enum {
        PUNC_COLON = 50,
        PUNC_SEMICOLON,
        PUNC_COMMA,
        PUNC_DOT,
        PUNC_LEFTBRACKET,
        PUNC_RIGHTBRACKET,
        PUNC_LEFTPERAN,
        PUNC_RIGHTPERAN,
        PUNC_LEFTBRACE,
        PUNC_RIGHTBRACE
    } PUNCTUATIONS;

    typedef enum {
        KEY_VOID = 70,
        KEY_CONST,
        KEY_SIGNED,
        KEY_UNSIGNED,
        KEY_SHORT,
        KEY_LONG,
        KEY_NULL,

        KEY_FOR,
        KEY_DO,
        KEY_WHILE,
        KEY_BREAK,
        KEY_CONTINUE,
        KEY_IF,
        KEY_ELSE,
        
        KEY_SWITCH,
        KEY_CASE,
        KEY_DEFAULT,

        KEY_RETURN,
        KEY_STRUCT
    } KEYWORDS;

    typedef enum {
        TOKEN_IDENTIFIER = 150,
        TOKEN_INTEGER, 
	    TOKEN_DOUBLE,
        TOKEN_CHARACTER,
        TOKEN_STRING
    } TOKEN;

    typedef enum {
        OTHER_SPACE = 170,
        OTHER_COMMENT,
        OTHER_MULTICOMMENT,

        OTHER_SOURCEON,
        OTHER_SOURCEOFF,
        OTHER_TOKENON,
        OTHER_TOKENOFF
    } OTHERS;

    typedef enum {
        STDIO_fclose = 200,
        STDIO_clearerr,
        STDIO_feof,
        STDIO_ferror,
        STDIO_fflush,
        STDIO_fgetpos,
        STDIO_fopen,
        STDIO_fread,
        STDIO_freopen,
        STDIO_fseek,
        STDIO_fsetpos,
        STDIO_ftell,
        STDIO_fwrite,
        STDIO_remove,
        STDIO_rename,
        STDIO_rewind,
        STDIO_setbuf,
        STDIO_setvbuf,
        STDIO_tmpfile,
        STDIO_tmpnam,
        STDIO_fprintf,
        STDIO_printf,
        STDIO_sprintf,
        STDIO_vfprintf,
        STDIO_vprintf,
        STDIO_vsprintf,
        STDIO_fscanf,
        STDIO_scanf,
        STDIO_sscanf,
        STDIO_fgetc,
        STDIO_fgets,
        STDIO_fputc,
        STDIO_fputs,
        STDIO_getc,
        STDIO_getchar,
        STDIO_gets,
        STDIO_putc,
        STDIO_putchar,
        STDIO_puts,
        STDIO_ungetc,
        STDIO_perror
    } STDIOFUNC;
%}


/* Definitions */
%x VARDEF
%s COMMENT

/* ^042 means '"'; ^047 means "'" */
KEYWORD    ("for"|"do"|"while"|"break"|"continue"|"if"|"else"|"return"|"struct"|"switch"|"case"|"default"|"void"|"int"|"double"|"char"|"const"|"signed"|"unsigned"|"short"|"long")
IDENTIFIER ([_a-zA-Z][_a-zA-Z0-9]*)
INTEGER    (0|[+-]0|[1-9][0-9]*|[+-][1-9][0-9]*)
DOUBLE     ([1-9][0-9]*"."[0-9]*[1-9]|"."[0-9]+|[0-9]+"."|[+-][1-9][0-9]*"."[0-9]*[1-9]|[+-]"."[0-9]+|[+-][0-9]+".")
CHARACTER  (\047[^\047\a\b\f\n\r\t\v\\\'\"\?\0]\047)
STRING     (\042[^\042\a\b\f\n\r\t\v\\\'\"\?\0]*\042)

COMMENT ("//"[^\n]*)

SOURCEOFF ("#pragma source off")
SOURCEON  ("#pragma source on")
TOKENOFF  ("#pragma token off")
TOKENON   ("#pragma token on")


/* return token type */
%%

"int"    { return TYPE_INT; }
"double" { return TYPE_DOUBLE; }
"char"   { return TYPE_CHAR; }
"bool"   { return TYPE_BOOL; }

"+"  { return OP_PLUS; }
"-"  { return OP_MINUS; }
"*"  { return OP_MULTIPLE; }
"/"  { return OP_DIVIDE; }
"%"  { return OP_MOD; }
"++" { return OP_INCREMENT; }
"--" { return OP_DECREMENT; }
"<"  { return OP_LESS; }
"<=" { return OP_LESSEQUAL; }
">"  { return OP_GREATER; }
">=" { return OP_GREATEREQUAL; }
"==" { return OP_EQUAL; }
"!=" { return OP_NOTEQUAL; }
""   { return OP_ASSIGN; }
"&&" { return OP_AND; }
"||" { return OP_OR; }
"!"  { return OP_NOT; }
"&"  { return OP_BITAND; }
"|"  { return OP_BITOR; }

":"  { return PUNC_COLON; }
";"  { return PUNC_SEMICOLON; }
","  { return PUNC_COMMA; }
"."  { return PUNC_DOT; }
"["  { return PUNC_LEFTBRACKET; }
"]"  { return PUNC_RIGHTBRACKET; }
"("  { return PUNC_LEFTPERAN; }
")"  { return PUNC_RIGHTPERAN; }
"{"  { return PUNC_LEFTBRACE; }
"}"  { return PUNC_RIGHTBRACE; }

"void"     { return KEY_VOID; }
"const"    { return KEY_CONST; }
"signed"   { return KEY_SIGNED; }
"unsigned" { return KEY_UNSIGNED; }
"short"    { return KEY_SHORT; }
"long"     { return KEY_LONG; }
"null"     { return KEY_NULL; }
"for"      { return KEY_FOR; }
"do"       { return KEY_DO; }
"while"    { return KEY_WHILE; }
"break"    { return KEY_BREAK; }
"continue" { return KEY_CONTINUE; }
"if"       { return KEY_IF; }
"else"     { return KEY_ELSE; }
"switch"   { return KEY_SWITCH; }
"case"     { return KEY_CASE; }
"default"  { return KEY_DEFAULT; }
"return"   { return KEY_RETURN; }
"struct"   { return KEY_STRUCT; }

"fclose"   { return STDIO_fclose; }
"clearerr" { return STDIO_clearerr; }
"feof"     { return STDIO_feof; }
"ferror"   { return STDIO_ferror; }
"fflush"   { return STDIO_fflush; }
"fgetpos"  { return STDIO_fgetpos; }
"fopen"    { return STDIO_fopen; }
"fread"    { return STDIO_fread; }
"freopen"  { return STDIO_freopen; }
"fseek"    { return STDIO_fseek; }
"fsetpos"  { return STDIO_fsetpos; }
"ftell"    { return STDIO_ftell; }
"fwrite"   { return STDIO_fwrite; }
"remove"   { return STDIO_remove; }
"rename"   { return STDIO_rename; }
"rewind"   { return STDIO_rewind; }
"setbuf"   { return STDIO_setbuf; }
"setvbuf"  { return STDIO_setvbuf; }
"tmpfile"  { return STDIO_tmpfile; }
"tmpnam"   { return STDIO_tmpnam; }
"fprintf"  { return STDIO_fprintf; }
"printf"   { return STDIO_printf; }
"sprintf"  { return STDIO_sprintf; }
"vfprintf" { return STDIO_vfprintf; }
"vprintf"  { return STDIO_vprintf; }
"vsprintf" { return STDIO_vsprintf; }
"fscanf"   { return STDIO_fscanf; }
"scanf"    { return STDIO_scanf; }
"sscanf"   { return STDIO_sscanf; }
"fgetc"    { return STDIO_fgetc; }
"fgets"    { return STDIO_fgets; }
"fputc"    { return STDIO_fputc; }
"fputs"    { return STDIO_fputs; }
"getc"     { return STDIO_getc; }
"getchar"  { return STDIO_getchar; }
"gets"     { return STDIO_gets; }
"putc"     { return STDIO_putc; }
"putchar"  { return STDIO_putchar; }
"puts"     { return STDIO_puts; }
"ungetc"   { return STDIO_ungetc; }
"perror"   { return STDIO_perror; }

{IDENTIFIER} { return TOKEN_IDENTIFIER; }
{INTEGER}    { return TOKEN_INTEGER; }
{DOUBLE}     { return TOKEN_DOUBLE; }
{CHARACTER}  { return TOKEN_CHARACTER; }
{STRING}     { return TOKEN_STRING; }

[\n]   { newLine(); }
[\t\r] { return OTHER_SPACE; }

{COMMENT}              { return OTHER_COMMENT; }
"/*"                   { BEGIN(COMMENT); return OTHER_MULTICOMMENT; }
<COMMENT>[^*\n]*      { return OTHER_MULTICOMMENT; }
<COMMENT>"*"+ [^*\n]* { return OTHER_MULTICOMMENT; }
<COMMENT>\n           { newLine(); }
<COMMENT>"*/"         { BEGIN(INITIAL); return OTHER_MULTICOMMENT; }

{SOURCEOFF} { isSourceOn = 0; return OTHER_SOURCEOFF; }
{SOURCEON}  { isSourceOn = 1; return OTHER_SOURCEON; }
{TOKENOFF}  { isTokenOn = 0; return OTHER_TOKENOFF; }
{TOKENON}   { isTokenOn = 1; return OTHER_TOKENON; }

%%


int main() {
    int token;
    while (token = yylex()) {
        strcat(currentLine, yytext);
        if (isTokenOn)
            printToken(token);
    }

    return 0;
}

int yywrap() { return 1; }

void printToken(int token) {
    // types
    if (10 <= token && token <= 14)
        fprintf(stdout, "#key:%s\n", yytext);
    // operators
    else if (20 <= token && token <= 39)
        fprintf(stdout, "#op:%s\n", yytext);
    // punctuations
    else if (50 <= token && token <= 59)
        fprintf(stdout, "#punc:%s\n", yytext);
    else if (200 <= token && token <= 221)
        fprintf(stdout, "#key:%s\n", yytext);
    // token id
    else if (token == TOKEN_IDENTIFIER)
        fprintf(stdout, "#id:%s\n", yytext);
    // token int
    else if (token == TOKEN_INTEGER)
        fprintf(stdout, "#integer:%s\n", yytext);
    // token double
    else if (token == TOKEN_DOUBLE)
        fprintf(stdout, "#double:%s\n", yytext);
    // token char
    else if (token == TOKEN_CHARACTER)
        fprintf(stdout, "#char:%s\n", yytext);
    // token string
    else if (token == TOKEN_STRING) {
        char str[256];
        int i;
        for (i = 1; yytext[i] != '\042'; i++)
            str[i - 1] = yytext[i];
        str[i - 1] = '\0';
        fprintf(stdout, "#string:%s\n", str);
    }

    return;
}

void newLine() {
    if (isSourceOn)
        fprintf(stdout, "%d:%s\n", currentLine, currentContent);
    memset(currentContent, 0, sizeof(currentContent));
    currentLine++;
    return;
}