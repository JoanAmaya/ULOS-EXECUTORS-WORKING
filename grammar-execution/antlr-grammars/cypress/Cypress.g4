grammar Cypress;

file:
	statement* EOF;

statement:
	describeBlock
	| lifecycleHook;

describeBlock:
	DESCRIBE LPAREN STRING COMMA arrowFunction RPAREN SEMICOLON?;

arrowFunction:
	LPAREN (SIGIL IDENTIFIER)? RPAREN ARROW LBRACE testBlock RBRACE;
// Allow both hooks and tests inside arrowFunction

testBlock: (lifecycleHook | itBlock | testStep)*; // Allow both hooks and tests in describe

itBlock:
	IT LPAREN STRING COMMA arrowFunction RPAREN SEMICOLON?;

lifecycleHook: (BEFORE | BEFORE_EACH | AFTER | AFTER_EACH) LPAREN arrowFunction RPAREN SEMICOLON?;

testStep:
	CY cyCommand+ SEMICOLON?;

cyCommand:
	visitCommand
	| getCommand
	| clickCommand
	| typeCommand
	| shouldCommand
	| containsCommand
	| screenshotCommand
	| scrollToCommand
	| genericCommand;

visitCommand:
	DOT VISIT LPAREN visitArgument RPAREN;
visitArgument:
	URL
	| optionArg
	| URL COMMA optionArg;

getCommand:
	DOT GET LPAREN STRING (COMMA optionArg)? RPAREN; // TODO: Match string with CSS Selector

screenshotCommand:
	DOT SCREENSHOT LPAREN screenshotArgument? RPAREN;
screenshotArgument:
	(PATH | STRING) (COMMA optionArg)?;
// having just name as param is valid (e.g. screenshot('clicl-on-nav'))

typeCommand:
	DOT TYPE LPAREN typeArgument RPAREN;
typeArgument:
	STRING (COMMA optionArg)?;

// TODO: click should only come after command that yields a DOM element
clickCommand:
	DOT CLICK LPAREN clickArgument? RPAREN;
clickArgument:
	((NUMBER COMMA NUMBER) | STRING) (COMMA? optionArg)?;

shouldCommand:
	DOT SHOULD LPAREN shouldArgument RPAREN;

// param (chainers) | (chainer, value) | (chainer, method, value) | callbackFn
shouldArgument:
	((STRING | URL) (COMMA STRING)? (COMMA STRING)?)
	// things like "be.visible" "have.attr" etc. are being tokenized as URLs, that's why its added as a
	| arrowFunction;

containsCommand:
	DOT CONTAINS LPAREN containsArgument RPAREN;
containsArgument:
	(containsContentParam (COMMA optionArg)?)
	| (STRING COMMA containsContentParam (COMMA optionArg)?);
containsContentParam:
	STRING
	| NUMBER
	| regexLiteral;

scrollToCommand:
	DOT SCROLLTO LPAREN scrollToArgument RPAREN;
scrollToArgument:
	((NUMBER COMMA NUMBER) | STRING) (COMMA? optionArg)?;
commandName:
	'and'
	| 'as'
	| 'blur'
	| 'check'
	| 'children'
	| 'clear'
	| 'clearAllCookies'
	| 'clearAllLocalStorage'
	| 'clearAllSessionStorage'
	| 'clearCookie'
	| 'clearCookies'
	| 'clearLocalStorage'
	| 'clock'
	| 'closest'
	| 'dbclick'
	| 'debug'
	| 'each'
	| 'end'
	| 'eq'
	| 'exec'
	| 'filter'
	| 'find'
	| 'firs'
	| 'fixture'
	| 'focus'
	| 'focused'
	| 'getAllCookies'
	| 'getAllLocalStorage'
	| 'getAllSessionStorage'
	| 'getCookie'
	| 'getCookies'
	| 'go'
	| 'hash'
	| 'hover'
	| 'intercept'
	| 'invoke'
	| 'its'
	| 'last'
	| 'location'
	| 'log'
	| 'mount'
	| 'next'
	| 'nextAll'
	| 'nextUntil'
	| 'not'
	| 'origin'
	| 'parent'
	| 'parents'
	| 'parentsUntil'
	| 'pause'
	| 'prev'
	| 'prevAll'
	| 'prevUntil'
	| 'readFile'
	| 'reload'
	| 'request'
	| 'rightClick'
	| 'root'
	| 'scrollIntoView'
	| 'select'
	| 'selectFile'
	| 'session'
	| 'setCookie'
	| 'shadow'
	| 'siblings'
	| 'spread'
	| 'spy'
	| 'stub'
	| 'submit'
	| 'task'
	| 'then'
	| 'tick'
	| 'title'
	| 'trigger'
	| 'uncheck'
	| 'url'
	| 'viewport'
	| 'wait'
	| 'window'
	| 'within'
	| 'wrap'
	| 'writeFile';
