package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"
)

type TestResult struct {
	FileName    string `json:"filename"`
	TestsPassed int    `json:"tests_passed"`
	TestsFailed int    `json:"tests_failed"`
	Passed      bool   `json:"result"`
}

type CompleteResults struct {
	CypressVersion      string       `json:"cypress_version"`
	Browser             string       `json:"browser"`
	Specs               string       `json:"specs"`
	Passed              bool         `json:"passed"`
	Timestamp           string       `json:"timestamp"`
	HasScreenshots      bool         `json:"has_screenshots"`
	ScreenshotsLocation string       `json:"screenshots_location,omitempty"`
	HasVideo            bool         `json:"has_video"`
	VideoLocation       string       `json:"video_location,omitempty"`
	Detail              []TestResult `json:"detail"`
}

func main() {

	workDir, err := os.Getwd()
	if err != nil {
		fmt.Println(err)
	}

	resultsFile := os.Args[1] // should be /results/XX_execution_output.txt
	browser := strings.Split(strings.Split(resultsFile, "/")[2], "_")[0]
	outputFilePrefix := fmt.Sprintf("/results/%s_", browser)
	fmt.Printf("[INFO] Browser: %s | Input File: %s | Output To: %s\n", browser, resultsFile, outputFilePrefix)

	// Open the file
	file, err := os.Open(workDir + resultsFile)
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close()

	fmt.Printf("[INFO] Parsing execution ouput from %s...\n", workDir+resultsFile)

	var result CompleteResults
	scanner := bufio.NewScanner(file)

	// General info regex
	cypressVersionRegex := regexp.MustCompile(`Cypress:`)
	browserRegex := regexp.MustCompile(`Browser:`)
	specRanRegex := regexp.MustCompile(`Specs:`)

	// Test based regex
	runningRegex := regexp.MustCompile(`Running:\s+(\S+)`)
	testsPassedRegex := regexp.MustCompile(`Passing:`)
	testsFailedRegex := regexp.MustCompile(`Failing:`)

	screenshotsRegex := regexp.MustCompile(`(Screenshots)`)
	videoRegex := regexp.MustCompile(`(Video)`)

	var testSuites []TestResult

	var inProgressSuite TestResult

	for scanner.Scan() {
		line := scanner.Text()

		if matches := cypressVersionRegex.FindStringSubmatch(line); len(matches) == 1 {
			result.CypressVersion = strings.Split(strings.TrimSpace(strings.Split(line, ":")[1]), " ")[0]
		}

		if matches := browserRegex.FindStringSubmatch(line); len(matches) >= 1 {
			sl := strings.Split(strings.Split(line, ":")[1], " ")
			result.Browser = strings.TrimSpace(strings.Join(sl[:len(sl)-2], " "))
		}

		if matches := runningRegex.FindStringSubmatch(line); len(matches) >= 1 {

			if (TestResult{} != inProgressSuite) {
				// END OF BUILDING -- APPENDING TO LIST
				inProgressSuite.Passed = true
				if inProgressSuite.TestsFailed > 0 {
					inProgressSuite.Passed = false
				}
				testSuites = append(testSuites, inProgressSuite)

				// RESET SUITE
				inProgressSuite.FileName = strings.TrimSpace((strings.Split(strings.Split(line, ":")[1], " ")[2]))

			} else {
				inProgressSuite.FileName = strings.TrimSpace((strings.Split(strings.Split(line, ":")[1], " ")[2]))
			}

		}

		if matches := testsPassedRegex.FindStringSubmatch(line); len(matches) >= 1 {
			passedInt, err := strconv.Atoi(strings.Split(strings.TrimSpace(strings.Split(line, ":")[1]), " ")[0])
			if err != nil {
				panic(err)
			}
			inProgressSuite.TestsPassed = passedInt
		}

		if matches := testsFailedRegex.FindStringSubmatch(line); len(matches) >= 1 {
			passedInt, err := strconv.Atoi(strings.Split(strings.TrimSpace(strings.Split(line, ":")[1]), " ")[0])
			if err != nil {
				panic(err)
			}

			inProgressSuite.TestsFailed = passedInt
		}

		if matches := screenshotsRegex.FindStringSubmatch(line); len(matches) >= 1 {
			result.HasScreenshots = true
			result.ScreenshotsLocation = "/cypress/screenshots/"
		}

		if matches := videoRegex.FindStringSubmatch(line); len(matches) >= 1 {
			result.HasVideo = true
			result.VideoLocation = "/cypress/videos/"
		}

		if matches := specRanRegex.FindStringSubmatch(line); len(matches) >= 1 {
			sl := strings.Split(strings.Split(line, ":")[1], " ")
			result.Specs = strings.TrimSpace(strings.Join(sl[:len(sl)-2], " "))
		}
	}

	result.Timestamp = time.Now().Format("2006-01-02 15:04:05")

	// Append last suite found

	inProgressSuite.Passed = true
	if inProgressSuite.TestsFailed > 0 {
		inProgressSuite.Passed = false
	}
	result.Detail = append(testSuites, inProgressSuite)

	result.Passed = true

	for _, detail := range result.Detail {
		if !detail.Passed {
			result.Passed = false
			break
		}
	}

	// Output the result as JSON
	jsonData, err := json.MarshalIndent(result, "", "  ")
	if err != nil {
		fmt.Println("[ERROR] Error marshaling to JSON:", err)
		return
	}

	resultsOutputFile := workDir + outputFilePrefix + "execution_results.json"
	logOutputFile := workDir + outputFilePrefix + "execution_passed.log"

	err = os.WriteFile(resultsOutputFile, jsonData, 0644)
	if err != nil {
		fmt.Println("[ERROR] Error writing JSON file:", err)
		return
	}

	fmt.Println("[INFO] Test result has been written to" + resultsOutputFile)

	// create file to indicate execution tests passed
	if result.Passed {
		_, err = os.Create(logOutputFile)
		if err != nil {
			fmt.Println("[ERROR] Error creating passed.log file:", err)
			return
		}
	}
}
