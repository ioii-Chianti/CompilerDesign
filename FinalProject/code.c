#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "code.h"

int currentCounter = 0;
int currentScope = 0;
struct Entry Table[TABLESIZE];

char *StringBuffer(char *str) {
    char *buffer = malloc(strlen(str) + 1);
    strcpy(buffer, str);
    return buffer;
}

int InstallSymbol(char *str) {
    Table[currentCounter].scope = currentScope;
    Table[currentCounter].name = StringBuffer(str);
    Table[currentCounter].offset = currentCounter;
    Table[currentCounter].mode = LOCALMODE;
    currentCounter++;

    fprintf(f_asm, "\taddi sp, sp, -4\n");

    return currentCounter;
}

int SetParameters(char *functor) {
    int i, j, idx, total_args;
    idx = LookUpSymbol(functor);

    total_args = currentCounter-idx-1;
    Table[idx].total_args = total_args;
    for (j = total_args, i = currentCounter-1; i > idx; i--, j--) {
        Table[i].scope = currentScope;
        Table[i].offset = j;
        Table[i].mode = ARGUMENTMODE;
    }

    return idx;
}

void InstallArray(char *s, int size) {
    for (int i = 0; i < size; i++) {
        if (i == 0) {
            Table[currentCounter].name = StringBuffer(s);
        } else {
            Table[currentCounter].name = "";
        }
        Table[currentCounter].scope = currentScope;
        Table[currentCounter].offset = currentCounter;
        Table[currentCounter].mode = LOCALMODE;

        fprintf(f_asm, "\t/* a[%d].offset = %d */\n", i, currentCounter);
        fprintf(f_asm, "\taddi sp, sp, -4\n");
        currentCounter++;
    }
}

int LookUpSymbol(char *str) {
    int i;
    if (currentCounter == 0)
        return -1;
    for (i = currentCounter - 1; i >= 0; i--) {
        if (!strcmp(str, Table[i].name))
            return i;
    }
    return -1;
}

void PopUpSymbol(int scope) {
    int i;
    if (currentCounter == 0)
        return;
    for (i = currentCounter - 1; i >= 0; i--) {
        if (Table[i].scope != scope)
            break;
    }
    if (i < 0)
        currentCounter = 0;
    currentCounter = i + 1;
}

void GenFunctionHeader(char *functor) {
    fprintf(f_asm, "%s:\n", functor);
    fprintf(f_asm, "\t// BEGIN PROLOGUE\n");
    fprintf(f_asm, "\tsw s0, -4(sp)\n");
    fprintf(f_asm, "\taddi sp, sp, -4\n");
    fprintf(f_asm, "\taddi s0, sp, 0\n");
    fprintf(f_asm, "\tsw sp, -4(s0)\n");
    fprintf(f_asm, "\tsw s1, -8(s0)\n");
    fprintf(f_asm, "\tsw s2, -12(s0)\n");
    fprintf(f_asm, "\tsw s3, -16(s0)\n");
    fprintf(f_asm, "\tsw s4, -20(s0)\n");
    fprintf(f_asm, "\tsw s5, -24(s0)\n");
    fprintf(f_asm, "\tsw s6, -28(s0)\n");
    fprintf(f_asm, "\tsw s7, -32(s0)\n");
    fprintf(f_asm, "\tsw s8, -36(s0)\n");
    fprintf(f_asm, "\tsw s9, -40(s0)\n");
    fprintf(f_asm, "\tsw s10, -44(s0)\n");
    fprintf(f_asm, "\tsw s11, -48(s0)\n");
    fprintf(f_asm, "\taddi sp, s0, -48\n");
    fprintf(f_asm, "\t// END PROLOGUE\n");
    fprintf(f_asm, "\n");
}

void GenFunctionEnding() {
    fprintf(f_asm, "\t// BEGIN EPILOGUE\n");
    fprintf(f_asm, "\tlw s11, -48(s0)\n");
    fprintf(f_asm, "\tlw s10, -44(s0)\n");
    fprintf(f_asm, "\tlw s9, -40(s0)\n");
    fprintf(f_asm, "\tlw s8, -36(s0)\n");
    fprintf(f_asm, "\tlw s7, -32(s0)\n");
    fprintf(f_asm, "\tlw s6, -28(s0)\n");
    fprintf(f_asm, "\tlw s5, -24(s0)\n");
    fprintf(f_asm, "\tlw s4, -20(s0)\n");
    fprintf(f_asm, "\tlw s3, -16(s0)\n");
    fprintf(f_asm, "\tlw s2, -12(s0)\n");
    fprintf(f_asm, "\tlw s1, -8(s0)\n");
    fprintf(f_asm, "\tlw sp, -4(s0)\n");
    fprintf(f_asm, "\taddi sp, sp, 4\n");
    fprintf(f_asm, "\tlw s0, -4(sp)\n");
    fprintf(f_asm, "\t// END EPILOGUE\n");
    fprintf(f_asm, "\n");
    fprintf(f_asm, "\tjalr zero, 0(ra)\n\n");
}