genericCommand:
	DOT commandName LPAREN argumentList? RPAREN;

argumentList:
	argument (COMMA argument)*; // Allow multiple arguments separated by commas

argument:
	STRING
	| NUMBER
	| IDENTIFIER
	| optionArg;

fileName:
	PATH;

dictArgList:
	argument COLON argument (COMMA argument COLON argument)*;

optionArg:
	LBRACE dictArgList RBRACE;

regexLiteral:
	REGEX_LITERAL;

// ! Lexer Keywords

// Regex Related
REGEX_LITERAL:
	'/' REGEX_PATTERN '/' REGEX_FLAGS?;

fragment REGEX_PATTERN: (~[/\\\r\n] | REGEX_ESCAPE_SEQUENCE)+;

fragment REGEX_ESCAPE_SEQUENCE:
	'\\' .; // Matches any escaped character including escaped forward slashes

fragment REGEX_FLAGS:
	[gimsuyd]+; // Standard JavaScript regex flags

IT:
	'it';
DESCRIBE:
	'describe';
BEFORE:
	'before';
BEFORE_EACH:
	'beforeEach';
AFTER:
	'after';
AFTER_EACH:
	'afterEach';

// Cypress commands
CY:
	'cy';
VISIT:
	'visit';
GET:
	'get';
CLICK:
	'click';
TYPE:
	'type';
SHOULD:
	'should';
CONTAINS:
	'contains';
SCREENSHOT:
	'screenshot';
SCROLLTO:
	'scrollTo';

// Literals

PATH:
	'"' ('/'? [a-zA-Z0-9\-]+) ('/' [a-zA-Z0-9\-]+)* '/' (
		[a-zA-Z0-9\-]* ('.' [a-zA-Z0-9\-]+)?
	) '"'
	| '\'' ('/'? [a-zA-Z0-9\-]+) ('/' [a-zA-Z0-9\-]+)* '/' (
		[a-zA-Z0-9\-]* ('.' [a-zA-Z0-9\-]+)?
	) '\'';

URL:
	'"' ('http' 's'? '://')? // Scheme: 'http' or 'https'
	(
		[a-zA-Z0-9\-]+ ('.' [a-zA-Z0-9\-]+)+
	)												// Domain: e.g., 'google.com', 'example.org'
	('/' [a-zA-Z0-9\-._~:/?#[\]@!$&'()*+,;=%]*)*	// Path: any valid URL characters
	(/[a-zA-Z0-9\-._]+ '.html')? '"'
	| '\'' ('http' 's'? '://')? // Scheme: 'http' or 'https'
	(
		[a-zA-Z0-9\-]+ ('.' [a-zA-Z0-9\-]+)+
	)												// Domain: e.g., 'google.com', 'example.org'
	('/' [a-zA-Z0-9\-._~:/?#[\]@!$&'()*+,;=%]*)*	// Path: any valid URL characters
	(/[a-zA-Z0-9\-._]+ '.html')? '\'';

STRING:
	'"' (~["\\] | '\\' .)* '"'		// Double-quoted strings
	| '\'' (~['\\] | '\\' .)* '\'';	// Sin		

NUMBER:
	[0-9]+;

IDENTIFIER:
	[a-zA-Z_][a-zA-Z0-9_]*;

SIGIL:
	'$';
DOT:
	'.';
LPAREN:
	'(';
RPAREN:
	')';
LBRACE:
	'{';
RBRACE:
	'}';
COMMA:
	',';
SEMICOLON:
	';';
COLON:
	':';
ARROW:
	'=>';

// Whitespace
WS:
	[ \t\r\n]+ -> skip;

SL_COMMENT:
	'//' ~[\r\n\u2028\u2029]* -> channel(HIDDEN);