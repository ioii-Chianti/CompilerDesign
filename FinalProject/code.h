#define TABLESIZE 5000

#define GLOBALMODE 1
#define LOCALMODE 2
#define ARGUMENTMODE 3

extern int currentCounter;
extern int currentScope;
extern FILE *f_asm;
extern struct Entry {
    char *name;
    int scope;
    int offset;
    int total_args;
    int total_locals;
    int mode;
} Table[TABLESIZE];

int InstallSymbol(char *str);
int LookUpSymbol(char *str);
void PopUpSymbol(int scope);
int SetParameters(char *functor);
void InstallArray(char *str, int size);
void GenFunctionHeader(char *functor);
void GenFunctionEnding();