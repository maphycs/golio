%{
open Types
%}

%token LPAREN RPAREN QUOTE DOT EOF
%token <int> NUMBER
%token <string> SYMBOL
%token <string> STRING
%token <bool> BOOL
%start parse
%type< Types.sexp option> parse
%%

parse:
  | EOF { None }
  | expr { Some $1 }
;

exprs:
  | expr exprs { $1 :: $2 }
  | expr { [$1] }
;

expr:
  | NUMBER { Number $1 }
  | SYMBOL { Symbol $1 }
  | STRING { String $1 }
  | BOOL { Bool $1 }
  | LPAREN exprs RPAREN { List $2 }
  | LPAREN exprs DOT expr RPAREN { DottedList ($2, $4) }
  | LPAREN RPAREN { List [] }
  | QUOTE expr { List [Symbol "quote" ; $2] }
;