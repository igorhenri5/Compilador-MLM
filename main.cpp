#include <stdio.h>

int yyparse();

int main(int argc, char **argv){

    if ((argc != 1 || freopen(argv[1], "r", stdin) == NULL))
        return 1;

    yyparse();

	return 0;
}
