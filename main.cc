/* main.cc */

#include "heading.h"
extern "C" int yyparse (void);
// prototype of bison-generated parser function
int yyparse();

int main(int argc, char **argv)
{
  	printf("\n1");

  if ((argc > 1) && (freopen(argv[1], "r", stdin) == NULL))
  {
  	printf("\n2");
    //cou << argv[0] << ": File " << argv[1] << " cannot be opened.\n";
    exit( 1 );
  }
  
  printf("\n3");
  yyparse();
  printf("\n4");
  return 0;
}
