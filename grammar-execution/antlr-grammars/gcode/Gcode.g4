grammar Gcode;

file : line+ EOF ;

line : command (parameter)* COMMENT? NEWLINE? ;

command : GCODE | MCODE | TCODE | FCODE | SCODE;

parameter : AXIS NUMBER | LETTER NUMBER ; 

COMMENT : ';' ~[\r\n]* -> skip ;

GCODE : 'G' DIGIT+ ;
MCODE : 'M' DIGIT+ ;
TCODE : 'T' DIGIT+ ;
FCODE : 'F' DIGIT+ ;
SCODE : 'S' DIGIT+ ;



AXIS: [XYZE] ;
LETTER : [A-DF-IK-NP-RTVUW];

NUMBER : '-'? DIGIT+ ('.' DIGIT+)? ;
DIGIT : [0-9] ;

NEWLINE : '\r'? '\n' -> skip ;
WHITESPACE : [ \t]+ -> skip ;


