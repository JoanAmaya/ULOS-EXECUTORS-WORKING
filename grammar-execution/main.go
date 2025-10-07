package main

import (
	"fmt"
	"io"
	"os"
	"strings"
	"time"
)

type ParseResult struct {
	FileName      string `json:"filename"`
	Passed        bool   `json:"passed"`
	SyntaxtErrors string `json:"syntax_errors,omitempty"`
}

type CompleteResults struct {
	Passed    bool          `json:"passed"`
	Timestamp string        `json:"timestamp"`
	Detail    []ParseResult `json:"detail"`
}

func main() {

	workDir, err := os.Getwd()
	if err != nil {
		fmt.Println(err)
	}

	fmt.Printf("[INFO] Working directory: %s\n", workDir)
	fmt.Printf("[INFO] Command line arguments: %s\n", os.Args)

	expectedDir := os.Args[1]
	expectedExtension := os.Args[2]

	testFiles := getTestingFiles(workDir, expectedDir, expectedExtension)

	var results CompleteResults

	for _, path := range testFiles {
		fmt.Printf("[INFO] Parsing %s\n", path)

		input, err := os.Open(path)
		if err != nil {
			fmt.Println("Error opening file:", err)
			return
		}
		defer input.Close()

		fileContents, err := io.ReadAll(input)
		if err != nil {
			fmt.Println("Error reading file:", err)
			return
		}

		fileResults := parseFileContents(fileContents)
		fileResults.FileName = strings.Join(strings.Split(path, "/")[3:], "/")
		results.Detail = append(results.Detail, fileResults)

	}

	results.Timestamp = time.Now().Format("2006-01-02 15:04:05")

	results.Passed = true

	for _, detail := range results.Detail {
		if !detail.Passed {
			results.Passed = false
			break
		}
	}

	writeResults(workDir, results)
}
