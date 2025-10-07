package main

import (
    "fmt"
    "strings"

    "github.com/antlr4-go/antlr/v4"
    "grammar-execution/parser"
)

type customErrorListener struct {
    *antlr.DefaultErrorListener
    syntaxErrors []string
}

func (el *customErrorListener) SyntaxError(recognizer antlr.Recognizer, offendingSymbol interface{},
    line, column int, msg string, e antlr.RecognitionException) {
    errorMessage := fmt.Sprintf("Syntax error at line %d:%d - %s", line, column, msg)
    el.syntaxErrors = append(el.syntaxErrors, errorMessage)
}

func parseFileContents(contents []byte) ParseResult {
    inputStream := antlr.NewInputStream(string(contents))

    // <<< Aquí inyectaremos en build-time el nombre de la gramática >>>
    lexer := parser.New%GRAMMAR%Lexer(inputStream)
    tokenStream := antlr.NewCommonTokenStream(lexer, 0)
    p := parser.New%GRAMMAR%Parser(tokenStream)

    // Capturamos errores
    errorListener := &customErrorListener{}
    p.RemoveErrorListeners()
    p.AddErrorListener(errorListener)

    // <<< Aquí inyectaremos en build-time la regla raíz >>>
    p.%ROOT_RULE%()

    var result ParseResult
    if len(errorListener.syntaxErrors) == 0 {
        result.Passed = true
    } else {
        result.Passed = false
        result.SyntaxtErrors = strings.Join(errorListener.syntaxErrors, "\n")
    }
    return result
}
