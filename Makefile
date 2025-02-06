all:
	flex lex.l
	bison -d sintaxe.y 
	g++ *.c -o compiladorjm
