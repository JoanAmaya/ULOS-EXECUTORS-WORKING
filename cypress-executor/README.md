# Cypress Executor Engine

## Consumer Node - Prerequisites

- Files to be tested on a local directory, unzipped.
- The directory where the project is contained (its parent) should be mounted as a volume to the container.

## Cypress Execution Image

- The cypress image uses the [cypress/included](https://github.com/cypress-io/cypress-docker-images/tree/master/included) image provided by the Cypress team as the base.
- There is a script written in Go to parse terminal results into JSON format into the following schema:
  
```JSON
{
  "cypress_version": "13.11.0",
  "browser": "Electron 118 (headless)",
  "specs": "2 found (spec.cy.js, page-a/actions.cy.js)",
  "passed": false,
  "timestamp": "2024-10-24 18:14:14",
  "has_screenshots": true,
  "screenshots_location": "/cypress/screenshots/",
  "has_video": true,
  "video_location": "/cypress/videos/",
  "detail": [
    {
      "filename": "spec.cy.js",
      "tests_passed": 0,
      "tests_failed": 1,
      "result": false
    },
    {
      "filename": "page-a/actions.cy.js",
      "tests_passed": 1,
      "tests_failed": 0,
      "result": true
    }
  ]
}
```

- A separate results file will be generated for each browser tested on (currently Electron and Chrome).
- The script is compiled within while building the image, but can be tested externally using the following command:

```shell
env GOOS=linux GOARCH=arm64 go build -o parse-cypress
```

### Building the image

There are no build arguments required.

```shell
docker build -f Dockerfile.cypress -t cypress-executor .
```

**Run Command:**

```shell
docker run -it -v /path/on/host/:/mnt/cypress_test -e DIRECTORY_PATH='file-1' cypress-executor
```

> ⚠️  `/path/on/host` must be a directory on you local machine where you have stored the testing files

- `DIRECTORY_PATH` is the top-level folder (or archive name) under `/mnt/tests/` containing your test files.
