grammar Gherkin;
//Parser rules
file:
    featureBlock backgroundBlock?  (ordersBlocks)+ EOF;
featureBlock:
    FEATURE DDOTS (WORD)+;
tag:
    TAG+;
ordersBlocks:
    (scenariosBlock)+;
scenariosBlock:
    tag? (normalScenarioBlock | outlineScenarioBlock);
normalScenarioBlock:
    SCENARIO DDOTS (WORD)+ (contentBlock)+;
outlineScenarioBlock:
    SCENARIO OUTLINE DDOTS (WORD)+ (contentBlock)+ examplesBlock?;
examplesBlock:
    EXAMPLES DDOTS UWORD+;
backgroundBlock:
    BACKGROUND DDOTS (contentBlock)+;
contentBlock:
    (givenWhenThen (WORD) (WORD | STRING)*)+ (givenWhenThenAndBut (WORD) (WORD | STRING)*)*;
givenWhenThen:
    GIVEN | WHEN | THEN;
givenWhenThenAndBut:
    GIVEN | WHEN | THEN | AND | BUT;

//Lexer rules

FEATURE:
    'Feature';
GIVEN:
    'Given';
WHEN:
    'When';
DDOTS:
    ':';
THEN:
    'Then';
AND:
    'And';
BUT:
    'But';
SCENARIO:
    'Scenario';
OUTLINE:
    'Outline';
BACKGROUND:
    'Background';
EXAMPLES:
    'Examples';
    
TAG: 
    '@'[A-Za-z0-9._-]+;
WORD: 
    ~["\t\r\n :]+;
STRING:
    '"' ~["\r\n]* '"';
UWORD: 
   '|' ~["'\r\n]* '|';
NEWLINE : '\r'? '\n' -> skip ;

WHITESPACE : [ \t]+ -> skip ;
