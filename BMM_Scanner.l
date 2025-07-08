%{
#include<stdio.h>
#include <string.h>
#include "y.tab.h"
#include "var.h"
// #define yyterminate() return token::EOF

void yyerror(const char*);
int line;

int balance = 0;
int max_line=-1;


%}



%%

[ ]+ {}
LET {return LET;}
REM.*?\n {return REM;}
PRINT {return PRINT;}
IF {return IF;}
END {max_line = line;return END;}
GOSUB {balance++; return GOSUB;}
GOTO {return GOTO;}
NEXT {return NEXT;}
RETURN {balance--; if(balance<0) {print_error("No matching GOSUB for the RETURN statement\n",line);} return RETURN;}
THEN {return THEN;}
DEF {return DEF;}
DIM {return DIM;}
STOP {return STOP;}
FOR {return FOR;}
TO {return TO;}
INPUT {return INPUT;}
DATA {return DATA;}
STEP {return STEP;}
FN[A-Z] {return FNID;}
["].*["]    {return STRING;}

^[0-9]+ {line=atoi(yytext);yylval.num=line;if(max_line!=-1 && line>max_line){print_error("Code cannot exist after END statement!\n",line);} return LINE;}
[0-9]+ {yylval.db = atoi(yytext);return NUMBER;}
[a-z\t]+ {print_error("Invalid input!\n",line);}
\<\>  {yylval.s =strdup(yytext);return RELOP;}
\<=  {yylval.s =strdup(yytext);return RELOP;}
\>=  {yylval.s = strdup(yytext);return RELOP;}
\<   {yylval.s =strdup(yytext);return RELOP;}
\>   {yylval.s = strdup(yytext);return RELOP;}  
\n  {return *yytext;}
=   {return *yytext;}
[)(]    {return *yytext;}
[;,]      {return *yytext;}
[-\+^/\*]   {return OPERATOR;}
[A-Z][0-9]?[\$] {yylval.s = strdup(yytext);return ID;}
[A-Z][0-9]?[#] {yylval.s = strdup(yytext);return ID;}
[A-Z][0-9]?[!] {yylval.s = strdup(yytext);return ID;}
[A-Z][0-9]?[%] {yylval.s = strdup(yytext);return ID;}
[A-Z][0-9]? {yylval.s = strdup(yytext);return ID;}
.     {;}


%%


int yywrap()
{
    return 1;
}
