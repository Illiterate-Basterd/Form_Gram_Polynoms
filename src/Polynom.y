%{
 	#include <stdio.h>
 	#include <stdlib.h>
 	#include <string.h>
 	#define ARRAY_SIZE 100
  	#define VAR_NUM 100
	void ErrorFunc(char * err_msg);
	void yyerror();
    extern int yylex();
  	char cur_var = 0;
  	typedef struct polynom Polynom;
  	Polynom* vars[VAR_NUM];
  	int var_count = 0;	
  	
%}

%code requires 
{
  	#define ARRAY_SIZE 100
  	#define VAR_NUM 100
	typedef struct polynom
  	{
		int coefs_[ARRAY_SIZE];
		char var_name_;	
  	}Polynom;
  	Polynom DegreePolynoms(Polynom pol, int num);
  	Polynom MulPolynoms(Polynom first, Polynom second);
	Polynom DivPolynoms(Polynom first, Polynom second);
  	Polynom SubPolynoms(Polynom first, Polynom second);
  	Polynom AddPolynoms(Polynom first, Polynom second);
  	Polynom InvertPolynom(Polynom pol);
  	Polynom GetPolynom(char c);
  	Polynom CreateNumberPolynom(int num);
  	Polynom CreateVarPolynom(char c);
  	void AssignPol(char var_name, Polynom pol);
  	void PrintPolynom(Polynom pol);

}

%union //содержит все возможные типы значений токенов
{
	Polynom pol;
	int num;
	char c;
}

%locations

%token print polynomial var number
%type <c> polynomial var
%type <num> number  
%type <pol> POL SINGLE_POL

%left '-' '+'
%left '*' '/'
%left '^'
%left UMIN

%start START

%%

START: 
     | EXPR ';' 
     | START EXPR ';'

EXPR: RES 
	| DECL
	| RES error { ErrorFunc("Error after printing the result!"); }
	| DECL error { ErrorFunc("Error after variable declaration!"); }
	| error { ErrorFunc("The program must include a declaration or printing a polynomial using the '$' symbol!"); }

DECL: var '=' POL	{ AssignPol($1, $3); }

POL: SINGLE_POL 
	| '(' POL ')' { $$ = $2; }
	| POL '+' POL { $$ = AddPolynoms($1, $3); }
	| POL '-' POL { $$ = SubPolynoms($1, $3); }
	| POL '*' POL { $$ = MulPolynoms($1, $3); }
	| POL POL %prec '*' { $$ = MulPolynoms($1, $2); }
	| POL '/' POL { $$ = DivPolynoms($1, $3); }
	| POL '^' number { $$ = DegreePolynoms($1, $3); }
	| '-' POL %prec UMIN { $$ = InvertPolynom($2); }
	| POL '^' error	{ ErrorFunc("Please use a number as a degree!"); }
	| POL '+' error { ErrorFunc("You can add only polynomials!"); }
	| POL '-' error { ErrorFunc("You can subtract only polynomials!"); }
	| POL '*' error { ErrorFunc("Only polynomials can be multiplied!"); }
	| '(' error POL ')'	{ ErrorFunc("Invalid operation before polynom!"); }
	| POL error { ErrorFunc("Invalid operation after polynom!"); }

SINGLE_POL: number { $$ = CreateNumberPolynom($1); }
	| polynomial { $$ = CreateVarPolynom($1); }
	| var { $$ = GetPolynom($1); }

RES: print POL { PrintPolynom($2); }
	| print error { ErrorFunc("You can only print a polynomial!"); }

%%

Polynom DegreePolynoms(Polynom pol, int num)
{
	Polynom* res = (Polynom*)calloc(1, sizeof(Polynom));
	memcpy(res->coefs_, pol.coefs_, ARRAY_SIZE * sizeof(int));
	for (int i = 1; i < num; i++)
		*res = MulPolynoms(*res, pol);
	return *res;
}

Polynom MulPolynoms(Polynom first, Polynom second)
{
	Polynom* pol = (Polynom*)calloc(1, sizeof(Polynom));
	for (int i = 0; i < ARRAY_SIZE; i++)
		if(first.coefs_[i] != 0)
		for (int j = 0; j < ARRAY_SIZE; j++)
			if(second.coefs_[j] != 0)
				pol->coefs_[i + j] += first.coefs_[i] * second.coefs_[j];
	return *pol;
}

Polynom DivPolynoms(Polynom first, Polynom second)
{
	int zero_fl = 0;
	Polynom* pol = (Polynom*)calloc(1, sizeof(Polynom));
	for (int i = 0; i < ARRAY_SIZE; i++)
	{
		if(first.coefs_[i] != 0)
		{
			for (int j = 0; j < ARRAY_SIZE; j++)
			{
				if(second.coefs_[j] != 0)
				{
					zero_fl = 1;
					pol->coefs_[i + j] += first.coefs_[i] / second.coefs_[j];
				}
			}
		}
	}

	if(!zero_fl)
		ErrorFunc("Cannot divide by zero!");

	return *pol;
}

