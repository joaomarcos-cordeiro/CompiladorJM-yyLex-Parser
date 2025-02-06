%{
#include "nodes.h"

int yyerror(const char *s);
int yylex(void);                          //função do arquivo (.yy.c) que é definida como o analisador lexico, permite agora a geracão dos tokens para o parser reconhecer.    
int errorcount = 0;
extern bool force_print_tree;
%}
                                      
%define parse.error verbose


%union {
    char *str;
    int itg;
    double flt;
    Node *node;
}

%token TOK_IDENT TOK_FLOAT TOK_INT

%token TOK_PRINT TOK_IF TOK_ELSE       TOK_WHILE        TOK_OR TOK_AND 

%token TOK_TRUE TOK_FALSE

%type<str> TOK_IDENT
%type<itg> TOK_INT
%type<flt> TOK_FLOAT
%token TOK_EQUAL TOK_MINOREQUAL  TOK_GREATEREQUAL TOK_GREATER TOK_LESS

%token TOK_POWER

%type<node> generals general expr term factor unary logico logicofactor  if_stmt

%start program

%%
								// analise sintatica(parser) acontece no arquivo.(y) 
program : generals {
    Node *program = new Program();
    program->append($generals);
    
    // parser (analise sintatica) gera a arvore sintatica abstrata
    
    //  a seguir criacao da arvore sintatica abstrata(AST), a analise semantica ocorre depois da AST , ao final ha a verificacao de erros e a formulacao do codigo intermediario em assembly para ser feito o passo final (.exe)

    
    CheckVarDecl cvd;
    cvd.check(program);

    if (errorcount > 0)
        cout << errorcount << " error(s) found." << endl;
    if (errorcount == 0 || force_print_tree) 
        printf_tree(program);


      //  analise semantica concluida

}


generals : generals[gg] general {
    $gg->append($general);
    $$ = $gg;
}

| general {
    Node *n = new Node();
    n->append($general);
    $$ = n;
}


general : TOK_IDENT '=' expr ';' {
	$$ = new Variable($TOK_IDENT, $expr);
} 

| TOK_PRINT TOK_IDENT ';' {
	Ident *id = new Ident($TOK_IDENT);
	$$ = new Print(id);
}


|TOK_WHILE '(' logico ')' '{' generals '}'{ 
    $$ = new While($logico, $generals);   
}

| error ';' { $$ = new Node(); }
| error  { $$ = new Node(); }


| if_stmt  {  
$$ = $if_stmt;
}




expr : expr[ee] '+' term {

	$$ = new BinaryOp($ee, $term, '+');
}

| expr[ee] '-' term {
	$$ = new BinaryOp($ee, $term, '-');
}


| term {
	$$ = $term;
}


term : term[tt] '*' factor {
	$$ = new BinaryOp($tt, $factor, '*');
}

| term[tt] '/' factor {
	$$ = new BinaryOp($tt, $factor, '/');
}

| term[tt] TOK_POWER factor {
	 $$ = new BinaryOpPower($1, $3, '^');

}

|factor {
	$$ = $factor;
}





factor : '(' expr ')' {
	$$ = $expr;
}
| TOK_IDENT[str] {
	$$ = new Ident($str);
}

| TOK_INT[itg] {
	$$ = new Integer($itg);
}

| TOK_FLOAT[flt] {
	$$ = new Float($flt);
}

| TOK_TRUE{
    $$ = new PositivoNegativo(true);
}

| TOK_FALSE{
    $$ = new PositivoNegativo(false);
}





| unary[u] {
	$$ = $u;
}

unary : '-' factor[f] {
	$$ = new Unary($f, '-');
}


logico : logico[l] TOK_OR logicofactor {
    $$ = new BinaryOp($l, $logicofactor, '|');
}

| logico[l] TOK_AND logicofactor {
    $$ = new BinaryOp($l, $logicofactor, '&');
}
     
| logicofactor{
  $$ = $logicofactor;

}


logicofactor : '('logico[l]')'{
    $$ = $l; 
}

| expr[ee] TOK_EQUAL expr[e2] {
    $$ = new BinaryOpCompare($ee, $e2, "==");
}

| expr[ee] TOK_MINOREQUAL expr[e2] {
    $$ = new BinaryOpCompare($ee, $e2, "<=");
}

| expr[ee] TOK_GREATEREQUAL expr[e2] {
    $$ = new BinaryOpCompare($ee, $e2, ">=");
}

| expr[ee] TOK_GREATER expr[e2] {
    $$ = new BinaryOpCompare($ee, $e2, ">");
}

| expr[ee] TOK_LESS expr[e2] {
    $$ = new BinaryOpCompare($ee, $e2, "<");
}

| factor{
$$=$factor;
}






if_stmt : TOK_IF logico '{' generals '}' { $$ = new Sempreq($logico, $generals);}

|TOK_IF logico '{' generals[ge1] '}' TOK_ELSE '{' generals[ge2] '}'{ $$ = new SempreqQuandon($logico, $ge1, $ge2);}

|TOK_IF logico '{' generals[ge1] '}' TOK_ELSE   if_stmt [ifs] { $$ = new SempreqQuandonLoop($logico, $ge1, $ifs); }




%%





