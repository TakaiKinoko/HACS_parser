// Fang Han
//
// Compiler Construction Spring 2019 Project Milestone 1
//

module org.crsx.hacs.samples.Pr1FangHan {

/* LEXICAL ANALYSIS */

  // 1.1 Definition(tokens)
  space [ \t\n\r] | '//' [^\n]* | '/*' ( '/' [^*] | [^*] | '*' [^/] )* '*/'  ; // no nested comments

  token Start           | "function int main" ;
  token Func            | "function" ;
  token ID  | ⟨LetterEtc⟩ (⟨LetterEtc⟩ | ⟨Digit⟩)* ;
  token INT	| ⟨Digit⟩+ ;
  token STR | "\"" ( [^\"\\\n] | \\ ⟨Escape⟩ )* "\"";

  token fragment Letter     | [A-Za-z] ;
  token fragment LetterEtc  | ⟨Letter⟩ | [$_] ;
  token fragment Digit      | [0-9] ;
  token fragment Escape  | [\n\\nt"] | "x" ⟨Hex⟩ ⟨Hex⟩ | ⟨Octal⟩;
  token fragment Hex     | [0-9A-Fa-f] ;
  token fragment Octal   | [0-7] | [0-7][0-7] | [0-7][0-7][0-7];

/* SYNTAX ANALYSIS */
   
  // 1.2 Definition(Expressions)
  sort Exp

    |  sugar ⟦ ( ⟨Exp#e⟩ ) ⟧@10 → #e

    |  ⟦ ⟨INT⟩ ⟧@10
    |  ⟦ ⟨STR⟩ ⟧@10
    |  ⟦ ⟨ID⟩ ⟧@10

    |  ⟦ ⟨Exp@9⟩ ( ⟨ExpList⟩ ) ⟧@9
    |  ⟦ null ( ⟨Type⟩ ) ⟧@9
    |  ⟦ sizeof ( ⟨Type⟩ )⟧@9

    |  ⟦ ! ⟨Exp@8⟩ ⟧@8
    |  ⟦ - ⟨Exp@8⟩ ⟧@8
    |  ⟦ + ⟨Exp@8⟩ ⟧@8
    |  ⟦ * ⟨Exp@8⟩ ⟧@8
    |  ⟦ & ⟨Exp@8⟩ ⟧@8

    |  ⟦ ⟨Exp@7⟩ * ⟨Exp@8⟩ ⟧@7

    |  ⟦ ⟨Exp@6⟩ + ⟨Exp@7⟩ ⟧@6
    |  ⟦ ⟨Exp@6⟩ - ⟨Exp@7⟩ ⟧@6

    |  ⟦ ⟨Exp@6⟩ < ⟨Exp@6⟩ ⟧@5 
    |  ⟦ ⟨Exp@6⟩ > ⟨Exp@6⟩ ⟧@5
    |  ⟦ ⟨Exp@6⟩ <= ⟨Exp@6⟩ ⟧@5
    |  ⟦ ⟨Exp@6⟩ >= ⟨Exp@6⟩ ⟧@5

    |  ⟦ ⟨Exp@5⟩ == ⟨Exp@5⟩ ⟧@4
    |  ⟦ ⟨Exp@5⟩ != ⟨Exp@5⟩ ⟧@4  

    |  ⟦ ⟨Exp@3⟩ && ⟨Exp@4⟩ ⟧@3 // associate right to left

    |  ⟦ ⟨Exp@2⟩ || ⟨Exp@3⟩ ⟧@2 // associate right to left
    ;

  sort ExpList | ⟦ ⟨Exp⟩ ⟨ExpListTail⟩ ⟧  |  ⟦⟧ ;
  sort ExpListTail | ⟦ , ⟨Exp⟩ ⟨ExpListTail⟩ ⟧  |  ⟦⟧ ;

  // 1.3 Definition(Types)
  sort Type    // precedence added according to 1.3 "type forms are listed in descending precedence order."
    |  ⟦ int ⟧@3
    |  ⟦ char ⟧@3
    |  ⟦ ( ⟨Type⟩ )⟧@3
    |  ⟦ ⟨Type@2⟩ ( ⟨TypeList⟩ )⟧@2 
    |  ⟦ * ⟨Type@1⟩ ⟧@1
    ;

  sort TypeList | ⟦ ⟨Type⟩ ⟨TypeListTail⟩ ⟧ | ⟦⟧;
  sort TypeListTail | ⟦ , ⟨Type⟩ ⟨TypeListTail⟩ ⟧ | ⟦⟧;
  
  // 1.4 Definition(Statements)
  sort Stmts | ⟦ ⟨Stmt⟩ ⟨Stmts⟩ ⟧ | ⟦⟧ ;

  sort Stmt
    |  ⟦ { ⟨Stmts⟩ } ⟧
    |  ⟦ var ⟨Type⟩ ⟨ID⟩ ; ⟧
    |  ⟦ ⟨ID⟩ = ⟨Exp⟩ ; ⟧           // added rule -- left hand side of (=) has to be lvalue
    |  ⟦ * ⟨Exp⟩ = ⟨Exp⟩ ; ⟧        // added rule -- left hand side of (=) has to be lvalue
    |  ⟦ if ( ⟨Exp⟩ ) ⟨IfTail⟩ ⟧
    |  ⟦ while ( ⟨Exp⟩ ) ⟨Stmt⟩ ⟧
    |  ⟦ return ⟨Exp⟩ ; ⟧
    ;

  sort IfTail | ⟦ ⟨Stmt⟩ else ⟨Stmt⟩ ⟧ | ⟦ ⟨Stmt⟩ ⟧ ;   // solution to dangling else
  
  // 1.5 Definition(Declaration)
  sort Decls 
    | ⟦ ⟨Decl⟩ ⟨Decls⟩ ⟧ 
    | ⟦⟧ 
    ;

  sort Decl
    |  ⟦ ⟨Func⟩ ⟨Type⟩ ⟨ID⟩ ⟨ParamList⟩ { ⟨Stmts⟩ } ⟧   
    ;

  sort Main 
    |  ⟦ ⟨Start⟩ ⟨ParamList⟩ { ⟨Stmts⟩ } ⟧
    ;
  
  sort ParamList    // to make zero or more comma-separated formal parameters. 
    |  ⟦ ( ) ⟧
    |  ⟦ ( ⟨Type⟩ ⟨ID⟩ ⟨TypeIDTail⟩ ) ⟧
    ;
  sort TypeIDTail |  ⟦ , ⟨Type⟩ ⟨ID⟩ ⟨TypeIDTail⟩ ⟧  |  ⟦ ⟧ ;

  // 1.6 Definition(Program)
  main sort Program  
    |  ⟦ ⟨Decls⟩ ⟨Main⟩ ⟨Decls⟩ ⟧ 
    ;
}