Polynom SubPolynoms(Polynom first, Polynom second)
{
	for (int i = 0; i < ARRAY_SIZE; i++)
		first.coefs_[i] -= second.coefs_[i];
	return first;
}

Polynom AddPolynoms(Polynom first, Polynom second)
{
	for (int i = 0; i < ARRAY_SIZE; i++)
		first.coefs_[i] += second.coefs_[i];
	return first;
}

Polynom InvertPolynom(Polynom pol)
{
	for (int i = 0; i < ARRAY_SIZE; i++)
		pol.coefs_[i] *= -1;
	return pol;
}

Polynom GetPolynom(char c)
{
	for (int i = 0; i < var_count; i++)
		if (vars[i]->var_name_ == c)
			return *vars[i];
	printf("No definition of variable %c!\n", c);
	exit(-1);
}

Polynom CreateNumberPolynom(int num)
{
	Polynom* pol = (Polynom*)calloc(1, sizeof(Polynom));
	pol->coefs_[0] = num;
	return* pol;
}

Polynom CreateVarPolynom(char c)
{
	if (!cur_var)
		cur_var = c;
	else if (cur_var != c)
		ErrorFunc("You cannot use more than 1 variable!");
	Polynom* pol = (Polynom*)calloc(1, sizeof(Polynom));
	pol->coefs_[1] = 1;
	return *pol;
}

void AssignPol(char var_name, Polynom pol)
{
	if(var_count == VAR_NUM) ErrorFunc("The maximum number of variables has been reached!");
	int i = 0;
	for(; i < var_count; i++)
	{
		if (vars[i]->var_name_ == var_name)
			break;
	}
	if (i == var_count)
	{
		vars[i] = (Polynom*)calloc(1, sizeof(Polynom));
		var_count++;
		vars[i]->var_name_ = var_name;
	}
	for(int k = 0; k < ARRAY_SIZE; k++)
		vars[i]->coefs_[k] = pol.coefs_[k];
}

void PrintPolynom(Polynom pol)
{
	int zero_fl = 0;
	int first = 1;
	printf("Result: ");

	for (int i = ARRAY_SIZE - 1; i >= 1; i--)
    {
        if (i != 1)
        {
            if(pol.coefs_[i] > 1)
			{
				if(!first)
					printf("+");
				first = 0;
                printf("%d%c^%d", pol.coefs_[i], cur_var, i);
				zero_fl = 1;
			}
            else if(pol.coefs_[i] < -1)
			{
				if(!first)
					printf("+");
				first = 0;
                printf("(%d%c^%d)", pol.coefs_[i], cur_var, i);
				zero_fl = 1;
			}
            else if(pol.coefs_[i] == 1)
			{
				if(!first)
					printf("+");
				first = 0;
                printf("%c^%d", cur_var, i);
				zero_fl = 1;
			}
            else if(pol.coefs_[i] == -1)
			{
				if(!first)
					printf("+");
				first = 0;
                printf("(-%c^%d)", cur_var, i);
				zero_fl = 1;
			}
        }

        else
        {
            if(pol.coefs_[i] > 1)
			{
				if(!first)
					printf("+");
				first = 0;
                printf("%d%c", pol.coefs_[i], cur_var);
				zero_fl = 1;
			}
            else if(pol.coefs_[i] < -1)
			{
				if(!first)
					printf("+");
				first = 0;
                printf("(%d%c)", pol.coefs_[i], cur_var);
				zero_fl = 1;
			}
            else if(pol.coefs_[i] == 1)
			{
				if(!first)
					printf("+");
				first = 0;
                printf("%c", cur_var);
				zero_fl = 1;
			}
            else if(pol.coefs_[i] == -1)
			{
				if(!first)
					printf("+");
				first = 0;
                printf("(-%c)", cur_var);
				zero_fl = 1;
			}
        }
    }
	if(pol.coefs_[0] > 0)
		printf("%d\n", pol.coefs_[0]);
	else if(pol.coefs_[0] < 0)
        printf("(%d)\n", pol.coefs_[0]);
	else if(pol.coefs_[0] == 0)
	{
		if(zero_fl)
        	printf(" \n");
		else
			printf("%d\n", pol.coefs_[0]);
	}
}

void ErrorFunc(char* err_msg)
{
	printf ("%s\n", err_msg);
	exit(-1);
}

void yyerror()
{
	fprintf (stderr, "Error %d.%d: ", yylloc.first_line,
             yylloc.first_column);
}
