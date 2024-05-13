%{

    #include <stdio.h>
    #include "y.tab.h"
    static int str_num = 1;
    static int pos_in_str = 1;

    #define YY_USER_ACTION { \
        yylloc.first_line   = str_num; \
        yylloc.last_line    = str_num; \
        yylloc.first_column = pos_in_str; \
        yylloc.last_column  = pos_in_str + yyleng - 1; \
        pos_in_str += yyleng; }
    
%}

%option nounput
%option noinput
%option noyywrap

POLYNOMIAL [a-z]
VAR [A-Z]
NUMBER [0-9]+
IGN_SYM [ \t\r]+
OPERATIONS [+|-|*|/|^|(|)|=]

%%

{POLYNOMIAL}		{ yylval.c = *yytext; return polynomial; }

{VAR}			    { yylval.c = *yytext; return var; }

{NUMBER}		    { yylval.num = atoi(yytext); return number; }

{OPERATIONS}	   	return *yytext;

";"			        return *yytext;

"$"			        return print;

"\n"			    { pos_in_str = 1; str_num++;}

{IGN_SYM}           ;

.                   return *yytext;

%%
