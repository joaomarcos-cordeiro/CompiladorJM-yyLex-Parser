%{
#include <stdio.h>
#include <stdlib.h>



char *build_file_name;               // nome do programa que será compilado
bool force_print_tree = false;
class Node;
#include "sintaxe.tab.h"

int yyerror(const char *s);

	//  arquivo.l responsável por fazer a declaração dos tokens. A partir da criação do (.l) ao colocar o comando Flex irá gerar o analisador lexico em um arquivo (.yy.c) 
  // dentro desse arquivo estará a  função yylex que é o analisador lexico. 
	// posteriormente a função yylex será utilizada no .y para gerar os tokens para o parser(analisador sintático) para que ele possa identificar os respectivos tokens 


%}
%option yylineno

%%
[ \t\r\n] { }
"//".*\n { /*Comentário*/ }

"olhar" { return TOK_PRINT; }
"sempreq" { return TOK_IF; }
"quandon" { return TOK_ELSE; }
"tempoq" { return TOK_WHILE; }

"V" { return TOK_OR; }
"EE" { return TOK_AND; }

"=="  { return TOK_EQUAL; }
"<=" { return TOK_MINOREQUAL; }
">=" { return TOK_GREATEREQUAL; }
">" { return TOK_GREATER; }
"<" { return TOK_LESS; }

"^" { return TOK_POWER; }

"+"                 { return '+'; }
"-"                 { return '-'; }
"*"                 { return '*'; }
"/"                 { return '/'; }
"("                 { return '('; }
")"                 { return ')'; }
";"                 { return ';'; }
"="                 { return '='; }
"{" { return '{'; }
"}" { return '}'; } 
     

"positivo" { return TOK_TRUE; }
"negativo" { return TOK_FALSE; }

    	

[a-zA-Z_][a-zA-Z0-9_]* {
  yylval.str = strndup(yytext, yyleng);
  return TOK_IDENT;
}

[0-9]+\.[0-9]* {
  yylval.flt = atof(yytext);
  return TOK_FLOAT;
}

[0-9]+ {
  yylval.itg = atoi(yytext);
  return TOK_INT;
}
					 


. {
     printf("Símbolo não reconhecido %c\n", yytext[0]); 
  }


%%


int yywrap () {
 return 1;
 
}

extern int errorcount;


int yyerror(const char *s){
    printf("%s:%d:0: %s\n",
        build_file_name, yylineno, s);
    errorcount++;
    return 1;
}






int main (int argc, char *argv[]) {


 if(argc <= 1){
        printf("Sintaxe: %s nome_do_programa\n",argv[0]);
        return 1;
    }
        
 int build_file_id=1;
 
 if(strcmp(argv[1], "-f") == 0){
        force_print_tree = true;
        build_file_id++;
    }

build_file_name = argv[build_file_id];

    yyin = fopen(build_file_name, "r");

    if(yyin == NULL){
        printf("Não foi possivel abrir o arquivo %s.\n",build_file_name);
        return 1;
    }
    
    yyparse();

    if(yyin){
        fclose(yyin);
        }
        
        

    return 0;
}

