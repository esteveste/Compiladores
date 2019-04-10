%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "node.h"
#include "tabid.h"
extern int yylex();
int yyerror(char *s);

int yydebug = 1;
%}
%union {
	int i;			/* integer value */
	double r;		/* real value */
	char *s;		/* symbol name or string literal */
    Node *n;        /* tree node */
};
%token <i> INT
%token <r> REAL
%token <s> ID STR
%token DO WHILE IF THEN FOR IN UPTO DOWNTO STEP BREAK CONTINUE
%token VOID INTEGER STRING NUMBER CONST PUBLIC 

%nonassoc SIMPLE_IF
%nonassoc ELSE 



%right ATR
%left '&' '|'
%nonassoc '~'
%left '=' NE

%left '<' '>' GE LE
%left '+' '-'

%left '*' '/' '%'


%nonassoc INCR DECR ADDR UMINUS '!'
%nonassoc '[' '('

%type<n> decls decl decl_const decl_param tipo init body instrucao algo_to op_step left_value parametro

%token NIL DECL_PARAM

%%
file: decls {printNode($1,0,yynames);}
    ;

decls: decls decl   {$$ = binNode(decls,$1,$2);}
     |              {$$ = nilNode(NIL)}
     ;


decl: PUBLIC decl_const {$$ = uniNode(PUBLIC,$2);}
    | decl_const        {$$ = $1;}
    ;

decl_const: CONST decl_param    {$$ = uniNode(CONST,$2);}
          | decl_param         
          ;

decl_param: parametro ';'       {$$ = binNode(DECL_PARAM,$1,nilNode(NIL));}
          | parametro init ';'  {$$ = binNode(DECL_PARAM,$1,$2);}
          ;


tipo: NUMBER 
    | STRING
    | INTEGER
    | VOID
    ;

init: ATR INT
    | ATR '-' INT
    | ATR CONST STR
    | ATR STR
    | ATR REAL
    | ATR '-' REAL
    | ATR ID
    | '(' ')' op_body
    | '(' parametros ')' op_body
    ;

op_body:
       | body
       ;

body:'{' body_param body_inst '}'
    ;

body_param: body_param parametro ';' 
          |
          ;

body_inst: body_inst instrucao 
         |
         ;


instrucao: BREAK ';'
         | BREAK INTEGER ';'
         | CONTINUE ';'
         | CONTINUE INTEGER ';'
         | body
         | expressao ';'
         | IF expressao THEN instrucao %prec SIMPLE_IF
         | IF expressao THEN instrucao ELSE instrucao
         | DO instrucao WHILE expressao ';'
         | left_value '#' expressao ';'
         | FOR left_value IN expressao algo_to expressao op_step DO instrucao
         ;

algo_to: UPTO
       | DOWNTO
       ;

op_step: 
       | STEP expressao
       ;

expressao: left_value
         | INT  {$$ = intNode(INT,$1);}
         | REAL {$$ = realNode(REAL,$1);}
         | STR  {$$ = strNode(STR,$1);}

         | '(' expressao ')'

         | expressao '(' f_args ')'
         | expressao '(' ')'
         
         | '-' expressao %prec UMINUS
         | '!' expressao
         | '&' left_value %prec ADDR
         | INCR left_value
         | DECR left_value
         | left_value INCR
         | left_value DECR
         
         | expressao '*' expressao
         | expressao '/' expressao
         | expressao '%' expressao
         | expressao '+' expressao
         | expressao '-' expressao
         
         | expressao '<' expressao
         | expressao '>' expressao
         | expressao NE expressao
         | expressao '=' expressao
         | expressao GE expressao
         | expressao LE expressao
         
         | '~' expressao
         | expressao '&' expressao
         | expressao '|' expressao
         
         | left_value ATR expressao 
         ;

f_args: f_args ',' expressao
      | expressao
      ;

left_value: ID
          | '*' left_value
          | left_value '[' expressao ']'
          ;

parametros: parametros ',' parametro
          | parametro
          ;


parametro: tipo ID
         | tipo '*' ID
         ;



%%
char **yynames =
#if YYDEBUG > 0
         (char**)yyname;
#else
         0;
#endif
int yyerror(char *s) { printf("%s\n", s); return 0; }
int main() { return yyparse(); }
/*
int yyerror(char *s) { printf("%s\n",s); return 1; }
char *dupstr(const char*s) { return strdup(s); }

/*
int main(int argc, char *argv[]) {
 extern YYSTYPE yylval;
 int tk;
 while ((tk = yylex())) 
  if (tk > YYERRCODE)
   printf("%d:\t%s\n", tk, yyname[tk]);
  else
   printf("%d:\t%c\n", tk, tk);
 return 0;
}*/
