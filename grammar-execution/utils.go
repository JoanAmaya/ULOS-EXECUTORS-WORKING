package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func getTestingFiles(wdir string, expectedDir string, expectedExtension string) []string {
	fmt.Printf("[INFO] Looking for files in %s with extension %s\n", expectedDir, expectedExtension)

	var testFiles []string

	// Iterate over directory  files
	filepath.Walk(wdir+"/"+expectedDir,
		func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}

			// Look for files with desired extension (eg. cy.js for cypress)
			if !info.IsDir() && strings.Contains(info.Name(), expectedExtension) {
				testFiles = append(testFiles, path)
			}

			return nil
		})

	fmt.Printf("[INFO] Parsing %d test files\n", len(testFiles))
	return testFiles
}

func writeResults(wdir string, contents CompleteResults) {

	resultsDirectory := wdir + "/results"
	fmt.Printf("[INFO] Writing results to %s...\n", resultsDirectory)

	jsonData, err := json.MarshalIndent(contents, "", "  ")

	if err != nil {
		fmt.Println("Error marshaling to JSON:", err)
		return
	}

	err = os.WriteFile(resultsDirectory+"/parse_results.json", jsonData, 0644)

	if err != nil {
		fmt.Println("Error writing JSON file:", err)
		return
	}

	fmt.Println("[INFO] Test result has been written to " + resultsDirectory + "/parse_results.json")

	// create file to indicate execution tests passed
	if contents.Passed {
		_, err = os.Create(wdir + "/results/passed.log")
		if err != nil {
			fmt.Println("[ERROR] Error creating passed.log file:", err)
			return
		}
	}
	// remove tmp task file that indicates in progress execution
	err = os.Remove(wdir + "/results/task.log")
	if err != nil {
		fmt.Println("[ERROR] Error removing task.log file:", err)
		return
	}

}
