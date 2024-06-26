#define TABLESIZE 5000
#define GLOBAL 1
#define LOCAL 2
#define ARGUMENT 3

extern struct Entry {
    char *name;
    int scope;
    int offset;
    int args;
    int locals;
    int mode;
} Table[TABLESIZE];

int InstallSymbol(char *str);
int SetParameters(char *functor);
void InstallArray(char *str, int size);
int LookUpSymbol(char *str);
void PopUpSymbol(int scope);
void CodeGeneratorFunctionHeader(char *functor);
void CodeGeneratorFunctionBody();

extern int currentCounter;
extern int currentScope;
extern FILE *f_asm;