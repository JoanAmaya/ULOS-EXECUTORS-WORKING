grammar stepsDefinitions;

file:
    imports* stepFunction* EOF;

stepFunction:
    givenWhenThen LPAREN PHRASE COMMA ASYNC FUNCTION LPAREN params* RPAREN LBRACE bodyFunction RBRACE RPAREN SEMICOLON?;

bodyFunction:
    (variableDeclaration | pageObjectMethod)*;

variableDeclaration:
((CONST | LET | VAR)? (PAGEOBJECT | VARIABLE) EQUAL NEW (PAGEOBJECT | VARIABLE) LPAREN params? RPAREN SEMICOLON?)
| ((CONST | LET | VAR)? (PAGEOBJECT | VARIABLE) EQUAL (NUMBER | PHRASE ) SEMICOLON?) | (CONST | LET | VAR)? (PAGEOBJECT | VARIABLE) EQUAL pageObjectMethod SEMICOLON?
| ((CONST | LET | VAR)? (PAGEOBJECT | VARIABLE) EQUAL AWAIT? variableMethods SEMICOLON?);

pageObjectMethod:
    AWAIT? PAGEOBJECT DOT VARIABLE LPAREN params? RPAREN SEMICOLON?;

variableMethods:
    VARIABLE (DOT VARIABLE)* (LPAREN params* RPAREN)? (LBRA (VARIABLE | PHRASE | NUMBER) RBRA)?;

params:
    param (COMMA param)*;
param:
    VARIABLE (DOT VARIABLE)* functionCall?;

functionCall:
    LPAREN paramList? RPAREN;

paramList:
    params;

imports:
IMPORT ((LBRACE (VARIABLE|givenWhenThen ) ( COMMA (VARIABLE|givenWhenThen ))* RBRACE) | ((VARIABLE|givenWhenThen ))) FROM IMPORT_PATH SEMICOLON?;


// Tokens for keywords

givenWhenThen:
    GIVEN | WHEN | THEN;
IMPORT:
    'import';
FROM:
    'from';
GIVEN:
    'Given';
WHEN:
    'When';
THEN:
    'Then';
ASYNC:
    'async';
FUNCTION:
    'function';
AWAIT:
    'await';
CONST:
    'const';
LET:
    'let';
VAR:
    'var';
NEW:
    'new';
PAGEOBJECT:
     [a-z] [a-zA-Z0-9]* 'Page';
VARIABLE:
    [A-Za-z_$][A-Za-z0-9_$]*;


// Tokens for symbols and literals

LPAREN:
    '(';
RPAREN:
    ')';
DOT:
    '.';
MARK:
    '"' | '\'';
SEMICOLON:
    ';';
COMMA:
    ',';    
LBRACE:
    '{';
RBRACE:
    '}';
LBRA:
    '[';
RBRA:
    ']';
EQUAL:
    '=';
NUMBER:
    [0-9]+;
IMPORT_PATH: 
    '\'' [A-Za-z0-9_/@.\-]+ '\''
    |'"' [A-Za-z0-9_/@.\-]+ '"';
PHRASE:
	'"' (~["\\] | '\\' .)* '"'	
	| '\'' (~['\\] | '\\' .)* '\'';
WORD: '"' (~["\\ \t\r\n] | '\\' .)+ '"'	
    | '\'' (~['\\ \t\r\n] | '\\' .)+ '\'';
		
NEWLINE : '\r'? '\n' -> skip ;
WHITESPACE : [ \t]+ -> skip ;