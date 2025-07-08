%{
    #include <stdio.h>
    #include <string.h>
    #include "var.h"
    int yylex(void);
    void yyerror(const char*);



// int lines[10000];
    int target_goto[10000];
    int target_gosub[10000];
    int var_type; // 0 for int, 1 for string

    extern FILE* yyin;
    extern int line;

%}

%error-verbose


%union{
    char *s;
    double db;
    float f;
    int num;
};




%token<s> RELOP LOGOP 
%token<db> NUMBER
%token STRING
%token OPERATOR FNID
%token LET REM PRINT IF END GOSUB GOTO NEXT RETURN THEN DEF DIM FOR TO STEP INPUT STOP DATA
%token <num> LINE
%token <s> ID
%left '+' '-'
%left '*' '/'
%left '^'
%left '(' ')'

%token YYEOF 0

%left RELOP
%left LOGOP



%%

programs:   program
            |programs program

program: LINE LET ID '=' exp '\n' 
        | LINE REM 
        | LINE PRINT print_stmt '\n' 
        | LINE IF condition THEN NUMBER '\n'
        | LINE END '\n'
        | LINE END YYEOF {return 0;}
        | LINE GOSUB exp '\n' 
        | LINE GOTO exp '\n' 
        | LINE INPUT input_exp '\n'
        | LINE RETURN '\n' 
        | LINE STOP '\n'
        | LINE DEF def_exp
        | LINE DATA data
        | LINE '\n'
        | YYEOF {return 0;}
        | LINE DIM declarations   
        | LINE FOR ID '=' exp TO exp STEP exp '\n' programs LINE NEXT ID '\n' {if(strcmp($3,$14)!=0){print_error("Different NEXT variable\n",$1);}}
        | LINE FOR ID '=' exp TO exp '\n' programs LINE NEXT ID '\n' {if(strcmp($3,$12)!=0){print_error("Different NEXT variable,\n",$1);}}
        | '\n'
        | LINE error '\n' {yyerrok; print_error("Invalid Keyword or expression!\n",$1);}
        | error '\n' {yyerrok;yyerror("Line number invalid or not present!\n");}
        ;

data:   constant  
        | constant ',' data
        | '\n'
        | error '\n' {yyerrok; print_error("Error in data entries!\n",line);}
        ;


constant:  NUMBER
           | STRING
            | error '\n' {yyerrok; print_error("Error in constant values!\n",line);}
            ;


input_exp: array
        | ID
        | ID ',' input_exp
        | declaration ',' input_exp
        | error LINE {yyerrok;print_error("Error in input expression!\n",line);}
        ;

array:  ID '(' var ')'
        | ID '(' var ',' var ')'
        | error '\n' {yyerrok; print_error("Incorrect syntax!\n",line);}
        ;

var: ID | NUMBER;

print_stmt: exp
            | exp ';'
            | exp ','
            | exp ';' print_stmt
            | exp ',' print_stmt
            | error '\n' {yyerrok; print_error("Error in print statement!\n",line);}
            ;


exps:   exp '\n'
        | exp '\n' exps
        | error '\n' {yyerrok; print_error("Error in expression!\n",line);}
        ; 

def_exp:    FNID '=' exp '\n'   
            | FNID '(' ID ')' '=' exp '\n'
            | error '\n' {yyerrok; print_error("Error in function definition!\n",line);}
            ;

declarations:   declaration
                | declaration ',' declarations
                | error '\n' {yyerrok; print_error("Error in declarations\n",line);}
                ;

declaration:    ID '(' NUMBER ')'
                | ID '(' NUMBER ',' NUMBER ')'
                | error '\n' {yyerrok; print_error("Syntax error in declaration!\n",line);}
                ;

exp:    ID
        | array
        | NUMBER      {var_type=0;} 
        | STRING        {var_type=1;}
        | exp OPERATOR exp 
        | exp '=' exp 
        | '(' exp ')'
        | exp LOGOP exp
        | exp RELOP exp
        | error '\n'  {yyerrok; print_error("Syntax error in expression!\n",line);}
        ;

condition:  exp RELOP exp
            | exp '=' exp  
            | error '\n' {yyerrok; print_error("Syntax error in condition!\n",line);}
            ;

%%

void print_error(char *s,int line_number) {
    fprintf(stderr, "Line %d: %s\n",line_number, s);
}
void yyerror(const char *s) {
    fprintf(stderr, "%s\n",s);
}

int main(int argc, char* argv[]) {
    char* file = strdup(argv[1]);
    yyin = fopen(file,"r");
    yyparse();
    return 0;
}